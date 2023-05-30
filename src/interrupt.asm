;********************************************************************************
; interrupt.asm
;
; Interrupt vectors and routines.
;
; date:        2023-05-30
; created by:  PIG Games (Erik van der Tier)
; license:     MIT
;********************************************************************************

.cpu cpu_type

.section irq
IRQ
                pha
                phx
                phy
                php

                jsr yam3g.InterruptHandlerJoystick

                plp 
                ply
                plx
                pla
EXIT_IRQ_HANDLE
		rti 
.endsection irq

.section unusedint
UnusedInt
	rti
.endsection unusedint

;
; Interrupt Vectors
;
.section ivec816
		.addr UnusedInt		; ffe4 816 native COP
		.addr UnusedInt		; ffe6 816 native BRK
		.addr UnusedInt		; ffe8 816 native ABORT
		.addr UnusedInt		; ffea 816 native NMI
		.addr UnusedInt		; ffec 816 native BRK
		.addr UnusedInt		; ffee 816 native IRQ
.endsection ivec816

.section ivecC02
		.addr UnusedInt		; fff4  COP
		.addr 0			; fff6  Not used on 6502
		.addr UnusedInt		; fff8  816 emulation ABORT
		.addr UnusedInt		; fffa  NMI
		.addr system.Boot	; fffc  RESET
		.addr IRQ		; fffe  IRQ/BRK
.endsection ivecC02

