; OS Header
; Provides metadata and RSTs for the OS

; $0000
; Standard KnightOS-compliant header
	; RST $00
	jp Boot
	; Magic Number
	; $0003
	.db "SK"
	; $0005
	.db $00 ; Major Version
	.db $00 ; Minor Version
	; $0007
	; Build Type
	; Bits 0-2 determine model
	; Bit 3 is set on DEBUG builds
	; Bit 4 is set on USB models only
	; Bit 5 is set on 15 MHz models only
	; Bits 6-7 are unused
	#ifdef DEBUG
	
	#ifdef TI73
	.db %00001000
	#endif
	#ifdef TI83Plus
	.db %00001001
	#endif
	#ifdef TI83PlusSE
	.db %00101010
	#endif
	#ifdef TI84Plus
	.db %00111011
	#endif
	#ifdef TI84PlusSE
	.db %00111100
	#endif
	
	#else
	
	#ifdef TI73
	.db %00000000
	#endif
	#ifdef TI83Plus
	.db %00000001
	#endif
	#ifdef TI83PlusSE
	.db %00100010
	#endif
	#ifdef TI84Plus
	.db %00110011
	#endif
	#ifdef TI84PlusSE
	.db %00110100
	#endif
	
	#endif
; $0008
	; RST $08
	ret
.fill $10-$
; $0010
	; RST $10
	ret
.fill $18-$
; $0018
	; RST $18
	ret
.fill $20-$
; $0020
	; RST $20
	ret
.fill $28-$
; $0028
	; RST $28
	ret
.fill $30-$	
; $0030
	; RST $30
	ret
.fill $38-$
; $0038
	; RST $38
	; SYSTEM INTERRUPT
	jp SysInterrupt
	
.fill $53-$
; $0053
	jp Boot
; $0056
	.db $FF, $A5, $FF
	