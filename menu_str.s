org $01db6d
	dw $002c
	db $07, $11
	dw $0070
	// Item
	db $02, $03, $04, $01
	dw $00f0
	// Magic
	db $05, $06, $07, $01
	dw $0170
	// Equip
	db $08, $09, $0a, $01
	dw $01f0
	// Status
	db $0b, $0c, $0d, $0e, $01
	dw $0270
	// Order
	db $0f, $10, $11, $01
	dw $02f0
	// Row
	db $12, $13, $01
	dw $0370
	// Option
	db $14, $15, $16, $17, $01
	dw $03f0
	// Save
	db $18, $19, $1a, $00
org $01dba7
	// Save
	db $18, $19, $1a, $00
org $01dbab
	dw $00f0
	// Magic
	db $05, $06, $07, $00
org $01dbb2
	// Unconscious
	db $1b, $1c, $1d, $1e, $1f, $20, $0e, $00
org $01dcae
	dw $0246
	// ABC
	db $02, $03, $01
	dw $05c6
	// End
	db $04, $05, $00
org $01dcde
	dw $02d2
	// This isn't necessary.
	db $21, $22, $23, $24, $25, $26, $27, $28, $29, $2a, $2b, $00
org $01dcde
	dw $02d2
	// Nothing happened.
	db $2c, $2d, $2e, $2f, $30, $31, $32, $33, $34, $35, $00
org $01dd00
	dw $0046
	// Item
	db $02, $03, $04, $00
org $01dd14
	dw $0054
	// Use on whom?
	db $36, $37, $38, $39, $3a, $3b, $3c, $3d, $00
org $01dd20
	dw $0054
	// Cannot use here.
	db $3e, $3f, $40, $41, $42, $37, $43, $11, $44, $00
org $01dd2d
	dw $0054
	// Nothing here.
	db $2c, $2d, $2e, $2f, $43, $11, $44, $00
org $01dd40
	dw $0210
	db $0a, $03
	dw $0252
	// Cannot use magic.
	db $3e, $3f, $40, $41, $42, $37, $45, $46, $47, $48, $00
org $01dd79
	dw $0106
	// MP needed
	db $49, $4a, $4b, $34, $4c, $4d, $00
org $01dd82
	dw $0106
	// On whom?  
	db $0f, $4e, $4f, $50, $51, $52, $00
org $01dda9
	dw $0002
	db $1b, $0b
	dw $005c
	// R.Hand
	db $53, $54, $55, $56, $01
	dw $00dc
	// L.Hand
	db $57, $54, $55, $56, $01
	dw $015c
	// Head
	db $58, $59, $4d, $01
	dw $01dc
	// Body
	db $5a, $5b, $5c, $01
	dw $025c
	// Arms
	db $5d, $5e, $5f, $00
org $01ddd9
	dw $0392
	db $0b, $06
	dw $03d4
	// Can only equip
	db $3e, $60, $38, $61, $62, $63, $64, $65, $01
	dw $0458
	// with both hands.
	db $66, $67, $68, $69, $6a, $30, $6b, $6c, $6d, $00
org $01de09
	dw $01f0
	// Status
	db $0b, $0c, $0d, $0e, $00
org $01de11
St_mes_level:
	dw $0114
	// Level
	db $6e, $6f, $70, $01
	dw $01a2
	// Experience
	db $71, $72, $11, $73, $74, $75, $01
St_mes_hp:
	dw $0206
	// HP
	db $76, $3d, $01
