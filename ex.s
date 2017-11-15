org $208000
font_bin:
	incbin "font.bin"
St_set_main:
	incbin "st_main.sfc"
St_set_shop:
	incbin "st_shop.sfc"
St_set_chocobo:
	incbin "st_fatc.sfc"
St_set_battle:
	incbin "st_bttl.sfc"
St_set_name:
	incbin "st_name.sfc"
St_set_config:
	incbin "st_optn.sfc"
// 4096 bytes empty

// this uses one full bank
org $218000
item_bin:
	incbin "item.sfc"

org $228000
St_vwf_equip_map:
	php			// preserve state
	phx
	rep #$20	// a.16
	tya			// load equip slot index
	sec
	sbc #$0030	// -0x30
	asl			// *2
	tax
	lda tmap_equip_start,x
	sta $45
	plx
	plp
	rtl
	
tmap_equip_start:
	dw $278, $280
	dw $288, $290
	dw $000, $298	// entry 4 is never used

St_vwf_shop_tmap:
	pha
	php			// preserve state
	rep #$20	// a.16
	txa			// item indexing
	asl			// *8 + 0x100
	asl
	clc
	adc #$100
	sta $45
	plp
	pla
	rtl

St_vwf_item_tmap:
	php			// preserve state
	rep #$20	// a.16
	lda $5D		// item indexing
	and #$00FF	// clear higher bits
	asl			// *8 + 0x100
	asl
	asl
	clc
	adc #$100
	sta $45
	plp
	rtl

_St_init_main:
	ldx #(St_set_main & 0xffff)
	ldy #(St_set_main >> 16)
	jsr St_DMA_trans_set
	rtl
	
_St_init_shop:
	ldx #(St_set_shop & 0xffff)
	ldy #(St_set_shop >> 16)
	jsr St_DMA_trans_set
	rtl
	
_St_init_name:
	ldx #(St_set_name & 0xffff)
	ldy #(St_set_name >> 16)
	jsr St_DMA_trans_set
	rtl
	
_St_init_choco:
	ldx #(St_set_main & 0xffff)
	ldy #(St_set_main >> 16)
	jsr St_DMA_trans_set
	rtl

_St_init_config:
	ldx #(St_set_config & 0xffff)
	ldy #(St_set_config >> 16)
	jsr St_DMA_trans_set
	rtl

St_DMA_trans_set:
// X.16 set location
// Y.16 set bank
	rep #$20
	lda #$3800		// last 256 tiles of vram
	sta {dma_dst}
	stx {dma_srcl}
	sty {dma_srch}
	lda #4096
	sta {dma_size}
	sep #$20
	jsr St_DMA0_trans_x
	rts

// wait until DMA can send stuff to vram
St_ex_wait_NMI:
	// wait for VRAM being accessible
-
	lda $004212
	and.b #$80
	beq -
	// read v-count
	lda $002137	// enable latch
	lda $00213d
	xba
	lda $00213d
	and.b #1
	xba
	rep #$20
	// see if we're in safe range for DMA transfers
	cmp #256
	bcc +
	sep #$20
	// if we're beyond safe ranges, wait until next frame
-
	lda $004210
	and.b #$80
	beq -
-
	lda $004212
	and.b #$80
	beq -
+
	sep #$20
	rts

St_DMA_trans_item:
	php
	phb

	sep #$20	// a.8
	// check stuff into the list
	lda {list_cnt}
	beq __end			// prematurely kill loop if list is empty
	
	lda.b #0
	pha
	plb

	rep #$20			// a.16
	stz $43
-
	
	rep #$20			// a.16
	lda $43
	inc $43
	asl
	asl
	asl
	tax
	lda {list_srcl},x	// source
	sta {dma_srcl}
	lda {list_srch},x	// source bank
	sta {dma_srch}
	lda #(16*8)		// size of an item
	sta {dma_size}
	lda {list_dst},x	// destination in vram
	sta {dma_dst}
	sep #$20			// a.8
	jsr St_ex_wait_NMI
	jsr St_DMA0_trans_x	// send shit to dma
	lda {list_cnt}
	dec
	sta {list_cnt}		// decrease transfer counter
	bne -
	//
__end:
	plb
	plp
	rtl

St_write_item_tmap:
	php
	
	rep #$20	// a.16
	lda #8		// i<8
	sta $43
-
	lda $45
	sep #$20	// a.8
	xba
	ora $DB		// load attributes
	ora $34
	xba
	rep #$20	// a.16
	sta ($1D),y
	lda #$00ff	// write blank tile
	sta ($29),y
	iny
	iny
	inc $45		// tile index
	dec $43		// i++
	bne -
	
	plp			// --
	rtl

