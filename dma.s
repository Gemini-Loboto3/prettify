
define list_base	0
define list			2


DMA_trans_reset:
	PHP
	REP #$30

	STA ($0)
	STA ($2),y
	
	PLP
	RTL

// A.16 = vram tile base
// X.16 = 
// Y.16 = 
DMA_push_trans_item:
	PHP
	PHA
	PHX
	
	LDA #$01
	//ADC [list_base]	// list++

	PLX
	PLA
	PLP
	RTL
