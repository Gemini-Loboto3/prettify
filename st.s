//////////////////////////////////
// JOBS							//
//////////////////////////////////
org $18fd3
	asl			// job id * 8 (makes code easier)
	asl
	asl
	sta $45
	stz $46
	ldx $45
	lda.b #7	// change job size to 7, was 6
	sta $45
	nop
	nop
	nop
	lda tbl_str_jobs,x	// relocate job strings

//////////////////////////////////
//								//
//////////////////////////////////
org $18E32
St_char_to_nigori:
	xba
	lda.b #$ff
	rts
St_write_wide3:
	sta $7e0040,x
	lda $7e0041,x
	and.b #$fc
	ora.b #3
	sta $7e0041,x
	rts
// change string copier to accept 3xx ranges
org $18318
___write1:
org $18322
	jsr St_write_wide3
	inx
	inx
	bra ___write1
	jmp $18332

// change literal copier to default to 3xx ranges
org $18798
	rep #$20
	txa
	sec
	sbc #$0040
	tax
	jmp $182CD

// move Gil one tile to the right
org $187D1		// main menu
	ldx.w #$678		// was 676
org $19850		// save menu
	ldx.w #$67A		// was 678
	
// fix config highlighter in 123456789 sequence
org $1D782
	lda.b #7	// was 4
org $1D220
	lda.b #3	// was 0
org $1D22D
	lda.b #3	// was 0
	
// make 'Controller' appear 2 tiles further than player names
org $1D681
	jsr $187B9

// fix magic highlighter for left panel
org $1B3EC
	lda #$27	// was 24
org $1B416
	lda #$23	// was 20
	
// fix highlighter with 'Save' in main menu
org $18939
	lda #$27	// was 24

// fix entry points
org $18048
	jsr St_init_main
org $1C2CD
	jsr St_init_shop
org $1D17D
	jsr St_init_config
org $1D19B
	jsr St_exit_config
org $19606	// boot
	jsr St_init_main
org $1BA2E
	jsr St_init_name
org $197D3
	jsr St_init_load	// when entering load / save screen
org $1CC21
	jsr St_init_load	// when leaving save
org $1D797
	jsr St_init_treasure

// fix a few string pointers
org $1D83D
	ldy.w #(St_mes_getall)
org $1C7E4
	ldy.w #(St_mes_howmany)
	
// fix broken transitions
org $18689	// top
	jsl St_fix_win_resize
	lda.b #$f9
	sta $0000,x
	rts
org $186AC	// bottom
	jsl St_fix_win_resize
	lda.b #$fe
	sta $0000,x
	rts
	
// dig some room from original St_pl_tmap_write
org $183AB
	rts
	
St_pl_tmap_panel:
	jsl _St_pl_tmap_panel
	rts
	
St_pl_tmap_panel_fix0:
	lda $45
	ora.b #2
	sta $45
	lda.b #6
	jsr $18C47
	rts
	
St_pl_tmap_panel_fix1:
	lda $45
	and.b #$fc
	sta $45
	lda.b #14
	jsr $18C47
	rts

St_pl_tmap_status:
	jsl _St_pl_tmap_status
	rts

St_pl_tmap_controller:
	jsl _St_pl_tmap_controller
	rts

St_pl_name_draw:
	jsr $1824C
	jsl _St_trans_namex
	rts
	
// hack new code into player writers
org $189AA	// panel
	jsr St_pl_tmap_panel
org $1A4AD	// panel short
	jsr St_pl_tmap_panel
org $1A4C5	// fix panel short, part 1
	jsr St_pl_tmap_panel_fix0
org $1A4C8	// fix panel short, part 2
	jsr St_pl_tmap_panel_fix1
org $1A8EF	// x learned y
org $1A9BA	// status
	jsr St_pl_tmap_status
org $1BB40	// namingway
	jsr St_pl_tmap_status
org $1BD57	// equip
	jsr St_pl_tmap_status
org $1D679	// pad selector
	jsr St_pl_tmap_controller
	
// hack save routine to backup expanded names
org $19794
	jsr hook_Load_names
org $1CBFB
	jsr hook_Save_names
	
//////////////////////////
// NAMINGWAY			//
//////////////////////////
org $1BBB6	// copy name to buffer
	lda $43
	asl
	asl
	asl
	nop
	nop
	nop
	adc.w #({ex_name_data} & 0xffff)
	tax
	lda.w #8-1	// expanded size, was 5
org $1BBCA
	mvn ({ex_name_data} >> 16), $7e	// source, destination
org $1BBD6	// copy name from buffer
	lda.w #8-1	// expanded size, was 5
	mvn $7e, ({ex_name_data} >> 16)	// source, destination

// St_tmap_pl_namingway
org $19E98
	rep #$20
	lda.w #6	// size in tiles
	sta $43
	lda.w #$22e0
-
	sta $c640,y
	iny
	iny
	inc
	dec $43
	bne -
	ply
	plx
	sep #$20
	jsl _St_name_draw
	rts
warnpc $19EB6
	
org $19BD7
	ldy.w #8	// size to copy into 'restore' buffer
	lda $0000,x
	sta $0008,x	// new buffer for restoration
org $19BFA
	lda.b #1	// initial cursor position (End)
org $19C99
	cmp.b #0	// old ABC value
org $19D14
	cmp.b #8	// max input size, was 6
org $19DF8
	ldy.w #8	// copy-back size, was 6
	lda $0008,x
	sta $0000,x
org $19C87
	jsr St_pl_name_draw
org $19D7B
	cmp.b #1	// End value
org $19DB5
	lda.b #1	// max of ABC / End selector
org $19D6C
	jsr St_pl_name_draw
org $19DD7
	cmp.b #1	// End value
	
org $19E16
	ldx.w #0	// drop katakana
org $19E1B
	ldx.w #0	// drop ABC

org $19F08
	cmp.b #2	// max choices of panel
	
org $19F21
	cpx.w #8	// old size of reset
	
org $19B30
	lda.w #(14 * 8 - 1)
	ldx.w #(pl_name_tables & 0xffff)	// source pointer
	ldy.w #({ex_name_data} & 0xffff)	// dest pointer
	mvn pl_name_tables >> 16, {ex_name_data} >> 16	// source, destination
	
org $1DBBA
St_mes_abc:
	db "ABCDEabcde"
	db "FGHIJfghij"
	db "KLMNOklmno"
	db "PQRSTpqrst"
	db "UVWXYuvwxy"
	db "Z0123z!?%/"
	db "45678:^^^^"
	db "9^^^^^^^^^"
org $1DCAA
	db 77, 189
org $1DCC8
	dw 0, 0, 0	// drop hiragana and katakana pointers
	
//////////////////////////
// TEST					//
//////////////////////////
org $18000
	jsr $1802C	// status
	//jsr $1D792	// treasure
