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
Fld_font8_dlg:
	incbin "font8_dlg.bin"

// this uses one full bank
org $218000
item_bin:
	incbin "item.sfc"
	
org $238000
item_desc_gfx:
	incbin "item_desc.sfc"

org $268000
dialog_pptr2:
	incbin "dial.ptr"
dialog_ptr1:
	incbin "dial1.ptr"
dialog_ptr2:
	incbin "dial2.ptr"
dialog_ptr3:
	incbin "dial3.ptr"
dialog_data:
	incbin "dial.bin"
	
// include further data here
org $2A8000
prophecy_mes:
	incbin "prophecy.bin"
prophecy_gfx:
	incbin "prophecy.sfc"
font_staff:
	incbin "font_staff.sfc"

org $228000
_St_name_draw:
	ldx.w #0		// always use first slot
	ldy.w #$1B0A	// 7E1B0A, current name buffer
	lda.b #$7e
	jsr Generate_name

_St_trans_namex:
	ldx.w #$e610
	stx {dma_srcl}
	lda.b #$7e
	sta {dma_srch}
	ldx.w #$3700
	stx {dma_dst}
	ldx.w #(6*16)
	stx {dma_size}
	jsr St_DMA0_trans_x
	rtl

_St_init_name:
	phb			// fix bank issues
	lda #$7e
	pha
	plb
	jsr St_trans_names
	ldx #(St_set_name & 0xffff)
	ldy #(St_set_name >> 16)
	jsr St_DMA_trans_set
	plb			// restore bank
	rtl

_St_init_main:
	jsr St_trans_names
	ldx #(St_set_main & 0xffff)
	ldy #(St_set_main >> 16)
	jsr St_DMA_trans_set
	rtl
	
_St_init_load:
	jsr St_trans_names
	rtl

_St_init_config:
	ldx #(St_set_config & 0xffff)
	ldy #(St_set_config >> 16)
	jsr St_DMA_trans_set
	rtl

_St_init_shop:
	ldx #(St_set_shop & 0xffff)
	ldy #(St_set_shop >> 16)
	jsr St_DMA_trans_set
	rtl
	
_St_init_choco:
	ldx #(St_set_main & 0xffff)
	ldy #(St_set_main >> 16)
	jsr St_DMA_trans_set
	rtl
	
_St_init_treasure:
	ldx #(St_set_battle & 0xffff)
	ldy #(St_set_battle >> 16)
	jsr St_DMA_trans_set
	rtl

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
	dw $280, $288
	dw $290, $298
	dw $000, $2A0	// entry 4 is never used

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
	lsr
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

St_desc_ck_init:
	lda.b #0
	sta {list_inv_last}
	rtl

// parameters:
// A.8 item id
// X.16 where to write
St_desc_tmap_write:
	phd
	rep #$20
	and.w #$00ff
	asl				// pointer from where to read description data
	asl
	asl
	tay				// keep pointer into Y.16
	stx $11d		// preserve tile seek
	lda.w #$100		// dpage = $100
	pha				// --
	pld				// --
	lda #$2280		// $278, base tile for descriptions
	sta $11f		// store
	lda.w #2		// loop twice max
	sta $45
.string:
	tyx
	sep #$20
	lda item_desc_data,x	// set line size
	beq .end		// if zero, quit writing
	txy
	sta $43
	stz $44
	rep #$20
	lda $11d		// load vram seek
	adc $29			// base
	tax
	lda $11f		// load tile counter
.line:
	sta $7e0040,x
	inc				// tile_cnt++
	inx				// vram_ptr++
	inx
	dec $43
	bne .line
	sta $11f		// preserve tile counter
	lda $11d		// tile seek += 32
	clc
	adc.w #64
	sta $11d
	iny				// next line data
	dec $45
	bne .string
.end:
	sep #$20
	pld
	rtl

St_desc_trans:
	php
	rep #$20
	lda $e600					// reload item id
	and.w #$00ff
	beq +						// item 0 transfers nothing
	asl
	asl
	asl
	tax
	lda.w #$3400				// vram destination
	sta {dma_dst}
	lda item_desc_data+4,x		// pointer
	sta {dma_srcl}
	lda item_desc_data+6,x		// bank
	sta {dma_srch}
	lda item_desc_data+2,x		// size
	//lda.w #256
	sta {dma_size}
	sep #$20
	jsr St_ex_wait_NMI
	jsr St_DMA0_trans_x			// transfer tiles!
+
	plp
	rts

item_desc_data:
	incbin "item_desc.dat"

