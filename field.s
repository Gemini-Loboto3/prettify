org $00B533	// hack new names
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
