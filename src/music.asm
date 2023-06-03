;********************************************************************************
; music.asm
;
; Music routines.
;
; date:        2023-05-30
; created by:  PIG Games (Erik van der Tier)
; license:     MIT
;********************************************************************************

.cpu cpu_type

.namespace yam3g
music .namespace

init = SIDTune
PlayAddr = SIDTune + 3

.section yam3g
play .proc
                lda State
                bne checkMenu
                rts
        checkMenu
                cmp #STATE_MENU
                bne checkGame
                rts
        checkGame
                jsr PlayAddr
                rts
.endproc
.endsection yam3g

.section music
SIDTune	.binary "../music/odeto64.bin"
.endsection music

.endnamespace ; music
.endnamespace ; yam3g
