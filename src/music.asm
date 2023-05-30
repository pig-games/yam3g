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

music .namespace

init = SIDTune
play = SIDTune + 3

.section	music
SIDTune	.binary "../music/odeto64.bin"
.send

.endnamespace ; music
