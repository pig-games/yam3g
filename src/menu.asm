;********************************************************************************
; menu.asm
;
; Menu screen routines.
;
; date:        2023-06-03
; created by:  PIG Games (Erik van der Tier)
; license:     MIT
;********************************************************************************

.cpu cpu_type

.namespace	yam3g
menu       .namespace

.section yam3g

init .proc
		pha
		pla
	rts
.endproc

processJoystick .proc
	rts
.endproc

.endsection yam3g
.endnamespace ; menu
.endnamespace ; yam3g

