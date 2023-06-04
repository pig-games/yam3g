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

initSID = SIDTune
PlayAddr = SIDTune + 3

.section yam3g

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
        SIDTune	.binary "../music/odeto64.bin"
        MusicJmpTable   .fill STATE_AMOUNT*2
.endsection music

.endnamespace ; music
.endnamespace ; yam3g
