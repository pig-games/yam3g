;********************************************************************************
; cursor.asm
;
; Routines for the in-game cursor.
;
; date:        2023-05-29
; created by:  PIG Games (Erik van der Tier)
; license:     MIT
;********************************************************************************

.cpu cpu_type

.namespace	yam3g
cursor		.namespace

.section yam3g

;********************************************************************************
; init
;
; Initialises the Cursor.
;
; input:
; output:
;********************************************************************************
init .proc
                ; setup sprite data

                lda #(<SpriteData)
                sta vky.sprite.SP0_Addy_L
                lda #>SpriteData
                sta vky.sprite.SP0_Addy_M
                lda #`SpriteData
                sta vky.sprite.SP0_Addy_H

                lda #vky.sprite.ENABLE | vky.sprite.LUT0 | vky.sprite.SIZE_16 | vky.sprite.DEPTH_L3
                sta vky.sprite.SP0_Ctrl

                stz CurPosX
                stz CurPosY
                stz vky.sprite.SP0_X_H
                stz vky.sprite.SP0_Y_H
                lda #32+6*16
                sta vky.sprite.SP0_X_L
                lda #32+4*16
                sta vky.sprite.SP0_Y_L
                rts
.endproc

;********************************************************************************
; setPos
;
; Sets a new cursor position.
;
; input:
; * CurPosX: x-position
; * CurPosY: y-position
; output:
;********************************************************************************
setPos .proc
                lda CurPosX
                asl
                asl
                asl
                asl
                clc
                adc #32+6*16
                sta vky.sprite.SP0_X_L
                
                lda CurPosY
                asl
                asl
                asl
                asl
                clc
                adc #32+4*16
                sta vky.sprite.SP0_Y_L
                rts
.endproc

;********************************************************************************
; moveRight
;
; Move cursor to the right if not on edge.
;
; input:
; output:
;********************************************************************************
moveRight .proc
                lda CurPosX
                cmp #7
                beq end
                inc a
                sta CurPosX
                jsr setPos
        end     rts
.endproc

;********************************************************************************
; moveLeft
;
; Move cursor to the left if not on edge.
;
; input:
; output:
;********************************************************************************
moveLeft .proc
                lda CurPosX
                beq end
                dec a
                sta CurPosX
                jsr setPos
        end     rts
.endproc

;********************************************************************************
; moveDown
;
; Move cursor to the down if not on edge.
;
; input:
; output:
;********************************************************************************
moveDown .proc
                lda CurPosY
                cmp #7
                beq end
                inc a
                sta CurPosY
                jsr setPos
        end     rts
.endproc

;********************************************************************************
; moveUp
;
; Move cursor to the up if not on edge.
;
; input:
; output:
;********************************************************************************
moveUp .proc
                lda CurPosY
                beq end
                dec a
                sta CurPosY
                jsr setPos
        end     rts
.endproc

;********************************************************************************
; swapLeft
;
; Attempt swap with gem to the left of the cursor.
;
; input:
; * CurPosX
; * CurPosY
; output:
; * C: set if successful swap
;********************************************************************************
swapLeft .proc
                stz Temp4
                stz HorizontalMatchTotal
                stz VerticalMatchTotal
                #loadXY CurPosX, CurPosY
                jsr playfield.setPlayFieldAddr
		pha			       ; backup low byte of address
                lda (playfield.PlayFieldAddr)
                dec playfield.PlayFieldAddr    ; move PlayFieldAddr to the gem to the left
                ldx #~playfield.CHECK_RIGHT    ; check all directions except where we came from
                jsr playfield.checkMatches
                bcc +
                inc Temp4
                txa
                sta HorizontalMatchTotal
                tya
                sta VerticalMatchTotal
        +
		pla			  	; restore low byte of playfield address
		sta playfield.PlayFieldAddr
		dec playfield.PlayFieldAddr
                lda (playfield.PlayFieldAddr)	; get gem number
		inc playfield.PlayFieldAddr
                ldx #~playfield.CHECK_LEFT
                jsr playfield.checkMatches
                bcs +
                lda Temp4
                beq notFound
        +
                clc
                txa
                adc HorizontalMatchTotal
                sta HorizontalMatchTotal
                clc
                tya
                adc VerticalMatchTotal
                sta VerticalMatchTotal
                sec
                rts
        notFound
                stz HorizontalMatchTotal
                stz VerticalMatchTotal
                clc
        rts
.endproc

;********************************************************************************
; swapRight
;
; Attempt swap with gem to the right of the cursor.
;
; input:
; * CurPosX
; * CurPosY
; output:
; * C: set if successful swap
;********************************************************************************
swapRight .proc
                #loadXY CurPosX, CurPosY
                jsr playfield.setPlayFieldAddr
                lda (playfield.PlayFieldAddr)
                inc playfield.PlayFieldAddr   ; move PlayFieldAddr to the gem to the right
                ldx #~playfield.CHECK_LEFT    ; check all directions except where we came from
                jsr playfield.checkMatches
        rts
.endproc

;********************************************************************************
; swapUp
;
; Attempt swap with gem above the cursor.
;
; input:
; * CurPosX
; * CurPosY
; output:
; * C: set if successful swap
;********************************************************************************
swapUp .proc
                #loadXY CurPosX, CurPosY
                jsr playfield.setPlayFieldAddr
                lda (playfield.PlayFieldAddr)
                pha
                lda playfield.PlayFieldAddr
                sec
                sbc #8
                sta playfield.PlayFieldAddr   ; move PlayFieldAddr to the gem above
                ldx #~playfield.CHECK_DOWN    ; check all directions except where we came from
		pla
                jsr playfield.checkMatches
        rts
.endproc

;********************************************************************************
; swapDown
;
; Attempt swap with gem below the cursor.
;
; input:
; * CurPosX
; * CurPosY
; output:
; * C: set if successful swap
;********************************************************************************
swapDown .proc
                #loadXY CurPosX, CurPosY
                jsr playfield.setPlayFieldAddr
                lda (playfield.PlayFieldAddr)
                pha
                lda playfield.PlayFieldAddr
                clc
                adc #8
                sta playfield.PlayFieldAddr ; move PlayFieldAddr to the gem below
                
                ldx #~playfield.CHECK_UP    ; check all directions except where we came from
		pla
                jsr playfield.checkMatches
        rts
.endproc

;********************************************************************************
; #loadXY x, y (Macro)
;
; Load x, y values into the X and Y registers.
;
; input:
; * x: x-value using any addressing mode available to 'lda'
; * y: y-value using any addressing mode available to 'lda'
; output:
; * X
; * Y
;********************************************************************************
loadXY .macro x, y
                lda \x
                tax
                lda \y
                tay
.endmacro

.endsection 	; yam3g
.endnamespace 	; cursor
.endnamespace	; yam3g