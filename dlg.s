define dlg_read_ptr	$72			// used only when expanding dialog to buffer
define dlg_seek		$778		// used to parse all pages of dialog
define vwf_draw_x	$77A		// canvas x
define vwf_draw_y	$77C		// canvas y
define vwf_seek		$77E		// where to write on canvas
define vwf_temp_0	$780		// write here whatever temp value
define vwf_temp_1	$782		// same as above
define vwf_line		$784		// number of scanlines to render
define vwf_tile		$786		//
define vwf_draw_x2	$788		// copy x value
define vwf_dma_srcl	$78A
define vwf_dma_srch	$78C
define vwf_dma_dst	$78E
define vwf_dma_size	$790
define vwf_jmp_x	$792		// jumptable index
define dlg_buffer	$704000		// where expanded dialog is stored
define vwf_canvas	$7ee600		// canvas for proportional rendering
define w_spc		4			// width of a space (it's not in the width table)
	
//////////////////////////////
// CODE FOR NMI				//
//////////////////////////////
Fld_DMA_trans:
	php
	phb
	sep #$20				// A.8
	lda.b #0				// bank = 0
	pha
	plb
	lda.b #$80
	sta $2115
	lda.b #0
	sta $420c
	ldx {vwf_dma_dst}		// destination
	stx $2116
	lda.b #1
	sta $4300
	lda.b #$18				// vram port
	sta $4301
	ldx {vwf_dma_srcl}	// source pointer
	stx $4302
	lda {vwf_dma_srch}	// source bank
	sta $4304
	ldx {vwf_dma_size}	// size
	stx $4305
	lda.b #1
	sta $420b				// enable transfer
	plb
	plp
	rts
	
Fld_dlg_trans_tmap:
	php
	rep #$20						// A.16
	lda.w #(dlg_tmap_tbl & 0xffff)	// source pointer
	sta {vwf_dma_srcl}
	lda.w #(dlg_tmap_tbl >> 16)		// source bank
	sta {vwf_dma_srch}
	lda.w #$2C00					// destination
	sta {vwf_dma_dst}
	lda.w #(32*9*2)					// size
	sta {vwf_dma_size}
	jsr Fld_DMA_trans
	plp
	rtl
	
Fld_dlg_trans_canvas:
	php
	rep #$20						// A.16
	lda.w #({vwf_canvas} & 0xffff)	// source pointer
	sta {vwf_dma_srcl}
	lda.w #({vwf_canvas} >> 16)		// source bank
	sta {vwf_dma_srch}
	lda.w #$2100					// destination
	sta {vwf_dma_dst}
	lda.w #(24*7*16)				// size
	sta {vwf_dma_size}
	jsr Fld_DMA_trans
	plp
	rtl

Fld_prolog_dma:

//////////////////////////////
// STRING HANDLING			//
//////////////////////////////
Fld_dlg_page0:
	stz {dlg_seek}
	stz {dlg_seek}+1
	jsr Fld_expand_dialog		// copy dialog to buffer
Fld_dlg_pages:
	jsr Fld_vwf_clear_canvas
	jsr Fld_parse_dialog		// do the actual rendering
	jsr Fld_vwf_flip_canvas
	// wait next nmi
	lda.b #1
	sta $7d
-
	lda $7d
	bne -
	inc $7d
	// enable canvas transfer
	lda.b #1
	sta $ed
	rtl

Fld_ptr_bank1_0:
	php
	rep #$20
	lda $B2
	and.w #$00ff
	sta $3D			// index * 3
	asl
	adc $3D
	tax
	sep #$20
	lda dialog_ptr1+0,x
	sta {dlg_read_ptr}+0x700
	lda dialog_ptr1+1,x
	sta {dlg_read_ptr}+0x701
	lda dialog_ptr1+2,x
	sta {dlg_read_ptr}+0x702
	plp
	rtl
	
Fld_ptr_bank1_1:
	php
	rep #$20
	lda $B2
	and.w #$00ff
	sta $3D			// index * 3
	asl
	adc $3D
	tax
	sep #$20
	lda dialog_ptr1+768,x
	sta {dlg_read_ptr}+0x700
	lda dialog_ptr1+769,x
	sta {dlg_read_ptr}+0x701
	lda dialog_ptr1+770,x
	sta {dlg_read_ptr}+0x702
	plp
	rtl

