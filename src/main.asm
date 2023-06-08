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

* = $1000-$7e
		.dsection music

* = $e000
 		.dsection boot
		.dsection init
		.dsection system
		.dsection audio

* = $e800
		.dsection data

* = $ee00
		.dsection tilesetpalette

* = $f000	
		.dsection yam3g

* = $fe00
		.dsection irq

* = $ff00
		.dsection unusedint

* = $ffe4
		.dsection ivec816
* = $fff4
		.dsection ivecC02

; The d_<...> labels below are a workaround to use long addresses in this memory layout.
; This are not the labels used in the rest of the code as those are defined in the yam3g namespace where they belong.

d_tilelayer0 = $010000
* = d_tilelayer0
		.dsection tilelayer0

d_tilelayer1 = $010500
* = d_tilelayer1
		.dsection tilelayer1

d_tilelayer2 = $011000
* = d_tilelayer2
		.dsection tilelayer2

d_spritedata = $011500
* = d_spritedata
		.dsection spritedata

d_tilesetdata = $012500
* = d_tilesetdata
		.dsection tilesetdata
