;Keyboard Input
;Obtains an ASCII output from the TI-8x keypad


WaitKey:
	call GetKey
	cp 0
	jp z, Waitkey
	ret

GetKey:
	call GetKeyRaw
	
	;Check if scancode, if not, reset last key
	cp 0
	jp z, ResetLastKey
	
	;Compare scancode with last key, if they are the same then return with 0
	ld b, a
	ld a, (lastKey)
	cp b
	ld a, 0
	ret z
	
	;A new key has been pressed, set it to last key
	ld a, b
	ld (lastKey), a
	
	;Load pointer to ASCII table
	ld hl, AsciiTable
	ld b, 0
	ld c, a
	
	;Correct offset if shift
	ld a, (shiftOn)
	cp 0
	jp z, GetKey0
	
	ld hl, AsciiTableShift
	
	;Obtains ASCII value
GetKey0:
	add hl, bc
	ld a, (hl)
	
	;If ASCII is not $FF, then return
	cp $FF
	ret nz
	
	;Otherwise,shift was pressed, handle it
	ld a, (shiftOn)
	cpl
	ld (shiftOn), a
	
	;Return 0
	ld a, 0
	ret
	
	
	;Resets the key in the scancode
ResetLastKey 	
	ld a, 0
	ld (lastKey), a
	ret
	
ResetKeyboard:
	ld a, 0
	ld (lastKey), a
	ld (shiftOn), a
	ret
	
	;Obtains raw scancode from the keyboard
	;
	;Returns scancode in Reg A
GetKeyRaw:
	;Set up masks to scan the prok
	ld e, %11111110
	ld b, %11111110
	ld c, 1
	
	;Actually scan the port
GetKeyRaw0:
	
	ld a,e
	out (1),a
	in a,(1)
	cp b
	jp z, GetKeyRaw1
	inc c
	rlc b
	ld a,%11111110
	cp b
	jp nz, getKeyRaw0
	rlc e
	cp e
	jp nz, getKeyRaw0
	
	;Nothing found, return 0
	ld a, 0
	ret
GetKeyRaw1:
	;Key found, return keycode
	ld a,c
	ret
	
	
AsciiTable:
		;Scan Code To ASCII Table
	;    00  01  02  03  04  05  06  07  08  09  0A  0B  0C  0D  0E  0F
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$0A,'"','W','R','M','H',$08
	.db $00,$00,'#','V','Q','L','G',$00,$00,':','Z','U','P','K','F','C'
	.db $00,' ','Y','T','O','J','E','B','=',$00,'X','S','N','I','D','A'
	.db $00,$00,$00,$00,$00,$00,$FF,$1B,$08,$00,$00,$00,$00,$00,$00,$00

AsciiTableShift:
	;Shift Codes
	;    00  01  02  03  04  05  06  07  08  09  0A  0B  0C  0D  0E  0F
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$0A,'+','-','*','/','!',$08
	.db $00,$00,'3','6','9',']',$00,$00,$00,'.','2','5','8','[',$00,'>'
	.db $00,'0','1','4','7',',',$00,'<','=',$00,'X','Y',$00,$00,$00,'@'
	.db $00,$00,$00,$00,$00,$00,$FF,$1B,$08,$00,$00,$00,$00,$00,$00,$00