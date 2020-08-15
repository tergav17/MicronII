;System Terminal Emulation
;Main user I/O for MICRON, supports VT52 control codes
curPosX .equ $C4FF
curPosY .equ $C4FE

termPnC .equ $C4FD
termPnD .equ $C4FC

ResetTerminal:
	;Set the graphics buffer to the correct memory location
	ld iy, $C000
	
	;Clear out the graphics buffer
	call ClearBuffer
	
	ld hl, $C400
	
	ld (hl), 0
	ld d, h
	ld e, l
	inc de
	ld bc, 239
	ldir
	
	;Reset cursor position to 0,0
	ld a, 0
	ld (curPosX), a
	ld a, 0
	ld (curPosY), a
	
	;Draw the cursor
	jp DrawCursor
	
	;Scrolls the screen and the terminal buffer
ScrollScreen:

	;Scroll graphics buffer
	ld hl, $C000 + (12 * 6)
    ld de, $C000
    ld bc, 768 - (12 * 6)
    ldir
	
	;Scroll terminal buffer
	ld hl, $C400 + 24
	ld de, $C400
	ld bc, 240 - 24
	  
	;Clear out moved areas 
	ld hl, $C400 + (240 - 24)
ScrollScreen0:
	ld (hl), 0
	inc l
	ld a,240
	cp l
	jp nz, ScrollScreen0
	
	ld hl, $C300 - (12*10)
ScrollScreen1:
	ld (hl), 0
	inc l
	ld a,l
	cp 0
	jp nz, ScrollScreen1
	
	ret 
	
	;Draw the cursor on the screen
DrawCursor:
	;Set cursor to '_'
	ld e,$5F
	jp DrawChar
	
	;Puts a character up on the terminal
	;
	;Reg E > Character Code
	;All registers return to nothing
PutChar:
	;Set H to terminal buffer
	ld h, $C4
	
	;Set X offset in Reg L
	ld a, (curPosX)
	ld l,a
	
	;Terminal width
	ld bc, 24
	
	;Offset Memory Location
	ld a, (curPosY)
PutChar_:	
	cp 0
	jp z, PutChar0
	add hl, bc
	dec a
	jp PutChar_
	
PutChar0:
	ld (hl), e
	call PutCharG
	jp DrawCursor
	

	;PutChar graphical routines
PutCharG:
	;Compare Reg E with $20 (ASCII for Space)
	ld a, e
	cp $20
	
	;If Reg E < $20, it is a control character
	jp c, PutChar4
	
	;Possible graphics character, make sure it doesn't go out of bounds
PutChar1:

	;Make sure that Reg E < 128
	bit 7, e
	jp z, PutChar2
	
	;If not, set Reg E to $20 (? Character)
	ld e, $3F

	;Routine to draw character
PutChar2:
	call DrawChar
	
	;Increment cursor logic
	ld a, (curPosX)
	inc a
	ld (curPosX), a
	cp 24
	
	;If curPosX = 24, continue
	ret nz
	
PutChar3:
	;Line feed
	ld a, 0
	ld (curPosX), a
	ld a, (curPosY)
	inc a
	ld (curPosY), a
	
	cp 10
	ret nz
	ld a, 9
	ld (curPosY), a
	jp ScrollScreen
	
PutChar4:
	cp $0A
	jp z, PutChar5
	ret
	
PutChar5:
	ld e, $20
	call DrawChar
	jp PutChar3
	
	
	;Draw a character on the screen
	;
	;(curPosX) > Cursor X Position
	;(curPosY) > Cursor Y Position
	;Reg E     > Character Code
	;All registers return to nothing
DrawChar:
	;Set Reg HL to char table
	ld hl, CharTable
	
	;Correct ASCII ID in Reg E
	ld a, %11100000
	add a,e
	ld e,a
	
	;Shift left E, and zero out Reg D to create char table offset
	sla e
	ld d, 0
	
	;Add offset to Reg HL, and load into BC
	add hl, de
	ld b, h
	ld c, l
	
	;Put cursor X (shifted left twice) into Reg H
	ld a,(curPosX)
	sla a
	sla a
	ld h, a
	
	;Put cursor Y multipled by 6 into Reg L
	ld a,(curPosY)
	sla a
	ld l,a
	add a,l
	add a,l
	ld l,a
	
	;Load "termPnC" and "termPnD"
	ld a, (bc)
	ld (termPnC), a
	inc bc
	ld a, (bc)
	ld (termPnD), a
	
	;Set C to pixel X
	ld c, h
	
	;Draw it all
	call TripleReadOutChar
	inc l
	ld h, c
	call TripleReadOutChar
	inc l
	ld h, c
	call DoubleReadOutChar
	ld a, (termPnD)
	ld (termPnC), a
	call ReadOutChar
	inc l
	ld h, c
	call TripleReadOutChar
	inc l
	ld h, c
	call TripleReadOutChar
	
	ret
	
	;Calls "ReadOutChar" 3 times
TripleReadOutChar:
	call ReadOutChar
	
	;Calls "ReadOutChar" 2 times
DoubleReadOutChar:
	call ReadOutChar

	;Reads out a bit from "termPnC" and draws it at the X/Y position determined by HL
	;L and BC are preserved, H is incremented