St_DMA_reg_item_init:
	lda.b #0
	sta {list_cnt}
	rtl

// $43 item
// $45 tile index start
St_DMA_reg_set_magic:
	php
	
	rep #$20		// a.16
	lda {list_cnt}	// list counter
	and #$00ff
	asl				// position on current list entry
	asl
	asl
	tax				// move to index mode

	lda $43			// item * 128
	and #$00ff		// just in case
	asl
	asl
	asl
	asl
	asl
	asl
	asl
	clc
	adc #(item_bin & 0xffff)
	sta {list_srcl},x	// base
	lda #(item_bin >> 16)	
	sta {list_srch},x	// bank
	
	lda $45			// tile index * 8
	asl
	asl
	asl
	clc
	adc #$2000
	sta {list_dst},x
	
	lda #(16*8)
	sta {list_size},x
	
	sep #$20		// a.8
	lda {list_cnt}	// list counter++
	inc
	sta {list_cnt}
	
	plp
	rtl
	
// $43 item
// $45 tile index start
St_DMA_reg_set_item:
	php
	
	rep #$20		// a.16
	lda {list_cnt}	// list counter
	and #$00ff
	asl				// position on current list entry
	asl
	asl
	tax				// move to index mode

	lda $43			// item * 128
	and #$00ff		// just in case
	xba
	ror
	clc
	adc #(item_bin & 0xffff)
	sta {list_srcl},x	// base
	lda #(item_bin >> 16)	
	sta {list_srch},x	// bank
	
	lda $45			// tile index * 8
	asl
	asl
	asl
	clc
	adc #$2000
	sta {list_dst},x
	
	lda #(16*8)
	sta {list_size},x
	
	sep #$20		// a.8
	lda {list_cnt}	// list counter++
	inc
	sta {list_cnt}
	
	plp
	rtl
	
St_DMA0_trans_x:
	phb
	tdc
	pha
	plb
	lda #$80
	sta $002115
	tdc
	sta $00420c
	ldy {dma_dst}
	sty $2116
	lda.b #1
	sta $004300
	lda.b #$18		// vram port
	sta $004301
	rep #$20		// a.16
	lda {dma_srcl}
	sta $004302
	lda {dma_srch}
	and #$00ff
	sta $004304
	lda {dma_size}
	sta $004305
	//stz $4306
	sep #$20
	lda.b #1
	sta $00420b
	plb
	rts

St_vwf_magic_tmap:
	php			// preserve state
	pha
	sta $43		// save item id
	rep #$20	// a.16
	tya			// copy slot index
	sta $45		// item indexing
	asl			// *6 + 0x100
	adc $45
	and #$01FF	// clear higher bits
	asl
	clc
	adc #$100
	sta $45
	pla
	plp
	rtl
	
St_write_magic_tmap:
	php
	rep #$20
	lda #6		// tiles to fill
	sta $43
-
	lda $45		// tile start count
	sep #$20	// a.8
	xba
	ora $DB		// load attributes
	xba
	rep #$20	// a.16
	sta $7e0000,x
	lda #$00ff	// write blank tile
	sta $7e0000,x
	inx
	inx
	inc $45		// tile index
	dec $43		// i++
	bne -
	plp			// --
	rts

St_write_item_tmap:
	php
	rep #$20	// a.16
	lda #8		// i<8
	sta $43
-
	lda $45
	sep #$20	// a.8
	xba
	ora $DB		// load attributes
	ora $34
	xba
	rep #$20	// a.16
	sta ($1D),y
	lda #$00ff	// write blank tile
	sta ($29),y
	iny
	iny
	inc $45		// tile index
	dec $43		// i++
	bne -
	plp			// --
	rts
	
St_tmap_desc:
	php
	//
	sep #$20	// a.8	

	//lda #(data_desc),x	// tile count
	rep #$20	// a.16
	and #$00ff	// clear upper bits
	sta $43
	//lda #(data_desc+1),x	// location	
	//lda #(data_desc+3),xba	// bank
	and #$00ff
	//
	plp
	rts
	
st_desc_ck_init:
	lda.b #0
	sta {list_inv_last}
	rtl

St_desc_ck_update:
	php
	sep #$20
	lda $1b23
	clc
	adc $1b1a
	asl
	adc $1b22
	sta $43		// store obtained value to temp
	lda {list_inv_last}
	cmp $43
	beq +		// same value, no need to dma tiles
	jsl St_DMA_reg_item_init
	jsl St_DMA_trans_item
	lda $43
	sta {list_inv_last}	// update old value
+	
	plp
	rtl

data_desc:
	incbin test.dat
//org $238000
//	incbin "test.sfc"