Fld_ptr_bank2:
	php
	ldx $3D
	rep #$20
	lda dialog_pptr2,x
	sta {vwf_temp_1}	// store local pointer
	lda $B2				// get index
	and.w #$00ff
	sta {vwf_temp_0}	// index * 3
	asl
	adc {vwf_temp_0}
	adc {vwf_temp_1}
	tax
	sep #$20
	lda dialog_ptr2+0,x
	sta {dlg_read_ptr}+0x700
	lda dialog_ptr2+1,x
	sta {dlg_read_ptr}+0x701
	lda dialog_ptr2+2,x
	sta {dlg_read_ptr}+0x702
	plp
	rtl

Fld_ptr_bank3:
	php
	rep #$20
	lda $B2
	and.w #$00ff
	sta $3D			// index * 3
	asl
	adc $3D
	tax
	lda dialog_ptr3+0,x
	sta {dlg_read_ptr}+0x700
	lda dialog_ptr3+1,x
	sta {dlg_read_ptr}+0x701
	lda dialog_ptr3+2,x
	sta {dlg_read_ptr}+0x702
	plp
	rtl
	
Fld_parse_dialog:
	php
	sep #$20			// A.8
	ldx {dlg_seek}		// load any previous seek
	stz {vwf_draw_x}
	stz {vwf_draw_x}+1
	stz {vwf_draw_y}
	stz {vwf_draw_y}+1
-
	lda {dlg_buffer},x
	inx
	cmp.b #0			// end
	bne +
	// treat end
	lda.b #1			// send signal that this is the last window
	sta $DE
	bra .end
+
	cmp.b #1			// line break
	bne +
	// treat line break
	jsr Fld_vwf_carry_line
	// check if we're above 4 lines of text
	lda {vwf_draw_y}
	cmp.b #56
	bcc -				// below 4 lines, keep going
	bra .end
+
	cmp.b #9			// new page
	bne +
	stz {vwf_draw_x}
	stz {vwf_draw_x}+1
	stz {vwf_draw_y}
	stz {vwf_draw_y}+1
	bra .end
+
	cmp.b #3			// music
	bne +
	lda {dlg_buffer},x
	inx
	sta $1e01
	lda.b #1
	sta $1e00
	jsl $48004
	bra -
+
	jsr Fld_vwf_draw_char
	bra -
.end:
	stx {dlg_seek}		// store current seek
	plp
	rts
	
.write:
.read:

//org $00B45B
// expands dialog to a buffer
Fld_expand_dialog:
// macros
define .write_ptr	$75
define .buffer		$774
// code
	phd
	// replace direct page
	rep #$20
	lda.w #$0700
	tcd
	sep #$20
	// setup write buffer
	ldx.w #({dlg_buffer} & 0xffff)
	stx {.write_ptr}+0x700
	lda.b #({dlg_buffer} >> 16)
	sta {.write_ptr}+0x702
.loop:
	jsr .read
	cmp.b #9
	bcs .char
	tay						// backup read character
	rep #$20
	and.w #$00ff
	asl
	tax
	sep #$20
	tya						// restore character
	jmp (.jmp_tbl,x)
.line:		// 01
.auto:		// 06
.page:		// 09
.char:		// 0a-ff
	jsr .write
	jmp .loop
.align:		// 02
.music:		// 03
.pause:		// 05
	jsr .write
	jsr .read
	jsr .write
	jmp .loop
.name:		// 04, expand name
	jsr .read
	asl
	asl
	asl
	sta $618
	stz $619
	ldx $618
	ldy $63D
	stz $607
-
	lda {ex_name_data},x
	cmp.b #$ff				// premature end of the string
	beq .loop
	jsr .write
	inx
	inc $607
	lda $607
	cmp.b #8				// max size of a name
	bne -
	bra .loop
.item:		// 7, expand item	
	lda $8FB				// item id
	rep #$20
	and.w #$00ff
	asl
	tax
	lda .item_txt_data,x	// load item pointer
	inc						// skip icon
	tax
	sep #$20
-
	lda .item_txt_data,x	// load character from item
	beq +					// end of string
	jsr .write				// write character read
	inx
	bra -
+
	jmp .loop
.var:		// 8, expand variable
	lda $8f8
	sta $630
	lda $8f9
	sta $631
	lda $8fa
	sta $632
	jsr Fld_format_number_ex
	ldx.w #0
-
	lda $636,x
	cmp.b #$80				// '0'
	bne +
	inx
	cpx.w #5
	beq +
	jmp -
+
-
	lda $636,x
	jsr .write
	inx
	cpx.w #6
	bne -
	jmp .loop
.end:		// 0
	jsr .write
	pld						// restore dpage
	rts

.item_txt_data:
	incbin "item.bin"
	