St_mes_mp:
	dw $0286
	// MP
	db $49, $77, $01
	dw $0344
	// Ability
	db $78, $79, $7a, $01
	dw $03c6
	// Strength
	db $0b, $7b, $33, $7c, $7d, $01
	dw $0446
	// Speed
	db $7e, $7f, $80, $01
	dw $04c6
	// Stamina
	db $0b, $81, $82, $83, $01
	dw $0546
	// Intellect
	db $84, $85, $86, $87, $88, $01
	dw $05c6
	// Spirit
	db $7e, $89, $8a, $01
	dw $035a
	// Attack
	db $8b, $8c, $8d, $8e, $01
	dw $03da
	// Accuracy
	db $8f, $90, $91, $92, $93, $01
	dw $045a
	// Defense
	db $94, $95, $96, $97, $98, $01
	dw $04da
	// Evasion
	db $99, $9a, $9b, $9c, $01
	dw $055a
	// Magic defense
	db $05, $06, $07, $9d, $9e, $9f, $a0, $a1, $01
	dw $05da
	// Magic evasion
	db $05, $06, $07, $a2, $a3, $a4, $16, $17, $01
	dw $036e
	// x
	db $a5, $01
	dw $046e
	// x
	db $a5, $01
	dw $056e
	// x
	db $a5, $00
org $01de98
	dw $0262
	// To next level
	db $a6, $a7, $4b, $a8, $a9, $aa, $ab, $00
org $01debe
	// Weapon
	db $02, $03, $04, $05, $00
org $01dec3
	// Armor
	db $06, $07, $08, $09, $00
org $01dec8
	// Items
	db $0a, $0b, $0c, $00
org $01decd
	dw $0054
	// Welcome! How can I help?
	db $02, $0d, $0e, $0f, $10, $11, $12, $13, $14, $15, $16, $17, $18, $01
	dw $0148
	// Buy         Sell        Exit
	db $19, $1a, $1b, $1b, $1b, $1c, $1d, $1b, $1b, $1b, $1e, $1f, $00
org $01def1
	dw $0054
	// What would you like?
	db $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $2a, $01
St_mes_howmany:
	dw $0146
	// How many?    1
	db $2b, $2c, $2d, $2e, $2f, $30, $1b, $31, $00
org $01df0a
	dw $0176
	// Gil
	db $fe, $00
org $01df0f
	dw $0282
	db $14, $04
	dw $02c4
	// Your don't have any more
	db $32, $27, $33, $34, $35, $36, $37, $38, $39, $14, $3a, $3b, $3c, $3d, $01
	dw $0344
	// room for buying anything.
	db $3e, $3f, $40, $41, $42, $43, $44, $45, $46, $47, $48, $49, $4a, $4b, $00
org $01df3b
	dw $028a
	db $10, $04
	dw $02cc
	// You don't have enough money.
	db $32, $27, $4c, $08, $4d, $16, $4e, $4f, $50, $51, $52, $53, $2d, $54, $55, $56, $00
org $01df61
	dw $028a
	db $0b, $02
	dw $02cc
	// Thanks!
	db $57, $21, $58, $59, $00
org $01df73
	dw $0292
	db $0b, $0d
	dw $035a
	//  of this makes
	db $5a, $5b, $5c, $5d, $2d, $5e, $5f, $60, $01
	dw $03e4
	//  Gil.
	db $61, $62, $01
	dw $0454
	// Is this deal okay for
	db $63, $64, $65, $66, $67, $68, $5a, $69, $6a, $6b, $3c, $01
	dw $04d4
	// you?
	db $6c, $6d, $6e, $01
	dw $0558
	// Yes      No
	db $6f, $70, $1b, $1b, $71, $72, $00
org $01dfa7
	dw $0054
	// What are you selling?   
	db $20, $21, $73, $74, $3d, $26, $27, $75, $76, $45, $77, $78, $1b, $00
org $01dfc9
	dw $0046
	// New Game
	db $ac, $ad, $ae, $af, $4b, $00
org $01dfe8
	dw $006e
	// Load this
	db $b0, $b1, $b2, $b3, $b4, $01
	dw $00ee
	// data?
	db $b5, $b6, $b7, $00
org $01dffa
	dw $0172
	// Yes
	db $b8, $b9, $01
	dw $01f2
	// No
	db $2c, $ba, $00
org $01e005
	dw $046e
	// Time
	db $bb, $bc, $98, $00
org $01e00c
	dw $0090
	// Empty
	db $bd, $be, $7a, $00
org $01e014
	dw $0046
	// Save
	db $18, $19, $1a, $00
