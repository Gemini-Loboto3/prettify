//////////////////////////////////
// EQUIPMENT					//
//////////////////////////////////
org $1BD0F
	jsr hook_St_draw_equip0
org $1BDBB
	jsr hook_St_draw_equip1

//////////////////////////////////
// ITEMS						//
//////////////////////////////////
// inventory
org $1A181
	jsr hook_St_draw_items0	// hook
	nop
org $1A185
hook_back:
org $1A1D5
	jsr hook_St_draw_items1
	bne hook_back	// @@loop
	jsr hook_St_draw_items2
	rts
	
// shop
org $1C44B
	jsr St_shop_hook
org $1C49A
	jsr St_shop_hook
org $1C580
	jsr St_shop_inject

org $1FF35
St_shop_inject:
	phy
	phy
	jsr St_vwf_shop_tmap
	jmp St_item_tmap_write1

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
	rts

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
	rts

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
	rts

jml_St_DMA0_trans:
	jsr $18078	// St_DMA0_trans
	rtl

hook_St_draw_items0:
	stz $5D
	stz $5E
	jsl St_DMA_reg_item_init
	rts
	
hook_St_draw_items1:
	inc $5D
	lda $5D
	cmp $E1
	rts

hook_St_draw_items2:
	jsl St_DMA_trans_item
	rts
	
hook_St_draw_equip0:
	jsl St_DMA_reg_item_init
	ldy #$DDA9
	rts
	
hook_St_draw_equip1:
	jsl St_DMA_trans_item
	lda $1BAD
	rts

// originally built tile map for an equipment
// revised to work similarly but with no string copying and
// prepares DMA queue
// input paramters:
//  X.16 position on tilemap
//  Y.16 item list index
define temp_u8	$43

org $19013
St_equip_tmap_write:
	PHY
	PHX					// push tilemap index
	jsr St_vwf_equip_map	//*** extra
	LDA ($60),y			// pull item id from inventory list
// secondary entry point
St_item_tmap_write1:
	STA $43
	jsl St_DMA_reg_set_item
	REP #$20
	LDA $29
	CLC
	ADC #$0040
	STA $1D
	// item id * 9 (size of string)
	LDA $43
	ASL
	ASL
	ASL
	ADC $43
	TAX					// turn A to index
	SEP #$20
	PLY					// get tilemap index
	LDA $F8000,x		// load icon
	STA ($1D),y
	INY
	LDA $DB
	ORA $34
	STA ($29),y
	STA ($1D),y
	INY
	jsl St_write_item_tmap	//*** extra piece
	PLY
	RTS

St_shop_hook:
	jsl St_DMA_reg_item_init
	jsr $1C4A0	// St_shop_write_list
	phy		// fixes shit with cursor
	jsl St_DMA_trans_item
	ply		// fixes shit with cursor
	rts

St_item_inject:
	pha
	jsr St_vwf_item_tmap	//*** extra piece
	pla
	bra St_item_tmap_write1


// originally built tile map for drawing the inventory
// input paramters:
//  A.8
//  Y.16 position on tilemap
org $19060
St_item_tmap_write:
	PHY
	PHY
	BRA St_item_inject
