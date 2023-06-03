;********************************************************************************
; title.asm
;
; Title screen routines.
;
; date:        2023-06-03
; created by:  PIG Games (Erik van der Tier)
; license:     MIT
;********************************************************************************

.cpu cpu_type

.namespace	yam3g
title       .namespace

.section yam3g

init .proc
		pha
		pla
		rts
.endproc

processJoystick .proc
                lda io.joy.VAL          ; backup for button value checks
                and io.joy.BUTTON_0_MASK
		beq end
		lda #STATE_GAME
		jsr yam3g.changeState
        end
                rts 

.endproc ; processJoystick

.endsection yam3g
.endnamespace ; title
.endnamespace ; yam3g