St_desc_ck_update:
	php
	sep #$20
	lda $1b23
	clc
	adc $1b1a
	asl
	adc $1b22
	sta $43				// store obtained value to temp
	lda {list_inv_last}
	cmp $43
	beq +				// same value, no need to dma tiles
	jsr St_desc_trans
	lda $43
	sta {list_inv_last}	// update old value
+	
	plp
	rtl

tbl_str_jobs:
	db $90, $91, $92, $93, $94, $95, $ff, $ff	// Dark Knight
	db $96, $97, $98, $99, $9A, $9B, $ff, $ff	// Dragon Knight
	db $9C, $9D, $9E, $9F, $A0, $A1, $ff, $ff	// Summoner
	db $A2, $A3, $A4, $ff, $ff, $ff, $ff, $ff	// Sage
	db $A5, $A6, $A7, $ff, $ff, $ff, $ff, $ff	// Bard
	db $A8, $A9, $AA, $AB, $AC, $AD, $ff, $ff	// White Mage
	db $8A, $8B, $8C, $8D, $8E, $ff, $ff, $ff	// Monk
	db $B2, $B3, $B4, $AB, $AC, $AD, $ff, $ff	// Black Mage
	db $A8, $A9, $AA, $AB, $AC, $AD, $ff, $ff	// White Mage
	db $B5, $B6, $B7, $B8, $ff, $ff, $ff, $ff	// Paladin
	db $B9, $BA, $BB, $BC, $BD, $ff, $ff, $ff	// Engineer
	db $9C, $9D, $9E, $9F, $A0, $A1, $ff, $ff	// Summoner
	db $BE, $BF, $C0, $ff, $ff, $ff, $ff, $ff	// Ninja
	db $7B, $7C, $7D, $7E, $7F, $ff, $ff, $ff	// Lunarian
	db $7B, $7C, $7D, $7E, $7F, $ff, $ff, $ff	// Lunarian (for Golbeza)
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	// empty (for Anna)

//////////////////////////////
// PLAYER NAMES				//
//////////////////////////////

// Generates all tile data for player names
// and transfers them to vram
St_trans_names:
	php
	jsr Generate_names
	rep #$20
	lda.w #5
	sta $43
	ldx.w #0
-
	lda .trans_tbl, x
	inx
	inx
	sta {dma_srcl}
	lda.w #$7e
	sta {dma_srch}
	lda .trans_tbl, x
	inx
	inx
	sta {dma_dst}
	lda.w #(6*16)
	sta {dma_size}
	sep #$20
	phx
	jsr St_DMA0_trans_x
	plx
	rep #$20
	dec $43
	bne -
	plp
	rts
.trans_tbl:
	dw $e610, $3700
	dw $e690, $3730
	dw $e710, $3760
	dw $e790, $3790
	dw $e810, $37C0

// Generate all player name tiles
Generate_names:
define .temp0	$143
define .temp1	$145
	php
	ldx.w #5
	stx {.temp0}
	stz {.temp1}
	stz {.temp1}+1
-
	rep #$20
	ldx {.temp1}
	// seek on player structure (* 64)
	txa
	xba
	lsr
	lsr
	tay				// player slot index generated
	lda $1000,y		// load player ID
	and.w #$003F
	beq +			// empty slot, skip
	dec
	tax
	lda $18457,x	// load from id to string lookup
	and.w #$00ff	// remove junk
	asl				// id * 8
	asl
	asl
	clc
	adc #({ex_name_data} & 0xffff) 
	pha				// string pointer
	sep #$20		// A.8
	lda.b #({ex_name_data} >> 16)	// string bank
	pha
	// seek on name buffer
	rep #$20
	lda {.temp1}
	xba	// * 128 (= *256 / 2)
	lsr
	tax
	sep #$20
	pla
	ply
	jsr Generate_name
+
	inc {.temp1}	// slot++
	dec {.temp0}	// i++
	bne -
	plp
	rts

// Generate tiles for a player name
// parameters
// X.16 slot indexing
// Y.16 string pointer
// A.8  string bank
define temp_0	$e600
define temp_1	$e602
define temp_2	$e604
define draw_x	$e606	// current draw x value
define draw_xh	$e607
define jtbl_x	$e608	// jumptable index (x*2)
define bmp_i	$e60A	// canvas seek
define slot		$e60C	// base index for buffer writes
define name_buf	$e610	// name buffer
define name_bun	$e620	// name buffer next tile
define str_i	$1d		// 24 bit string seek
define str_im	$1e
define str_ih	$1f

