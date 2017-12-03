org $1283E0
	//db $FD, $39							// make test staff roll
	//db $F9, $33, $FD, $37, $FD, $37, $FF	// make test prophecy
	db $FA, $2C, $E9, $1C, $FD, $00, $FE	// regular new game

// move prophecy text
org $13D818
	ldx.w #(prophecy_mes & 0xffff)
	stx $7D19
	lda.b #(prophecy_mes >> 16)
// kill nigori in mode7 prophecy screen
org $13EB43
	nop
	nop
	sta ($3C),y
	nop
	nop
	nop
	nop

// change gfx upscale code to support two font sets
org $13D781
	bne +
	lda.b #$40
	sta $4
	jsl Mode7_trans_font
	plb
	rts
+
	jsl Mode7_trans_prophecy
	plb
	rts
	
// font palette
org $13D200
	dw $0000,$7FFF,$001B,$0019,$0421,$4610,$4778	// last 3 entries are empty, so 2 now hold border and shading
