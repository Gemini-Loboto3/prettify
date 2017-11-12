org $208000
font_bin:
	incbin "font.bin"

// this uses one full bank
org $218000
item_bin:
	incbin "item.sfc"

org $228000
// wait until DMA can send stuff to vram
St_ex_wait_NMI:
-
	lda $004212
	and.b #$80
	beq -
	lda $002137	// enable latch
	lda $00213d
	xba
	lda $00213d
	and.b #1
	xba
	rep #$20
	cmp #256
	bcc +
	sep #$20
-
	lda $004210
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