Generate_name:
	php
	phd
	pha
	// change direct page
	rep #$20			// A.16
	tdc					// get current dpage
	lda.w #$0100		// replace it
	tcd
	sep #$20			// A.8
	//
	pla
	// store 24 bit pointer to string
	sty {str_i}			// pointer
	sta {str_ih}		// bank
	stx {slot}			// preserve buffer index
	rep #$20			// A.16
	ldy.w #(8*16/2)		// size of buffer
	lda.w #0			// clear value
	ldx {slot}
	// clear buffer
-
	sta {name_buf},x
	inx
	inx
	dey
	bne -
	
	// reset draw x
	stz {draw_x}
	stz {draw_xh}

	lda.w #8			// i, max size of a string
	sta {temp_1}		// --
.string:
	// compute buffer seek (=(x >> 3) * 16)
	lda {draw_x}		// load draw x
	and.w #$fff8
	asl
	clc
	adc {slot}			// add slot seek
	sta {bmp_i}			// store buffer seek
	// compute value for correct shifting
	lda {draw_x}		// load draw x
	and.w #$7			// x % 8
	asl					// make index for jump table
	sta {jtbl_x}		// store as index
	lda.w #16			// j, loop for all 16 planes
	sta {temp_0}		// --
	// calculate where to load stuff from font
	lda [{str_i}]		// *string
	and.w #$00ff
	cmp.w #$ff
	beq .end
	sec
	sbc.w #$0f
	// character to font position (*16)
	asl
	asl
	asl
	asl
	tax
.line:
	// load one plane
	lda font_name,x
	inx
	txy					// preserve font seek
	and #$00ff
	beq .empty			// skip completely empty lines
	xba					// put pixels into upper bits
	ldx {jtbl_x}		// load jump index
	jmp (.jtbl,x)
	// create shifted plane
.shf7:
	lsr
.shf6:
	lsr
.shf5:
	lsr
.shf4:
	lsr
.shf3:
	lsr
.shf2:
	lsr
.shf1:
	lsr
.shf0:
	sep #$20			// A.8
	xba					// switch to first plane
	sta {temp_2}		// store temp result
	ldx {bmp_i}			// reload buffer seek
	// vwf for first tile
	cmp.b #0
	beq +
	lda {name_buf},x	// load current
	ora {temp_2}		// OR the result
	sta {name_buf},x	// update current
+
	// store for next tile
	xba					// switch to next line
	cmp.b #0
	beq +
	sta {name_bun},x	// write next if there is any data
+
	rep #$20			// A.16
	bra .not_empty
.empty:
	ldx {bmp_i}
.not_empty:
	inx					// buffer++
	stx {bmp_i}			// update buffer seek
	tyx					// restore font seek
	// j++
	dec {temp_0}
	bne .line
	
	// load width
	lda [{str_i}]		// *string
	and.w #$00ff
	sec
	sbc.w #$0f
	tax
	lda font_namew,x	// get w
	and.w #$00ff
	// draw_x += w
	clc
	adc {draw_x}
	sta {draw_x}
	// i++
	inc {str_i}			// string++
	dec {temp_1}
	beq .end
	jmp .string
.end:
	// change tile colors to follow real palette
	ldy.w #(8*16/2)	// size of buffer
	ldx {slot}		// buffer seek
-
	lda {name_buf},x
	eor.w #$00ff
	sta {name_buf},x
	inx
	inx
	dey
	bne -
	// leave
.exit:
	pld
	plp
	rts
.jtbl:
	dw .shf0, .shf1, .shf2, .shf3, .shf4, .shf5, .shf6, .shf7
	
