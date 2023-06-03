;********************************************************************************
; platform.asm
;
; Routines and macro's helping to make code more portable.
;
; date:        2023-05-29
; created by:  PIG Games (Erik van der Tier)
; license:     MIT
;********************************************************************************

bbr .macro bit, zp, label
	.switch cpu_type
	.case "r65c02", "w65c02"
		bbr \bit,\zp,\label
	.default
		lda \zp
		bit #1 << \bit
		beq \label
	.endswitch
.endmacro

bbs .macro bit, zp, label
	.switch cpu_type
	.case "r65c02", "w65c02"
		bbs \bit,\zp,\label
	.default
		lda \zp
		bit #1 << \bit
		bne \label
	.endswitch
.endmacro

platform .namespace

fixCPUPin3 .macro
		; If this is a 65816, switch pin 3 from an input
    		; (6502 PHI1-out) to a 1 output (816 ABORTB-in).

	      	; Try to put the CPU into 65816 native mode.
        	.cpu    "65816"
        	clc
        	xce             ; NOP on a w65c02

      		; Carry still clear if this is a w65c02;
      		; Carry set if an 816 was in emulation mode
      		; (as it would be after a RESET).
       		bcc     +

      		; Switch back to emulation mode.
        	sec
        	xce

      		; Reconfigure CPU pin 3.
        	stz     $1       ; io_ctrl
        	lda     #$03     ; 
        	sta     $d6b0    ; 

      		; Resume
	+    	.cpu cpu_type      
.endmacro

.endnamespace ; platform