.jmp_tbl:
dw .end,  .line,  .align, .music
dw .name, .pause, .auto,  .item
dw .var,  .page

.read:
	lda [{dlg_read_ptr}]
	jsr .increase
	rts
	
.write:
	pha
	sta [{.write_ptr}]
	rep #$20
	inc {.write_ptr}
	sep #$20
	pla
	rts
	
.increase:
	pha
	rep #$20
	lda {dlg_read_ptr}
	inc
	sta {dlg_read_ptr}
	bit #$8000
	bne +
	lda.w #$8000			// reset to bank start
	sta {dlg_read_ptr}
	sep #$20
	inc {dlg_read_ptr}+2	// next bank
+
	sep #$20
	pla
	rts

//////////////////////////////
// PROPORTIONAL RENDERING	//
//////////////////////////////

// parameters:
// A.8 character to print
Fld_vwf_draw_char:
	php
	phx
	phy
	pha
	cmp.b #$40					// check if it's a space
	bne +
	jmp .end					// skip all rendering for spaces
+
	cmp.b #$3F					// check valid range of characters
	bcs +
	cmp.b #$D2
	bcc +
	lda.b #'?'					// replace all unknown characters with '?'
+
	// calculate seek on font
	rep #$20					// A.16
	and.w #$00ff
	sec
	sbc.w #'A'					// align with font order
	sta {vwf_temp_1}			// char * 24
	asl
	clc
	adc {vwf_temp_1}
	asl
	asl
	asl
	sta {vwf_temp_1}
	jsr .calc_seek				// calculate where to write
	lda {vwf_draw_x}			// calculate jump table index
	and.w #$7					// x % 8 * 2
	asl
	sta {vwf_jmp_x}
	lda.w #12*2					// process 12 scanlines (24 planes)
	sta {vwf_line}
	lda {vwf_temp_1}			// reload font seek
	tax
.line:
	lda Fld_font16_dlg,x		// load font plane
	inx							// plane++
	and #$00ff
	beq .skip					// skip empty lines
	xba
	txy							// preserve font seek
	ldx {vwf_jmp_x}
	jmp (.jtbl,x)
.lsr7:
	lsr
.lsr6:
	lsr
.lsr5:
	lsr
.lsr4:
	lsr
.lsr3:
	lsr
.lsr2:
	lsr
.lsr1:
	lsr
.lsr0:
	ldx {vwf_seek}				// load where to write in buffer
	sep #$20					// A.8
	xba							// shifted glyph
	beq +						// skip if empty
	sta {vwf_temp_0}
	lda {vwf_canvas},x			// load previous plane data
	ora {vwf_temp_0}			// combine
	sta {vwf_canvas},x			// store combined plane
+
	xba							// overflow glyph
	beq +						// skip if empty
	sta ({vwf_canvas}+112),x	// write to next tile plane
+
	tyx
.skip:
	rep #$20					// A.16
	inc {vwf_seek}
	dec {vwf_line}
	bne .line
.end:
	sep #$20
	pla
	jsr Fld_vwf_get_char_w		// x += width
	clc
	adc {vwf_draw_x}
	sta {vwf_draw_x}
	ply
	plx
	plp
	rts
.jtbl:
	dw .lsr0, .lsr1, .lsr2, .lsr3, .lsr4, .lsr5, .lsr6, .lsr7	

// calculates seek on canvas
.calc_seek:
	pha
	php
	rep #$20
	lda {vwf_draw_y}	// y * 2 + (x >> 3) * 7 * 16
	asl
	sta {vwf_seek}
	lda {vwf_draw_x}
	lsr
	lsr
	lsr
	sta {vwf_temp_0}
	asl
	adc {vwf_temp_0}
	asl
	adc {vwf_temp_0}
	asl
	asl
	asl
	asl
	adc {vwf_seek}
	sta {vwf_seek}
	plp
	pla
	rts
	
// returns width of a character
// parameters:
// A.8 character to retrieve
// returns
// A.8 width of character
Fld_vwf_get_char_w:
	phx
	cmp.b #$40		// space
	bne .not_space
	lda.b #{w_spc}	// space width
	bra .return
.not_space:
	cmp.b #$3F		// check below defined range
	bcs +
	cmp.b #$D2		// check above defined range
	bcc +
	lda.b #'?'		// replace with valid character
+
	sec
	sbc.b #'A'		// use 0x42-0xff range
	tax
	lda font16_wtbl,x
+
.return:
	plx
	rts

// clear render canvas
Fld_vwf_clear_canvas:
	php
	rep #$20
	ldx.w #0
	lda.w #0				// clear value
