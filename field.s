

org $00B533	// hack expanded names
	asl
	asl
	asl
	sta $18
	stz $19
	ldx $18
	ldy $3D
	stz $7
-
	lda {ex_name_data},x
	cmp.b #$ff
	beq .endname
	sta $774,y
	lda.b #$ff
	sta $834,y
	iny
	inx
	inc $7
	lda $7
	cmp.b #8
	bne -
	bra .endname
warnpc $00B565
org $00B565
.endname:

// replace font for dialog with reduced set
org $8468
	ldx.w #512						// size
org $846D
	lda.b #(Fld_font8_dlg >> 16)	// font bank
org $8471
	ldx.w #(Fld_font8_dlg & 0xffff)	// font pointer

Flg_yesno_prompt:
// hack Yes / No prompt to follow new tile specification
org $AE42
	lda.b #$14		// was $14
org $AE47
	lda.b #$09		// was $ff
org $AE5B
	lda.b #$14		// was $14
org $AE60
	lda.b #$09		// was $ff

// fix numbers with new font tile order
org $15C329
	ldy.w #$A		// starting index for conversion of '0', was $80
org $AD98
	cmp.b #$A		// leading zero check, was $80
org $ADA5
	lda.b #$09		// new blank tile value, was $FF

// fix name location rendering
org $B97E
	ldx.w #$2004
org $B984
	ldx.w #$2009
org $B9A4
	ldx.w #$2009
org $B9AA
	ldx.w #$2005
org $B9B6
	ldx.w #$2004
org $B9BC
	ldx.w #$2009
org $B9DC
	ldx.w #$2009
org $B9E2
	ldx.w #$2005
	
org $14F5F6
// Gil dialog
	dw $2001,$2002,$2002,$2002,$2002,$2002,$2002,$2002,$2002,$2002,$2002,$2003
	dw $2004,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2005
	dw $2004,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$201E,$201F,$2005	// Gil
	dw $2006,$2007,$2007,$2007,$2007,$2007,$2007,$2007,$2007,$2007,$2007,$2008
// Yes / no prompt
	dw $2001,$2002,$2002,$2002,$2002,$2002,$2002,$2003
	dw $2004,$2009,$2009,$2009,$2009,$2009,$2009,$2005
	dw $2004,$2009,$2014,$2016,$2017,$2009,$2009,$2005	// >Yes
	dw $2004,$2009,$2009,$2018,$2019,$2009,$2009,$2005
	dw $2004,$2009,$2009,$201A,$201B,$2009,$2009,$2005	//  No
	dw $2004,$2009,$2009,$201C,$201D,$2009,$2009,$2005
	dw $2006,$2007,$2007,$2007,$2007,$2007,$2007,$2008
// clear stripes
	dw $0,$0,$0,$0,$0,$0,$0,$0
// dialog window, top stripe
	dw $2000,$2000,$2001,$2002,$2002,$2002,$2002,$2002,$2002,$2002,$2002,$2002,$2002,$2002,$2002,$2002
	dw $2002,$2002,$2002,$2002,$2002,$2002,$2002,$2002,$2002,$2002,$2002,$2002,$2002,$2003,$2000,$2000
// dialog window, bottom stripe
	dw $2000,$2000,$2006,$2007,$2007,$2007,$2007,$2007,$2007,$2007,$2007,$2007,$2007,$2007,$2007,$2007
	dw $2007,$2007,$2007,$2007,$2007,$2007,$2007,$2007,$2007,$2007,$2007,$2007,$2007,$2008,$2000,$2000
// dialog window, middle stripe
	dw $2000,$2000,$2004,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009
	dw $2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2009,$2005,$2000,$2000
// place window, top stripe
	dw $2001,$2002,$2002,$2002,$2002,$2002,$2002,$2002,$2002,$2002,$2002,$2002,$2002,$2002,$2002,$2003
// place window, bottom stripe
	dw $2006,$2007,$2007,$2007,$2007,$2007,$2007,$2007,$2007,$2007,$2007,$2007,$2007,$2007,$2007,$2008

