Btl_write_name:
Btl_write_magic0:
Btl_write_magic1:
Btl_write_item:

Btl_trans_name:
Btl_trans_magic0:
Btl_trans_magic1:
Btl_trans_item:

jBtl_write_tmap:
	lda $ef55
	sta $36
	asl $ef54
	ldx $ef50
	stx $30
	ldx $ef52
	stx $32
	lda $32
	clc
	adc $ef54
	sta $34
	lda $33
	adc.b #0
	sta $35
	ldy.w #0
-
	-
	rtl
	
//	db

btl_gfx_bg2:
	incbin "btl_bg2.sfc"
btl_font:
	incbin "btl_font.sfc"
