.cpu cpu_type

; *******************************************************************************************
; Memory layout
; *******************************************************************************************

* = $02			; reserved
DP		.dsection dp
		.cerror * > $00fb, "Out of DP space"

* = $100		; Stack
Stack		.dsection stack
		.fill $100

* = $1000
Music	.dsection music

* = $E000
Boot 	.dsection boot
		.dsection init
		.dsection system
		.dsection audio

* = $E800
		.dsection data

* = $EE00
		.dsection tilesetpalette

* = $F000	
		.dsection yam3g

* = $FE00
IRQ		.dsection irq

* = $FF00
NMI		.dsection nmi

* = $FFFA
		.dsection ivec

TileMapLayer0 = $010000
* = TileMapLayer0
		.dsection tilelayer0

TileMapLayer1 = $010500
* = TileMapLayer1
		.dsection tilelayer1

TileMapLayer2 = $011000
* = TileMapLayer2
		.dsection tilelayer2

SpriteData =    $011500
* = SpriteData
		.dsection spritedata

TileSet0Data =  $012500
* = TileSet0Data
		.dsection tilesetdata


.section	music
	.binary "../music/odeto64.bin"
.send

.section	irq
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
.send

.section	nmi
rti
.send

;
; Interrupt Vectors
;
.section	ivec
RVECTOR_NMI     .addr NMI    ; FFFA
RVECTOR_RST 	.addr Boot   ; FFFC
RVECTOR_IRQ     .addr IRQ    ; FFFE
.send
