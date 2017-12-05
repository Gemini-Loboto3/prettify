// definitions of some functions
org $18C7D
St_init:
org $1D1A1
St_config:
org $197D3
St_save_loop:

//////////////////////////////////
// MAGIC AND SKILLS				//
//////////////////////////////////

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

// hack item descriptions for everything
org $1A7E2
	sta $e600
	ldx.w #$54
	jsl St_desc_tmap_write
	rts
// couple useful hooks
St_desc_trans0:
	jsr $18078	// St_DMA0_trans
	lda.b #$ff
	sta {list_inv_last}
	jsl St_desc_ck_update
	rts
St_desc_trans1:
	jsr $19423	// St_set_DMA_vbg2
	jsl St_desc_ck_update
	rts

org $19FE6
	jsr St_desc_trans0
org $1A049
	jsr St_desc_trans1
org $1A09F
	jsr St_desc_trans1

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
St_shop_hook:
	jsl St_DMA_reg_item_init
	jsr $1C4A0	// St_shop_write_list
	phy		// fixes shit with cursor
	jsl St_DMA_trans_item
	ply		// fixes shit with cursor
	rts

St_init_main:
	jsl _St_init_main
__init_main:
	jsr St_init
	rts

St_init_shop:
	jsl _St_init_shop
	bra __init_main

St_init_load:
	jsr $1947e			// wait for fade
__init_load:
	jsl _St_init_load
	rts
	
St_init_name:
	jsl _St_init_name
	jsr St_init
	rts
	
St_init_config:
	jsl _St_init_config
	jsr St_config
	rts
	
St_exit_config:
	jsr $1947E
	jsl _St_init_main
	rts
	
St_init_treasure:
	jsl _St_init_treasure
	jsr St_init
	rts

St_shop_inject:
	phy
	phy
	jsl St_vwf_shop_tmap
	jmp St_item_tmap_write1

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

hook_Load_names:
	jsl Load_names
	rts

hook_Save_names:
	jsl Save_names
	rts
	
warnpc $28000

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
	jsl St_vwf_equip_map	//*** extra
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

St_item_inject:
	pha
	jsl St_vwf_item_tmap	//*** extra piece
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
