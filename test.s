St_DMA_canvas:
	php
	rep #$20		// a.16
	lda.w #4		// 128 tiles * 4 = 512 tiles
	sta $43

	// source is the canvas in sram
	lda #0
	sta {dma_srcl}
	lda #$71
	sta {dma_srch}
	lda #(128*16)		// always transfer 128 tiles
	sta {dma_size}
	lda #($4800 / 2)	// upper vram region with font
	sta {dma_dst}
-
	jsr St_ex_wait_NMI
	jsr St_DMA0_trans_x
	dec $43
	beq +
	// increase source
	lda {dma_srcl}
	clc
	adc #(128*16)
	sta {dma_srcl}
	// incrase destination
	lda {dma_dst}
	clc
	adc #(128*16/2)
	sta {dma_dst}

	dec $43
	bra -
+
	plp
	rts