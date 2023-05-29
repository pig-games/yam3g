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