-
	sta {vwf_canvas},x
	inx
	inx
	cpx.w #(24*7*16)		// if (x < sizeof(canvas))
	bne -
	plp
	rts

// fixes bits to render canvas
Fld_vwf_flip_canvas:
	php
	rep #$20
	ldx.w #0
-
	lda {vwf_canvas},x
	eor.w #$00ff
	sta {vwf_canvas},x
	inx
	inx
	cpx.w #(24*7*16)		// if (x < sizeof(canvas))
	bne -
	plp
	rts

Fld_vwf_carry_line:
	stz {vwf_draw_x}	// x = 0
	stz {vwf_draw_x}+1
	lda {vwf_draw_y}	// y += 14
	adc.b #14
	sta {vwf_draw_y}
	rts
	
Fld_format_dlg:
	ldx.w #0
	stx {vwf_draw_x}
-
	lda {dlg_buffer},x
	inx
	cmp.b #0			// end of string
	beq .end
	cmp.b #$40			// space
	bne .ck_line
	// is space, do prediction stuff
	jsr Fld_width_next
	cmp.b #1
	beq .line			// returned 1, it's a line carry now
	lda #{w_spc}		// load space width
	bra .space
.ck_line:
	cmp.b #1			// new line
	bne .ck_align
	// is line, reset x
.line:
	stz {vwf_draw_x}
	stz {vwf_draw_x}+1
	bra -
.ck_align:
	cmp.b #2			// align
	bne .char
	inx					// skip aligner
.char:
	txy
	tax
	lda font16_wtbl,x	// load width to add
	tyx
.space:
	adc {vwf_draw_x}
	sta {vwf_draw_x}	// x+=read
	bra -
.end:
	rts

// parameters
// X.16 seek of last read
Fld_width_next:
	phx
	rep #$20
	lda {vwf_draw_x}		// make temp copy of calculated width
	adc #{w_spc}			// add current space to temp width
	sta {vwf_draw_x2}
	sep #$20
-
	lda {dlg_buffer},x
	inx
	cmp.b #$40				// we hit another space, perform check
	beq +
	cmp.b #0				// hit end of dialog, perform check
	beq +
	cmp.b #1				// hit a line break, perform check
	beq +
	cmp.b #9				// hit a new page
	beq +
+
	txy						// save x
	tax
	lda font16_wtbl,x		// load character width
	rep #$20
	and.w #$00ff
	adc {vwf_draw_x2}		// add to current x
	sta {vwf_draw_x2}
	sep #$20
	tyx		// restore x
	bra -
+
	plx						// restore original seek
	ldy {vwf_draw_x2}
	cpy.w #(24*8)			// max allowed width on a line
	bcc .ret0 				// jump if x < 24 * 8
	// replace space with line carry
	lda.b #1				// line carry value and return 1
	sta ({dlg_buffer}-1),x
	bra .ret1
.ret0:
	lda.b #0				// return 0 if this space stays a space
.ret1:
	rts
	
//////////////////////////////
// HELPERS					//
//////////////////////////////
Fld_format_number_ex:
	phx
	phy
	ldx.w #0
.loop:
	ldy.w #$80		// '0'
	stz $633
.next:
	rep #$20
	lda $630
	sec
	sbc $15C36F,x
	sta $630
	lda $632
	sbc $15C37F,x
	sta $632
	bcc +
	iny
	jmp .next
+
	lda $630
	clc
	adc $15C36F,x
	sta $630
	lda $632
	adc $15C37F,x
	sta $632
	lda.w #0
	sep #$20
	phx
	txa
	lsr
	tax
	tya
	sta $632,x
	plx
	inx
	inx
	cpx.w #$10
	bne .loop
	ply
	plx
	rts

//////////////////////////////
// DATA BLOCK				//
//////////////////////////////
font16_wtbl:
//	A B C D E F G H I J K L M N O P
db	5,5,5,5,5,5,5,6,4,5,6,5,6,6,5,5
//	Q R S T U V W X Y Z a b c d e f
db	5,5,5,6,6,6,6,6,6,6,5,5,5,5,5,4
//	g h i j k l m n o p q r s t u v
db	5,5,2,3,5,2,6,5,5,5,5,5,5,4,5,5
//	w x y z & # + ( ) woxzxaxuxo0 1
db	6,6,5,5,6,6,6,4,4,5,5,5,5,5,5,4
//  2 3 4 5 6 7 8 9 à è é ì ò ö ù ü
db	5,5,5,5,5,5,5,5,5,5,5,3,5,5,5,5
//	À È É Ì Ò Ù ~ = titutetonaninune
db	5,5,5,5,5,6,8,6,8,8,8,8,8,8,8,8
//	nohahihuhehomamimumemoyayuyorari
db	8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8
//	rurerowan XAXI" XEXOXZXAXUXO, .
db	8,8,8,8,8,8,8,4,8,8,8,8,8,8,3,2
//	- _ ! ? % / : ' A I U E O KAKIKU
db	5,6,2,6,7,5,2,2,8,8,8,8,8,8,8,8

