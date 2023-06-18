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

.section yam3g

InitSIDAddr     = $1000 ;SIDTune     ;.word 1
PlayAddr        = $1003 ;SIDTune + 3;.word 1

init .proc
                lda #<playTitle
                sta MusicJmpTable + STATE_TITLE
                lda #>playTitle
                sta MusicJmpTable + STATE_TITLE+1
                lda #<playMenu
                sta MusicJmpTable + STATE_MENU
                lda #>playMenu
                sta MusicJmpTable + STATE_MENU+1
                lda #<playGame
                sta MusicJmpTable + STATE_GAME
                lda #>playGame
                sta MusicJmpTable + STATE_GAME+1
                rts
.endproc

play .proc
                ldx State
                jmp (MusicJmpTable,x)
.endproc


playTitle .proc
                jsr PlayAddr
                rts
.endproc

playMenu .proc
                rts
.endproc

playGame .proc
                jsr PlayAddr
        rts
.endproc

.endsection yam3g

.section music
        SIDTune	.binary "../music/Bejewled3CLone6581.sid"
        MusicJmpTable   .fill STATE_AMOUNT*2
.endsection music

.endnamespace ; music
.endnamespace ; yam3g