org $01e01a
	dw $0046
	// Save aborted.
	db $18, $19, $bf, $c0, $c1, $c2, $80, $48, $00
org $01e02b
	dw $02ee
	// Game saved.
	db $c3, $c4, $a1, $c5, $19, $80, $48, $00
org $01e035
	dw $006e
	// Overwrite
	db $c6, $c7, $c8, $c9, $85, $ca, $01
	dw $00ee
	// this data?
	db $67, $cb, $cc, $cd, $ce, $77, $00
org $01e048
	dw $02f2
	// Cancel
	db $3e, $cf, $d0, $d1, $00
org $01e054
	dw $0142
	db $0d, $01
	dw $004e
	// Wanna change your name?
	db $06, $07, $08, $09, $0a, $0b, $0c, $0d, $0e, $0f, $10, $11, $12, $13, $00
org $01e072
	dw $004e
	// Who needs a new name?
	db $14, $15, $16, $17, $18, $19, $1a, $1b, $1c, $1d, $1e, $1f, $20, $00
org $01e089
	dw $004e
	// Enter a name.
	db $04, $21, $22, $23, $16, $24, $25, $26, $00
org $01e09c
	dw $004e
	// Godspeed.
	db $27, $28, $29, $2a, $2b, $26, $00
org $01e0ac
	// Change      Leave
	db $2c, $11, $2d, $2e, $2f, $2f, $30, $31, $32, $00
org $01e0b7
	dw $004e
	// Is this okay?
	db $33, $34, $35, $36, $37, $38, $39, $00
org $01e0dc
	dw $0184
	db $0c, $02
	dw $008e
	// Fat Chocobo
	db $02, $03, $04, $05, $06, $07, $08, $01
	dw $01c8
	// Deposit   Withdrawl
	db $09, $0a, $0b, $0c, $0d, $0e, $0f, $10, $11, $12, $00
org $01e0f6
	dw $009a
	// Yo! What can I do for ya?
	db $13, $14, $15, $16, $17, $18, $19, $1a, $1b, $1c, $1d, $1e, $1f, $20, $00
org $01e107
	dw $009a
	// That's no place for a whistle.
	db $21, $16, $22, $23, $05, $24, $25, $26, $27, $28, $29, $2a, $2b, $2c, $2d, $2e, $00
org $01e118
	dw $009a
	// What do you have for me?
	db $15, $16, $17, $2f, $30, $31, $32, $16, $33, $34, $1d, $35, $36, $37, $00
org $01e129
	dw $009a
	// What do you need?
	db $15, $16, $17, $2f, $30, $31, $38, $39, $3a, $3b, $00
org $01e13a
	dw $009a
	// I'm stuffed.
	db $3c, $3d, $3e, $3f, $40, $41, $42, $00
org $01e14b
	dw $009a
	// Sort your stuff!
	db $43, $44, $45, $46, $47, $48, $49, $4a, $4b, $00
org $01e15c
	dw $0054
	db $07, $02
	dw $0098
	// Options
	db $02, $03, $04, $05, $00
org $01e168
	dw $0104
	db $18, $14
	dw $014a
	// Btl. mode
	db $06, $07, $08, $09, $0a, $01
	dw $015e
	// Wait
	db $0b, $0c, $01
	dw $016c
	// Active
	db $0d, $0e, $0f, $10, $01
	dw $01ca
	// Btl. speed
	db $06, $07, $11, $12, $13, $01
	dw $024a
	// Btl. message
	db $06, $07, $14, $15, $16, $17, $18, $01
	dw $04ca
	// Window color
	db $19, $1a, $1b, $1c, $1d, $1e, $1f, $01
	dw $035e
	// Default
	db $20, $21, $22, $23, $01
	dw $036c
	// Custom
	db $24, $25, $26, $27, $01
	dw $044a
	// Cursor position
	db $24, $28, $29, $1f, $2a, $2b, $2c, $04, $2d, $01
	dw $045e
	// Default
	db $20, $21, $22, $23, $01
	dw $046c
	// Keep
	db $2e, $2f, $30, $01
	dw $02ca
	// Sound
	db $31, $32, $33, $01
	dw $02de
	// Stereo
	db $34, $35, $36, $37, $01
	dw $02ec
	// Mono
	db $38, $39, $37, $01
	dw $021e
	// Fast
	db $3a, $3b, $3c, $01
	dw $022e
	// Slow
	db $3d, $3e, $3f, $01
	dw $03de
	// Single
	db $40, $41, $42, $01
	dw $03ec
	// Multi
	db $43, $44, $45, $01
	dw $034a
	// Control
	db $46, $47, $48, $49, $00
