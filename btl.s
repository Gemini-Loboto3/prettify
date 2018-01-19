org $02907C
	rep #$20						// A.16
	lda.w #1184						// size of transfer
	sta $0e
	sep #$20						// A.8
	ldx.w #(btl_gfx_bg2 & 0xffff)	// source pointer
	lda.b #(btl_gfx_bg2 >> 16)		// src bank
	ldy.w #$4db0					// vram dest
	jsr $2869A						// Btl_DMA4_trans
	rts

org $0382F0
	lda.b #44						// move tile base of BG3-4 to $4000 instead of $5000, was 55
	
org $02975D							// MP needed
	db $de,$df,$e0,$e1,$e2,$e3,$ff

org $029AB7
	db $ff,$ff,$ff,$ff				// Defend
	db $e8,$e9,$ea,$eb
	db $ff,$ff,$ff,$ff				// Change
	db $e4,$e5,$e6,$e7

org $029B91							// remap window tiles
	db $a7,$a8,$a9
	db $aa,$a6,$ab
	db $ac,$ad,$ae
	db $f7,$f8,$f9					// defend / change
	db $fa,$ff,$fb
	db $fc,$fd,$fe
	db $af,$b0,$b1
	db $aa,$a6,$ab
	db $ac,$ad,$ae
	
org $16FEA8
	db $a6,$d6,$d7,$d8,$a6			// "PAUSE"
	
org $16FED5
	db $ff,$ff,$ff,$ff,$ff
	db $db,$dc,$dd,$de,$ff			// right hand
	db $ff,$ff,$ff,$ff,$ff
	db $df,$dc,$dd,$de,$ff			// left hand
	db $ff,$ff,$ff,$ff,$ff
	db $db,$dc,$dd,$de,$ff			// right hand
	db $ff,$ff,$ff,$ff,$ff
	db $df,$dc,$dd,$de,$ff			// left hand
	db $ff,$ff,$ff,$ff,$ff
	db $db,$dc,$dd,$de,$ff			// right hand
	db $ff,$ff,$ff,$ff,$ff
	db $df,$dc,$dd,$de,$ff			// left hand
	
// replace font upload
org $029137
	ldx.w #4608						// size
	stx $00
	lda.b #(btl_font >> 16)			// source
	ldx.w #(btl_font & 0xffff)
	ldy.w #$4500					// destination
	
org $02FFC1
Btl_write_tmap:
	jsl jBtl_write_tmap
	rts

warnpc $030000