ReadOutChar:
	;Push HL into stack, and call "getPixel" using X/Y from Reg HL
	push hl
	ld a, h
	call getPixel
	ld d, a
	
	;Shift "termPnC" left to set carry flag	
	ld a, (termPnC)
	sla a
	ld (termPnC), a
	ld a, d
	
	;If carry, set bit at mask location, otherwise reset it
	jp c, ReadOutChar0
	cpl
	and (hl)
	ld (hl), a
	pop hl
	inc h
	ret
	
ReadOutChar0:
	or (hl)
	ld (hl), a
	pop hl
	inc h
	ret
	
	
	;Character information table
	;Covers ASCII $21-$7E
CharTable:
	;What the fuck?
	;' '
	.db %00000000, %00000000
	;'!'
	.db %01001001, %00000100
	;'"'
	.db %10110100, %00000000	
	;'#'
	.db %10111110, %11111010
	;'$'	
	.db %01011111, %00111110
	;'%'
	.db %10100101, %01001010
	;'&'
	.db %01010101, %01011110
	;'''
	.db %01001000, %00000000
	;'('
	.db %01010010, %01000100
	;')'
	.db %01000100, %10010100
	;'*'
	.db %01011101, %01010000
	;'+'
	.db %00001011, %10100000
	;','
	.db %00000000, %00101100
	;'-'
	.db %00000011, %10000000
	;'.'
	.db %00000000, %00000100
	;'/'
	.db %00100101, %01001000
	;'0'
	.db %11110110, %11011110
	;'1'
	.db %11001001, %00101110
	;'2'
	.db %11100111, %11001110
	;'3'
	.db %11100101, %10011110
	;'4'
	.db %10110111, %10010010
	;'5'
	.db %11110011, %10011110
	;'6'
	.db %11110011, %11011110
	;'7'
	.db %11100100, %10010010
	;'8'
	.db %11110111, %11011110
	;'9'
	.db %11110111, %10010010
	;':'
	.db %00001000, %00100000
	;';'
	.db %00001000, %00101100
	;'<'
	.db %00101010, %00100010
	;'='
	.db %00011100, %01110000
	;'>'
	.db %10001000, %10101000
	;'?'
	.db %11000101, %00000100
	;'@'
	.db %11000111, %11011100
	;'A'
	.db %01010111, %11011010
	;'B'
	.db %11010111, %01011100
	;'C'
	.db %01110010, %01000110
	;'D'
	.db %11010110, %11011100
	;'E'
	.db %11110011, %01001110
	;'F'
	.db %11110011, %01001000
	;'G'
	.db %11110010, %11011110
	;'H'
	.db %10110111, %11011010
	;'I'
	.db %11101001, %00101110
	;'J"
	.db %11100100, %11011100
	;'K'
	.db %10110111, %01011010
	;'L'
	.db %10010010, %01001110
	;'M'
	.db %10111111, %11011010
	;'N'
	.db %10111111, %11111010
	;'O'
	.db %01010110, %11010100
	;'P'
	.db %11010111, %11001000
	;'Q'
	.db %01010110, %11110110
	;'R'
	.db %11010111, %01011010
	;'S'
	.db %01110011, %10011100
	;'T'
	.db %11101001, %00100100
	;'U'
	.db %10110110, %11010110
	;'V'
	.db %10110101, %10110010
	;'W'
	.db %10110111, %11111010
	;'X'
	.db %10110101, %01011010
	;'Y'
	.db %10110101, %00100100
	;'Z'
	.db %11100101, %01001110
	;'['
	.db %11010010, %01001100
	;'\'
	.db %10010001, %00010010
	;']'
	.db %01100100, %10010110
	;'^'
	.db %01010100, %00000000
	;'_'
	.db %00000000, %00001110
	;'`'
	.db %01000100, %00000000
	;'a'
	.db %00001110, %11010110
	;'b'
	.db %10011010, %11011100
	;'c'
	.db %00001110, %01000110
	;'d'
	.db %00101110, %11010110
	;'e'
	.db %00001110, %11100110
	;'f'
	.db %00101011, %10100100
	;'g'
	.db %01110101, %10011100
	;'h'
	.db %10010011, %01011010
	;'i'
	.db %01000001, %00100100
	;'j'
	.db %00100000, %11011100
	;'k'
	.db %10010111, %01011010
	;'l'
	.db %01001001, %00100100
	;'m'
	.db %00011111, %11011010
	;'n'
	.db %00011010, %11011010
	;'o'
	.db %00001010, %11010100
	;'p'
	.db %00011010, %11101000
	;'q'
	.db %00001110, %10110010
	;'r'
	.db %00010111, %01001000
	;'s'
	.db %00001111, %00011100
	;'t'
	.db %01011101, %00100010
	;'u'
	.db %00010110, %11010110
	;'v'
	.db %00010110, %11010100
	;'w'
	.db %00010111, %11111010
	;'x'
	.db %00010101, %00101010
	;'y'
	.db %10110101, %10011110
	;'z'
	.db %00011100, %10101110
	;'{'
	.db %01101010, %00100110
	;'|'
	.db %01001000, %00100100
	;'}'
	.db %11001000, %10101100
	;'~'
	.db %00001111, %00000000
	;' '
	.db %00000000, %00000000

