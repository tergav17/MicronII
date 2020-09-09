;BDOS Monitor Program
;Used for low level debugging and system interaction

;Monitor Entry Point
EnterMonitor:
	ld hl, MonMessage
	call PrintString
	call SafeCopy
	
;Monitor Get Command From User
MonGetCom:
	;Print out prompt
	ld e,$3E
	call PutChar
	call SafeCopy
	
MonGetCom0:
	;Grab key input
	call WaitKey
	ld e, a
	
	;Compare if key is lower than $21
	cp $21
	jp c, MonGetCom0
	
	;Save DE
	push de

	;Draw command
	call PutChar
	
	;Restore DE
	pop de
	ld a, e
	
	;If "E", return
	cp 'E'
	jp z, MonRet
	
	;If "W", Write
	cp 'W'
	jp z, MonWrite
	
	;If "R" or "L", return
	cp 'R'
	jp z, MonRead
	cp 'L'
	jp z, MonRead

MonError:	
	;If not recognized, error and loop
	ld e, $3F
	call PutChar

MonNewLine:
	ld e, $0A
	call PutChar
MonCommandExit:
	call SafeCopy
	jp MonGetCom
	
	;Return from monitor
MonRet:
	ld e,$0A
	call PutChar
	
	;Make sure A is 0, for reasons
	ld a,0
	ret
	
	;Enter values into memory
	;TODO
MonWrite:
	call MonEnterWord
	jp MonNewLine
	
	;List 32 values from memory
MonRead:
	call MonEnterWord
	
	inc e
	jp z, MonError
	ld d, 8
	
	;Prints out a line of information
MonRead0:
	dec d
	jp z, MonNewLine
	
	push de
	push bc
	ld e, $0A
	call PutChar
	
	pop bc
	push bc
	
	call MonPrintByte
	pop bc
	push bc
	ld b, c
	call MonPrintByte
	
	ld e, ':'
	call PutChar
	
	pop bc
	push bc
	
	ld a, (bc)
	ld b, a
	
	call MonPrintByte
	
	ld e, ' '
	call PutChar
	
	pop bc
	inc bc
	push bc
	
	ld a, (bc)
	ld b, a
	
	call MonPrintByte
	
	ld e, ' '
	call PutChar
	
	pop bc
	inc bc
	push bc
	
	ld a, (bc)
	ld b, a
	
	call MonPrintByte
	
	ld e, ' '
	call PutChar
	
	pop bc
	inc bc
	push bc
	
	ld a, (bc)
	ld b, a
	
	call MonPrintByte
	
	pop bc
	pop de
	inc bc
	jp MonRead0
	
	jp MonNewLine
	
	;Prompt user to type in a 16 bit word
	;Reg BC < Entered Value
	;Reg E < Error if $FF
MonEnterWord:
	;Print out "#"
	ld e, $23
	call PutChar
	call SafeCopy
	
	;Read in a byte
	call MonReadByte
	
	;Check for errors
	ld a, e
	cp $FF
	ret z
	
	;Save BC register
	push bc
	
	;Read in a byte
	call MonReadByte
	
	;Restore BC, and put B in D
	ld d, b
	pop bc
	
	;Check for errors
	ld a, e
	cp $FF
	ret z
	
	;Valid return
	ld c, d
	ld e, 0
	ret
	
	;Prompt user to type in a byte
	;Reg B < Entered Value
	;Reg E < Error if $FF
MonEnterByte:
	;Print out "$"
	ld e, $24
	call PutChar
	call SafeCopy
	
	;Read in a byte from the user
	;Reg B < Entered Value
	;Reg E < Error if $FF
MonReadByte:
	;Get nybble
	call MonReadNybble
	
	;Check for errors
	ld a, e
	cp $FF
	ret z
	
	;Shift left 4 times
	sla b
	sla b
	sla b
	sla b
	
	;Save BC register
	push bc
	
	;Get nybble
	call MonReadNybble
	
	;Save value in A
	ld d,b
	
	;Restore BC
	pop bc
	
	;Check for errors
	ld a, e
	cp $FF
	ret z
	
	;Load B into A, then OR with D
	ld a, b
	or d
	
	;Return without error
	ld e, 0
	ld b, a
	ret
	
	;Read in a nybble from the user
	;Reg B < Entered Value
	;Reg E < Error if $FF
MonReadNybble:
	call WaitKey
	
	;Save AF and update screen
	push af
	ld e, a
	call PutChar
	call SafeCopy
	pop af
	
	;Subtract ASCII within number block range
	sub $30
	
	;Check if lower than 10
	cp 10
	jp c, MonReadNybble0
	
	;Subtract ASCII within letter block range
	sub 17
	
	;Check if lower than 6
	cp 6
	jp c, MonReadNybble1
	
	;Return error
	ld e, $FF
	ret
	
	;Add 10, then return
MonReadNybble1:
	add a, $0A
	
	;Return if valid
MonReadNybble0:
	ld e, 0
	ld b, a
	ret
	
	;Reg B > Byte
MonPrintByte:
	ld c, b
	
	;Shift C Right 4
	srl c
	srl c
	srl c
	srl c
	
	;Save BC register
	push bc
	
	;Print Nybble
	ld b, c
	call MonPrintNybble
	
	;Restore BC register
	pop bc
	
	;AND operation
	ld a, %00001111
	and b
	
	;Print Nybble
	ld b, a
	jp MonPrintNybble
	
	
	;Reg B > Nybble
MonPrintNybble:
	;Shift to letter block
	ld a, $37
	add a, b
	
	;Check if lower than $41
	cp $41
	jp c, MonPrintNybble0
	
	ld e, a
	jp PutChar
	
	
MonPrintNybble0:
	;Shift to number block
	ld a, $30
	add a, b
	
	ld e, a
	jp PutChar
	
;String Bank
MonMessage:
	.db "SMON V1.0",10,0