font_namew:
	// U gagigugegozazizuzezodadidudedo
	db 8,8,8,8,8,8,8,7,8,8,8,8,8,8,8,8
	// babibubebopapipupepoGAGIGUGEGOZA
	db 8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8
	// ZIZUZEZODADIDUDEDOBABIBUBEBOPAPI
	db 8,8,8,8,8,8,8,8,7,8,7,8,8,8,8,7
	// PUPEPOA B C D E F G H I J K L M
	db 8,8,8,5,5,5,5,5,5,5,5,4,5,5,5,6
	// N O P Q R S T U V W X Y Z a b c
	db 5,5,5,5,5,5,6,5,5,6,5,6,5,5,5,5
	// d e f g h i j k l m n o p q r s
	db 5,5,5,5,5,2,3,5,2,6,5,5,5,5,5,5
	// t u v w x y z & # + { } woduxaxu
	db 4,5,5,6,5,5,5,5,6,6,5,5,7,7,7,7
	// xo0 1 2 3 4 5 6 7 8 9 a i u e o
	db 7,5,4,5,5,5,5,5,5,5,5,8,8,7,8,8
	// kakikukekosasisusesotatitutetona
	db 8,8,6,8,8,8,7,8,8,7,8,8,8,8,7,8
	// ninunenohahihuhehomamimumemoyayu
	db 8,8,8,8,8,8,8,8,8,7,8,8,8,8,8,8
	// yorarirurerowan XAXI[ XEXOXDXAXU
	db 8,7,6,8,8,8,8,8,6,6,4,6,6,6,6,6
	// XO, . - @ ! ? % / : ] A I U E O
	db 6,3,2,6,5,2,5,5,4,2,4,8,8,8,8,8
	// KAKIKUKEKOSASISUSESOTATITUTETONA
	db 7,8,8,8,7,8,8,7,8,8,8,8,7,8,6,8
	// NINUNENOHAHIHUHEHOMAMIMUMEMOYAYU
	db 8,8,8,7,8,8,8,8,8,8,8,8,8,8,8,8
	// YORARIRUREROWAN
	db 7,8,6,8,7,7,7,7

font_name:
	incbin font_names.bin

table "table.tbl"
pl_name_tables:
	db "Cecil   "
	db "Cain    "
	db "Rydia   "
	db "Tella   "
	db "Gilbert "
	db "Rosa    "
	db "Yang    "
	db "Palom   "
	db "Porom   "
	db "Cid     "
	db "Edge    "
	db "Fusuya  "
	db "Golbeza "
	db "Anna    "

// Tries to expand names upon boot
Boot_names:
	jsr St_ck_expand_names
	jsl $1800C	// Status3_load
	rtl

//
St_ck_expand_names:
	php
	rep #$20
	// change dpage
	tdc
	pha			// store it
	lda.w #0
	tcd
	lda {ex_name_ok}
	cmp.w #(('K'<<8) | 'O')	// check if sram contains 'OK'
	beq +
	jsr St_expand_names
	lda.w #(('K'<<8) | 'O')
	sta {ex_name_ok}
+
	// restore dpage
	pld
	plp
	rts

// 
St_expand_names:
define name_src 	$001d
define name_srcb	$001f
define name_dst 	$0020
define name_dstb	$0022
	php
	sep #$20
	ldx.w #0		// slot id
	lda.b #4		// number of slots to convert
	sta $45
.slot:
	// setup pointers for a slot
	jsr _Get_src_ptr
	jsr _Set_src
	jsr _Get_dst_ptr
	jsr _Set_dst
	inx
	lda.b #14		// count of names
	sta $47
.name:
		lda.b #6	// size of original names
		sta $43
.char:
			jsr _Read_src
			jsr _Write_dst
			dec $43
			bne .char
			// write padding
			lda.b #$ff
			jsr _Write_dst
			jsr _Write_dst
			dec $47
			bne .name
		dec $45
		bne .slot
	


	plp
	rts

// X.16 slot
_Get_src_ptr:
	rep #$20
	phx
	txa
	xba				// x * 2048 + 0x500
	asl
	asl
	asl
	adc.w #$500		// add save base
	tay
	sep #$20
	lda.b #({ex_name_save} >> 16)
	plx
	rts
	
// X.16 slot
_Get_dst_ptr:
	rep #$20
	phx
	txa				// x*128 + base
	xba
	lsr
	adc.w #({ex_name_save} & 0xffff)
	tay
	sep #$20
	lda.b #({ex_name_save} >> 16)
	plx
	rts

// Y.16 location
// A.8 bank
_Set_src:
	sty {name_src}
	sta {name_srcb}
	rts

// Y.16 location
// A.8 bank
_Set_dst:
	sty {name_dst}
	sta {name_dstb}
	rts
	
// returns
// A.8 read byte
_Read_src:
	lda [{name_src} + 0x7e0000]
	pha
	rep #$20
	lda {name_src}	// seek forward
	inc
	sta {name_src}
	sep #$20
	pla
	rts

// parameters
// A.8 byte to write
_Write_dst:
	pha
	sta [{name_dst} + 0x7e0000]
	rep #$20
	lda {name_dst}	// seek forward
	inc
	sta {name_dst}
	sep #$20
	pla
	rts

Load_names:
	mvn $70, $0			// original code
	jsr _Load_names
	rtl

_Load_names:
	php
	rep #$20			// A.16
	lda $1A3C			// get slot to be loaded (0 = none, 1 = first slot)
	dec
	and.w #$00ff		// slot id * 128
	xba
	lsr
	clc
	adc.w #({ex_name_save} & 0xffff)
	tax									// src pointer
	ldy.w #({ex_name_data} & 0xffff)	// dst pointer
	lda #127			// size -1
	mvn {ex_name_save} >> 16, {ex_name_data} >> 16	// destination, source
	plp
	rts

