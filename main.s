arch snes.cpu; lorom
incsrc def.s
incsrc menu_str.s

org $008040
	jsl Boot_names

// backup vram to sram
org $14FF85
	ldx.w #$4000
org $14FF8B
	lda.b #$70
org $14FF90
	ldx.w #$4000
// restore vram from sram
org $14FFE0
	ldx.w #$4000
org $14FFE6
	lda.b #$70
org $14FFEB
	ldx.w #$4000

org $FFD8
	db 5	// change sram size (32KB)

org $18CC9
	ldx.w #(font_bin & 0xffff)
org $18CCE
	lda.b #(font_bin >> 16)
org $18CD2
	ldx.w #(4096)

incsrc ex.s
incsrc dlg.s
incsrc mode7.s

incsrc item.s
incsrc st.s
incsrc field.s

org $3fffff
	db 0

	