// tilemap used for regular dialog
dlg_tmap_tbl:
dw $2000,$2000,$2004,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2005,$2000,$2000
dw $2000,$2000,$2004,$2009,$2020,$2027,$202E,$2035,$203C,$2043,$204A,$2051,$2058,$205F,$2066,$206D,$2074,$207B,$2082,$2089,$2090,$2097,$209E,$20A5,$20AC,$20B3,$20BA,$20C1,$2009,$2005,$2000,$2000
dw $2000,$2000,$2004,$2009,$2021,$2028,$202F,$2036,$203D,$2044,$204B,$2052,$2059,$2060,$2067,$206E,$2075,$207C,$2083,$208A,$2091,$2098,$209F,$20A6,$20AD,$20B4,$20BB,$20C2,$2009,$2005,$2000,$2000
dw $2000,$2000,$2004,$2009,$2022,$2029,$2030,$2037,$203E,$2045,$204C,$2053,$205A,$2061,$2068,$206F,$2076,$207D,$2084,$208B,$2092,$2099,$20A0,$20A7,$20AE,$20B5,$20BC,$20C3,$2009,$2005,$2000,$2000
dw $2000,$2000,$2004,$2009,$2023,$202A,$2031,$2038,$203F,$2046,$204D,$2054,$205B,$2062,$2069,$2070,$2077,$207E,$2085,$208C,$2093,$209A,$20A1,$20A8,$20AF,$20B6,$20BD,$20C4,$2009,$2005,$2000,$2000
dw $2000,$2000,$2004,$2009,$2024,$202B,$2032,$2039,$2040,$2047,$204E,$2055,$205C,$2063,$206A,$2071,$2078,$207F,$2086,$208D,$2094,$209B,$20A2,$20A9,$20B0,$20B7,$20BE,$20C5,$2009,$2005,$2000,$2000
dw $2000,$2000,$2004,$2009,$2025,$202C,$2033,$203A,$2041,$2048,$204F,$2056,$205D,$2064,$206B,$2072,$2079,$2080,$2087,$208E,$2095,$209C,$20A3,$20AA,$20B1,$20B8,$20BF,$20C6,$2009,$2005,$2000,$2000
dw $2000,$2000,$2004,$2009,$2026,$202D,$2034,$203B,$2042,$2049,$2050,$2057,$205E,$2065,$206C,$2073,$207A,$2081,$2088,$208F,$2096,$209D,$20A4,$20AB,$20B2,$20B9,$20C0,$20C7,$2009,$2005,$2000,$2000
dw $2000,$2000,$2004,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2005,$2000,$2000

// tilemap used for rendering location names
loc_tmap_tbl:
dw $2020,$2022,$2024,$2026,$2028,$202A,$202C,$202E,$2030,$2032,$2034,$2036
dw $2021,$2023,$2025,$2027,$2029,$202B,$202D,$202F,$2031,$2033,$2035,$2037

// tilemap used for scrolling dialog (i.e. prologue)
prol_tmap_tbl0:
dw $2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009
dw $2020,$2021,$2022,$2023,$2024,$2025,$2026,$2027,$2028,$2029,$202A,$202B,$202C,$202D,$202E,$202F,$2030,$2031,$2032,$2033,$2034,$2035,$2036,$2037
dw $2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009
dw $2038,$2039,$203A,$203B,$203C,$203D,$203E,$203F,$2040,$2041,$2042,$2043,$2044,$2045,$2046,$2047,$2048,$2049,$204A,$204B,$204C,$204D,$204E,$204F
dw $2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009
dw $2040,$2041,$2042,$2043,$2044,$2045,$2046,$2047,$2048,$2049,$204A,$204B,$204C,$204D,$204E,$204F,$2050,$2051,$2052,$2053,$2054,$2055,$2056,$2057
dw $2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009
dw $2058,$2059,$205A,$205B,$205C,$205D,$205E,$205F,$2050,$2051,$2052,$2053,$2054,$2055,$2056,$2057,$2058,$2059,$205A,$205B,$205C,$205D,$205E,$205F
prol_tmap_tbl1: