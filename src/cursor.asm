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
; updateTotalMatches
;
; Updates the total horizontal and vertical matches.
;
; input:
; * X: horizontal number of matches
; * Y: vertical number of matches
; output:
; * HorizontalMatchTotal
; * VerticalMatchTotal
;****************************************************h****************************
updateTotalMatches .proc
                clc
                txa
                adc HorizontalMatchTotal
                sta HorizontalMatchTotal
                clc
                tya
                adc VerticalMatchTotal
                sta VerticalMatchTotal
        rts
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
                lda CurPosX
                dec a                       ; CurPosX - 1
                asl                         ; (CurPosX-1) * 2
                clc
                adc playfield.Col0          ; Calculate address of column struct
                sta playfield.ColPtr        ; Store ColPtr
                #loadXY CurPosX, CurPosY
                jsr playfield.setAddr
		pha			    ; backup low byte of source address
                lda (playfield.Addr)
                tay
                ldx #~playfield.CHECK_RIGHT ; check all directions except where we came from
                dec playfield.Addr          ; move Addr to the gem to the left
                lda playfield.Addr
                pha                         ; back up low byte of target address
                jsr playfield.checkMatches
                bcc +
                inc Temp4
                jsr updateTotalMatches
        +
                lda CurPosX
                asl                         ; CurPosX * 2
                clc
                adc playfield.Col0          ; Calculate address of column struct
                sta playfield.ColPtr        ; Store ColPtr
		pla			    ; restore low byte of target address
		sta playfield.Addr
                lda (playfield.Addr)	    ; get gem number
                tay
                pla                         ; restore low byte of source address
                sta playfield.Addr
                ldx #~playfield.CHECK_LEFT
                jsr playfield.checkMatches
                bcs +
                lda Temp4
                beq notFound
        +
                jsr updateTotalMatches
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
                stz Temp4
                stz HorizontalMatchTotal
                stz VerticalMatchTotal
                #loadXY CurPosX, CurPosY
                jsr playfield.setAddr
                pha                         ; backup low byte of source address
                lda (playfield.Addr)
                tay
                ldx #~playfield.CHECK_LEFT  ; check all directions except where we came from
                inc playfield.Addr          ; move Addr to the gem to the right
                lda playfield.Addr
                pha                         ; backup low byte of target address
                jsr playfield.checkMatches
                bcc +
                inc Temp4
                jsr updateTotalMatches
        +
                pla                        ; restore low byte of target address
                sta playfield.Addr
                lda (playfield.Addr)
                tay
                pla                        ; restore low byte of source address
                sta playfield.Addr
                ldx #~playfield.CHECK_RIGHT
                jsr playfield.checkMatches
                bcs +
                lda Temp4
                beq notFound
        +
                jsr updateTotalMatches
                sec
                rts
        notFound
                stz HorizontalMatchTotal
                stz VerticalMatchTotal
                clc
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
                stz Temp4
                stz HorizontalMatchTotal
                stz VerticalMatchTotal
                #loadXY CurPosX, CurPosY
                jsr playfield.setAddr
                pha                        ; backup low byte of source address
                lda (playfield.Addr)       ; get source gem number
                tay
                ldx #~playfield.CHECK_DOWN ; check all directions except where we came from
                lda playfield.Addr
                sec
                sbc #8                     ; point playfield addr to gem above
                pha                        ; backup low byte of target addr
                sta playfield.Addr         ; store target addr
                jsr playfield.checkMatches
                bcc +
                inc Temp4
                jsr updateTotalMatches
        +
                pla                         ; restore low byte of target addr
                sta playfield.Addr
                lda (playfield.Addr)
                tay
                pla                         ; restore low byte of source addr
                sta playfield.Addr
                ldx #~playfield.CHECK_UP
                jsr playfield.checkMatches
                bcs +
                lda Temp4
                beq notFound
        +
                jsr updateTotalMatches
                sec
                rts
        notFound
                stz HorizontalMatchTotal
                stz VerticalMatchTotal
                clc
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
                stz Temp4
                stz HorizontalMatchTotal
                stz VerticalMatchTotal
                #loadXY CurPosX, CurPosY
                jsr playfield.setAddr
                pha                        ; backup low byte of source address
                lda (playfield.Addr)       ; get source gem number
                tay
                ldx #~playfield.CHECK_UP ; check all directions except where we came from
                lda playfield.Addr
                clc
                adc #8                     ; point playfield addr to gem below
                pha                        ; backup low byte of target addr
                sta playfield.Addr         ; store target addr
                jsr playfield.checkMatches
                bcc +
                inc Temp4
                jsr updateTotalMatches
        +
                pla                         ; restore low byte of target addr
                sta playfield.Addr
                lda (playfield.Addr)
                tay
                pla                         ; restore low byte of source addr
                sta playfield.Addr
                ldx #~playfield.CHECK_DOWN
                jsr playfield.checkMatches
                bcs +
                lda Temp4
                beq notFound
        +
                jsr updateTotalMatches
                sec
                rts
        notFound
                stz HorizontalMatchTotal
                stz VerticalMatchTotal
                clc
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