Save_names:
	mvn $7e, $70		// original code
	jsr _Save_names
	rtl

_Save_names:
	php
	lda $1A3C			// get slot to be saved (0 = none, 1 = first slot)
	dec
	rep #$20			// A.16
	and.w #$00ff		// slot id * 128
	xba
	lsr
	clc
	adc.w #({ex_name_save} & 0xffff)
	tay								// dst pointer
	ldx #({ex_name_data} & 0xffff)	// src pointer
	lda #127			// size -1
	mvn {ex_name_data} >> 16, {ex_name_save} >> 16	// destination, source
	plp
	rts
	
Backup_names:
	lda #112-1			// size of backup names
	ldx #({ex_name_data} & 0xffff)	// src pointer
	ldy	#({ex_name_temp} & 0xffff)	// dst pointer
	mvn {ex_name_temp} >> 16, {ex_name_data} >> 16	// destination, source
	rts

Restore_names:
	lda #112-1			// size of backup names
	ldx	#({ex_name_temp} & 0xffff)	// src pointer
	ldy #({ex_name_data} & 0xffff)	// dst pointer
	mvn {ex_name_data} >> 16, {ex_name_temp} >> 16	// destination, source
	rts

// paramters:
// A.8 ID to decode into name
// X.16 slot
// Y.16 where to write
define tax8_16	"sta $43; ldx $43"
St_pl_tmap_write:
	and.b #$3f		// check if it's a valid value
	beq +			// 0 = empty slot, do not print
	stx $45			// preserve slot number
	dec
	{tax8_16}
	rep #$20
	tya
	clc
	adc $29
	tay

	lda.w #6		// max tiles to write
	sta $43
	ldx $45			// reload slot index
	lda .pl_tmap_tbl,x
	sep #$20		// A.8
	sta $45
-
	lda $45
	sta 64,y
	inc $45			// tile index++
	lda 65,y
	ora.b #2		// make it access upper tiles
	sta 65,y
	iny
	iny
	dec $43
	bne -
+
	rts
	
.pl_tmap_tbl:
	db $E0, $E6, $EC, $F2, $F8

// parameters
// A.16 seek
// returns X for St_pl_tmap_write
St_pl_from_seek:
	lsr			// (a >> 6) & 7
	lsr
	lsr
	lsr
	lsr
	lsr
	and.w #7
	tax
	rts

// for main panel and item panel
_St_pl_tmap_panel:
	php
	pha
	phy
	// convert seek to slot
	rep #$20
	lda $48		// load seek
	jsr St_pl_from_seek
	// original code
	sep #$20
	ply
	pla
	jsr St_pl_tmap_write
	plp
	rtl
	
// for status, equip, and partially namingway
_St_pl_tmap_status:
	php
	pha
	phy
	// convert seek to slot
	rep #$20
	lda $60		// load seek
	jsr St_pl_from_seek
	// original code
	sep #$20
	ply
	pla
	jsr St_pl_tmap_write
	plp
	rtl
	
// for pad selector
_St_pl_tmap_controller:
	php
	pha
	phy
	// convert seek to slot
	rep #$20
	txa		// load seek
	jsr St_pl_from_seek
	// original code
	sep #$20
	ply
	pla
	jsr St_pl_tmap_write
	plp
	rtl
	
//////////////////////////////////////
// DIRTY FIXES						//
//////////////////////////////////////
St_fix_win_resize:		// comes from $18687
-
	sta $0000,x
	xba
	lda $0001,x
	and.b #$fc
	sta $0001,x
	xba
	inx
	inx
	dec $1D
	bne -
	rtl

//////////////////////////////////////
// MODE 7 EXTENDED CODE				//
//////////////////////////////////////
Mode7_trans_prophecy:
	ldx.w #0
-
	lda prophecy_gfx,x
	pha
	and.b #$0f
	sta $2119
	pla
	and.b #$f0
	beq +
	lsr
	lsr
	lsr
	lsr
+
	sta $2119
	inx
	cpx.w #$2000
	bne -
	rtl
	
Mode7_trans_font:
	ldx.w #0
-
	lda font_staff,x
		pha
	and.b #$0f
	sta $2119
	pla
	and.b #$f0
	beq +
	lsr
	lsr
	lsr
	lsr
+
	sta $2119
	inx
	cpx.w #$1A00
	bne -
	rtl
