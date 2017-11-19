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
// TEST					//
//////////////////////////
org $18000
	jsr $1802C	// status
	//jsr $1D792	// treasure
