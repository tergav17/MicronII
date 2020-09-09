;BDOS Variables
lastKey .equ $C300
shiftOn .equ $C301

#include "terminal.asm"
#include "kbinput.asm"
#include "monitor.asm"
;BSOD (Basic Device Operating System)
;Layer of abstraction between calculator hardware and MICRON Kernel
;Manages terminal, MSFS file operations, interrupts, and more

;BDOS Memory Map:
;$C000-C2FF Graphics Buffer
;$C300-C3FF BDOS Utility Work Area + Stack
;$C400-C4FF Terminal Buffer + Work Area



BDOSBootEntry:
	;Move SP to upper memory
	ld sp, $C3FF

	;Reset the terminal
	call ResetTerminal
	call ResetKeyboard
	
	;Boot Message
	ld hl, BootMessage
	call PrintString
	call SafeCopy
	
#ifdef TI83Plus
	;Memory Set Op For TI83+
	ld a, $40
	out ($06), a
	
	ld a, $41
	out ($07), a
#endif

	;Memory Set Message
	ld hl, MemoryMessage
	call PrintString
	call SafeCopy
	
	call EnterCLI
	
	call SafeCopy
	
	jp $
	
	;BDOS Command Line Interface
EnterCLI:
	ld hl, CLIMessage
	call PrintString
	
	;Display Help Message
HelpCLI:
	ld hl, CLIHelpMessage
	call PrintString
	
	;CLI Command Prompt
CommandCLI:
	ld e,$2A
	call PutChar
	call SafeCopy
	
	;Grab key
GetKeyCLI:
	call WaitKey
	ld e, a
	
	;Compare if key is low than $21
	cp $21
	jp c, GetKeyCLI
	
	;Save DE
	push de

	;Draw command
	call PutChar
	
	ld e, $0A
	
	call PutChar
			
	;Recall DE
	pop de
	
	ld a, e
	
	cp '0'
	ret z
	
	cp '1'
	jp z, Boot
	
	cp '2'
	call z, EnterMonitor
	
	cp '9'
	jp z, HelpCLI

	call SafeCopy
	jp CommandCLI
	
	
	;Prints out a string
	;
	;Reg HL > String Address
PrintString:
	;Save HL
	push hl
	
	;Make sure (HL) isn't 0
	ld a, (hl) 
	cp 0
	jp z, PrintString0
	
	;Put Char
	ld e, a
	call PutChar
	
	;Recall original HL and increment
	pop hl
	inc hl
	;Loop
	jp PrintString
	
	;Exit
PrintString0:
	pop hl
	ret

	;Strings and other data
BootMessage:
	.db "BDOS V0.1"

#ifdef TI73
	.db " ON TI73",10,0
#endif
#ifdef TI83Plus
	.db " ON TI83+",10,0
#endif
#ifdef TI83PlusSE
	.db " ON TI83+SE",10,0
#endif
#ifdef TI84Plus
	.db " ON TI84+",10,0
#endif
#ifdef TI84PlusSE
	.db " ON TI84+SE",10,0
#endif

MemoryMessage:
	.db "MEMORY ZONES PREPPED",10,0
	
CLIMessage:
	.db "ENTERING BDOS CLI...",10,0
	
CLIHelpMessage:
	.db "0: BOOT",10
	.db "1: EXIT CLI",10
	.db "2: MONITOR",10
	.db "9: DISPLAY HELP",10,0




