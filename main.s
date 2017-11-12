arch snes.cpu; lorom

org $FFD8
	db 4	// change sram size

org $18CC9
	ldx.w #(font_bin & 0xffff)
org $18CCE
	lda.b #(font_bin >> 16)
org $18CD2
	ldx.w #(4096)

incsrc def.s
incsrc ex.s

tmap_equip_start:
	dw $278, $280
	dw $288, $290
	dw $000, $298	// entry 4 is never used

incsrc item.s
//incsrc dma.s

org $3fffff
	db 0

	