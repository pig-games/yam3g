;********************************************************************************
; game.asm
;
; Game screen routines.
;
; date:        2023-06-03
; created by:  PIG Games (Erik van der Tier)
; license:     MIT
;********************************************************************************

.cpu cpu_type


.namespace	yam3g
game       .namespace

.section yam3g

;********************************************************************************
; init
;
; Initialise the game state.
; This initialises the Cursor and Playfield.
;
; input:
; output:
;********************************************************************************
init .proc
		lda #2
                jsr yam3g.music.InitSIDAddr
		; lda #1
		; jsr yam3g.music.init
                jsr cursor.init
                jsr playfield.resetScore
                ; generate random tiles for map 1
                jsr playfield.generateNew
                jsr playfield.updateTileMap
	rts
.endproc

;********************************************************************************
; processJoystick
;
; Process joystick input.
;
; input:
; * io.joy.VAL: the joystick input value.
; output:
;********************************************************************************
processJoystick .proc
                lda io.joy.VAL          ; backup for button value checks
                lsr a                   ; shift Up status into carry
                bcs joyUp
                lsr a                   ; shift Down status into carry
                bcs joyDown
                lsr a                   ; shift Left status into carry
                bcs joyLeft
                lsr a                   ; shift Right status into carry
                bcs joyRight
        end
		rts

joyRight 
                lda io.joy.VAL                 ; restore joy value for button checks
                and io.joy.BUTTON_0_MASK
                beq +
                jsr cursor.swapRight        ; if button 0 is pressed attempt a swap
                bcc end
                jsr playfield.updateScore
        +
                jsr cursor.moveRight
                bra end
joyLeft
                lda io.joy.VAL
                and io.joy.BUTTON_0_MASK
                beq +
                jsr cursor.swapLeft
                bcc end
                jsr playfield.updateScore
        +
                jsr cursor.moveLeft
                bra end
joyDown
                lda io.joy.VAL
                and io.joy.BUTTON_0_MASK
                beq +
                jsr cursor.swapDown
                bcc end
                jsr playfield.updateScore
        +
                jsr cursor.moveDown
                bra end
joyUp
                lda io.joy.VAL
                and io.joy.BUTTON_0_MASK
                beq +
                jsr cursor.swapUp
                bcc end                        ; swap failed we're done
                jsr playfield.updateScore
        +
                jsr cursor.moveUp
                bra end
.endproc

.endsection yam3g
.endnamespace ; game
.endnamespace ; yam3g
