.cpu cpu_type

; *******************************************************************************************
; Memory layout
; *******************************************************************************************

* = $02			; reserved
		.dsection dp
		.cerror * > $00fb, "Out of DP space"

* = $100		; Stack
		.dsection stack
		.fill $100

* = $1000
		.dsection music

* = $E000
 		.dsection boot
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
		.dsection irq

* = $FF00
		.dsection unusedint

* = $FFE4
		.dsection ivec816
* = $FFF4
		.dsection ivecC02

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