org $01e1f8
	// Controller
	db $46, $47, $48, $4a, $35, $4b, $00
org $01e204
	dw $0096
	// Customize
	db $24, $25, $26, $4c, $4d, $10, $01
	dw $0206
	// Confirm
	db $46, $4e, $4f, $50, $01
	dw $0286
	// Cancel
	db $51, $52, $53, $54, $01
	dw $0306
	// Menu
	db $55, $56, $57, $01
	dw $0386
	// L button
	db $58, $59, $5a, $5b, $5c, $01
	dw $0406
	// START
	db $5d, $5e, $5f, $60, $01
	dw $0486
	// Quit
	db $61, $62, $00
org $01e238
	// Unused    Confirm  Cancel    Menu
	db $63, $64, $65, $66, $67, $68, $69, $6a, $6b, $6c, $6d, $6e, $6f, $70, $67, $55, $56, $57, $00
org $01e24c
	// A      B       X      Y      SELECT
	db $71, $67, $72, $73, $67, $67, $74, $67, $67, $75, $67, $67, $76, $77, $78, $79, $00
org $01e263
	dw $01ca
	db $14, $0b
	dw $0096
	// Pad selector
	db $7a, $7b, $7c, $7d, $7e, $7f, $1f, $00
org $01e279
	dw $0002
	db $06, $02
	dw $0044
	//  Treasure
	db $02, $03, $04, $05, $06, $07, $01
	dw $0072
	// Exit
	db $08, $09, $01
St_mes_getall:
	dw $0056
	// Take all  
	db $0a, $0b, $0c, $0d, $0e, $00
org $01e295
	dw $0056
	// Exchange
	db $08, $0f, $10, $11, $12, $00
org $01e2a0
	dw $f00d
	db $ad, $ba
	dw $0046
	// You have left some
	db $13, $14, $15, $16, $17, $18, $19, $1a, $1b, $1c, $1d, $01
	dw $0072
	// important item.
	db $1e, $1f, $20, $21, $22, $23, $24, $25, $00
org $01e2bd
	dw $0258
	// learned
	db $d2, $d3, $d4, $d5, $00
org $01e2cd
	// 1    2    3    4   5    6
	db $80, $67, $81, $67, $82, $67, $83, $67, $84, $67, $85, $00
org $01e2d9
	// 
	db $52, $00
org $01e2e1
	// Left-handed
	db $6e, $d6, $d7, $d8, $cf, $d9, $da, $00
org $01e2e9
	// Right-handed
	db $db, $dc, $dd, $de, $6b, $df, $d5, $00
org $01e2f1
	// Ambidexter
	db $e0, $e1, $e2, $e3, $85, $e4, $00
org $01b214
	dw $00f0
	// Wh. magic
	db $e5, $e6, $e7, $06, $07, $00
org $01b21c
	dw $0170
	// Bl. magic
	db $e8, $e9, $ea, $eb, $ec, $00
org $01b224
	dw $01f0
	// Summon
	db $ed, $ee, $ef, $9c, $00
org $01b22c
	dw $0170
	// Ninjutsu
	db $f0, $f1, $f2, $f3, $f4, $00
org $01b234
	dw $00f0
	//              
	db $52, $52, $52, $52, $52, $00
org $01b23c
	dw $0170
	//              
	db $52, $52, $52, $52, $52, $00
org $01b244
	dw $01f0
	//              
	db $52, $52, $52, $52, $52, $00
