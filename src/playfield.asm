.cpu "w65c02"
;********************************************************************************
; playfield.asm
;
; Routines for generation and manipulation of YAM3G playfields.
;
; date:        2023-05-25
; created by:  PIG Games (Erik van der Tier)
; license:     MIT
;********************************************************************************
.namespace	yam3g
playfield	.namespace

PlayFieldXSize = 8
PlayFieldYSize = 8

HORIZONTAL_MATCH = %01000000
VERTICAL_MATCH   = %10000000
HORIZONTAL_MATCH_B = 6
VERTICAL_MATCH_B   = 7
CHECK_LEFT       = %00000001
CHECK_RIGHT      = %00000010
CHECK_UP         = %00000100
CHECK_DOWN       = %00001000
OFF_GEM_MN       = 0
OFF_GEM_RIGHT    = 1
OFF_GEM_BELOW    = 8
Temp             = Temp0
CurrentGem       = Temp3

.section data
        .align $100
	PlayField       .fill 64,0
	PlayFieldEnd
.endsection

.section dp
	TileAddr        .fill 2
	PlayFieldAddr   .fill 2
.endsection

.section yam3g

;********************************************************************************
; resetScore
;
; Resets the player score.
;
; input:
; output:
;********************************************************************************
resetScore .proc
                stz Score0
                stz Score1
                stz Score2
                stz Score3
                jsr displayScore                
        rts
.endproc

;********************************************************************************
; updateScore
;
; Updates the player score based on number of matches.
;
; input:
; * X: horizontal number of matches
; * Y: vertical number of matches
; output:
;********************************************************************************
updateScore .proc
        TotalMatches = Temp0     ; used as temp storage for adding the horizontal and vertical match counts
                stz TotalMatches
        sed
                txa              ; get horizontal number of matches
                clc
                adc TotalMatches
                sta TotalMatches
                tya              ; get vertical number of matches
                clc
                adc TotalMatches
                inc a            ; increase with one to count the swapped gem
                clc
                adc Score0       ; add match count and overflow to other 'positions'
                sta Score0
                lda #0
                adc Score1
                sta Score1
                lda #0
                adc Score2
                sta Score2
                lda #0
                adc Score3
                sta Score3
        cld
                jsr displayScore
        rts
.endproc

;********************************************************************************
; initCursor
;
; Initialises the Cursor.
;
; input:
; output:
;********************************************************************************
initCursor .proc
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
                sta vky.sprite.SP0_y_L
                rts
.endproc

;********************************************************************************
; setCursorPosition
;
; Sets a new cursor position.
;
; input:
; * CurPosX: x-position
; * CurPosY: y-position
; output:
;********************************************************************************
setCursorPos .proc
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
; cursorRight
;
; Move cursor to the right if not on edge.
;
; input:
; output:
;********************************************************************************
cursorRight .proc
                lda CurPosX
                cmp #7
                beq end
                inc a
                sta CurPosX
                jsr setCursorPos
        end     rts
.endproc

;********************************************************************************
; cursorLeft
;
; Move cursor to the left if not on edge.
;
; input:
; output:
;********************************************************************************
cursorLeft .proc
                lda CurPosX
                beq end
                dec a
                sta CurPosX
                jsr setCursorPos
        end     rts
.endproc

;********************************************************************************
; cursorDown
;
; Move cursor to the down if not on edge.
;
; input:
; output:
;********************************************************************************
cursorDown .proc
                lda CurPosY
                cmp #7
                beq end
                inc a
                sta CurPosY
                jsr setCursorPos
        end     rts
.endproc

;********************************************************************************
; cursorUp
;
; Move cursor to the up if not on edge.
;
; input:
; output:
;********************************************************************************
cursorUp .proc
                lda CurPosY
                beq end
                dec a
                sta CurPosY
                jsr setCursorPos
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
                #loadXY CurPosX, CurPosY
                jsr setPlayFieldAddr
                lda (PlayFieldAddr)
                sta CurrentGem
                dec PlayFieldAddr    ; move PlayFieldAddr to the gem to the left
                
                lda #~CHECK_RIGHT    ; check all directions except where we came from
                tax
                jsr checkMatches
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
                jsr setPlayFieldAddr
                lda (PlayFieldAddr)
                sta CurrentGem
                inc PlayFieldAddr   ; move PlayFieldAddr to the gem to the right
                
                lda #~CHECK_LEFT    ; check all directions except where we came from
                tax
                jsr checkMatches
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
                jsr setPlayFieldAddr
                lda (PlayFieldAddr)
                sta CurrentGem
                lda PlayFieldAddr
                sec
                sbc #8
                sta PlayFieldAddr   ; move PlayFieldAddr to the gem above
                
                lda #~CHECK_DOWN    ; check all directions except where we came from
                tax
                jsr checkMatches
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
                jsr setPlayFieldAddr
                lda (PlayFieldAddr)
                sta CurrentGem
                lda PlayFieldAddr
                clc
                adc #8
                sta PlayFieldAddr ; move PlayFieldAddr to the gem below
                
                lda #~CHECK_UP    ; check all directions except where we came from
                tax
                jsr checkMatches
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

;********************************************************************************
; setPlayFieldAddr
;
; Sets the PlayFieldAddr ptr for the given X, Y coordinates.
;
; input:
; * X: x-coordinate
; * Y: y-coordinate
; output:
; * PlayFieldAddr(+1) contains the address for the gem at X, Y.
;********************************************************************************
setPlayFieldAddr .proc
        Temp = Temp0
                tya
                asl a                 ; multiply y-pos by 8
                asl a
                asl a
                clc
                sta Temp
                txa
                adc Temp              ; add x-pos to calculate offset
                adc #<PlayField       ; add offset to start of playfield
                sta PlayFieldAddr
                lda #>PlayField
                sta PlayFieldAddr+1
        rts
.endproc

;********************************************************************************
; checkMatches
;
; check for matches around a target gem.
;
; input:
; * CurrentGem: current gem number
; * X: directions to check (bit 0-3 represent: Left, Right, Up, Down. If set this direction is checked)
; output:
; * X: number of horizontal matches
; * Y: number of vertical matches
; * C: set if successful swap
;********************************************************************************
checkMatches .proc
        BackupPFA        = Temp0
        HorMatchAmount   = Temp1
        VerMatchAmount   = Temp2
                stz HorMatchAmount
                stz VerMatchAmount

                lda PlayFieldAddr
                sta BackupPFA

        ; check if target gem is the same as the current, if so we're done
                lda CurrentGem
                and #7
                eor (PlayFieldAddr)
                and #7
                bne checkLeft
                clc
                rts
        checkLeft
                txa
                and #CHECK_LEFT
                beq checkRight
                
                lda CurPosX
                beq checkRight
                dec PlayFieldAddr        ; move playfield addr to the left

                lda CurrentGem
                and #7
                eor (PlayFieldAddr)
                and #7
                bne checkRight
                inc HorMatchAmount
                lda (PlayFieldAddr)
                and #HORIZONTAL_MATCH
                beq checkRight
                inc HorMatchAmount
        checkRight
                lda BackupPFA                ; restore original playfield address
                sta PlayFieldAddr

                txa
                and #CHECK_RIGHT
                beq checkAbove

                lda CurPosX
                cmp #7                ; check if we're too far right
                beq checkAbove        ; if so we still need to check for vertical match
                lda CurrentGem
                and #7
                ldy #1
                eor (PlayFieldAddr),y
                and #7
                bne checkAbove        ; we didn't find a horizontal match try vertical
                inc HorMatchAmount
                lda (PlayFieldAddr),y
                and #HORIZONTAL_MATCH
                beq checkAbove
                inc HorMatchAmount
        checkAbove
                lda BackupPFA                ; restore original playfield address
                sta PlayFieldAddr

                txa
                and #CHECK_UP
                beq checkBelow
                lda CurPosY
                beq checkBelow
                sec
                lda PlayFieldAddr
                sbc #8
                sta PlayFieldAddr
                lda (PlayFieldAddr)
                and #7
                eor CurrentGem
                and #7
                bne checkBelow
                inc VerMatchAmount
                lda (PlayFieldAddr)
                and #VERTICAL_MATCH
                beq checkBelow
                inc VerMatchAmount
        checkBelow
                txa
                and #CHECK_DOWN
                beq checkMatch
                
                lda BackupPFA                ; restore original playfield address
                sta PlayFieldAddr
                lda CurPosY
                cmp #7
                beq checkMatch
                ldy #8
                lda CurrentGem
                and #7
                eor (PlayFieldAddr),y
                and #7
                bne checkMatch
                inc VerMatchAmount
                lda (PlayFieldAddr),y
                and #VERTICAL_MATCH
                beq checkMatch
                inc VerMatchAmount
        checkMatch
                ldx HorMatchAmount
                ldy VerMatchAmount
                cpx #2
                bge found
                cpy #2
                blt notFound
        found
                sec
                rts
        notFound
                clc
                rts
.endproc

;********************************************************************************
; generateNew
;
; Generate new playfield without any matches.
;
; input:
; output:
;********************************************************************************
generateNew .proc
                lda #7
                jsr rnd.init                        ;Galois24o

                lda #<PlayFieldEnd-1
                sta PlayFieldAddr
                lda #>PlayFieldEnd-1
                sta PlayFieldAddr+1

                ldx #64
        loop
                stz Temp                          ; intialize Temp
                jsr rnd.generate                  ; get random number
                sta (PlayFieldAddr)               ; store gem number in current gem position
                ; jmp endMatching                 ; uncomment to see playfield without unmatching

                jsr checkHorizontalMatch
                bcs noHorizontalMatch             ; no horizontal match, go check vertical match
                bne unmatchGem                    ; z is set, which means that we neighbour a second consecutive match, so unmatch
                jsr setHorizontalMatchBits        ; out neighbour is the first match, so set match bits
        noHorizontalMatch
                jsr checkVerticalMatch
                bcs endMatching                   ; no vertical match so we're done
                bne unmatchGem                    ; z is set, see above
                jsr setVerticalMatchBits          ; see above
                bra endMatching
        unmatchGem
                ; we have a matching gem pair below or to the right so we increase the current gem number
                jsr increaseGemNumber
                ; check if the unmatch was triggered by a horizontal match, if so check if we created a new vertical match and fix if needed
                bbr HORIZONTAL_MATCH_B, Temp, recheckVertical 
                jsr checkVerticalMatch            ; we did unmatch a horizontal match, so check if we created a new vertical match
                bcs recheckVertical               ; we didn't introduce a new vertical match, so go recheck potential vertical match
                bne +
                jsr setVerticalMatchBits          ; we have a match and it is our first vertical (z is set), set bits
                bra recheckVertical
        +
                jsr increaseGemNumber             ; we have a match and it's the third vertical so increase gem number one more
        recheckVertical
                bbr VERTICAL_MATCH_B, Temp, endMatching
                jsr checkHorizontalMatch
                bcs endMatching                   ; we didn't introduce a new horizontal match so we're done
                bne +
                jsr setHorizontalMatchBits        ; we have a match and it is our first horizontal (z is set), set bits
                bra endMatching
        +
                jsr increaseGemNumber             ; we have a match and it's the third horizontal so increase gem number one more
        endMatching
                ; we're done matching let's do next gem
                dec PlayFieldAddr
                dex
                bne loop
	rts
.endproc

;********************************************************************************
; setHorizontalMatchBits
;
; Sets the horizontal match bit of the current gem and it's horizontal neighbour,
; to the right
;
; input:
; output:
;********************************************************************************
setHorizontalMatchBits .proc
                ; our match with the right neighbour is isolated, so we set involved match gem's bits
                lda #HORIZONTAL_MATCH
                ora (PlayFieldAddr)
                sta (PlayFieldAddr)
                lda #HORIZONTAL_MATCH
                ldy #OFF_GEM_RIGHT
                ora (PlayFieldAddr),y
                sta (PlayFieldAddr),y
        rts
.endproc

;********************************************************************************
; setVerticalMatchBits
;
; Sets the vertical match bit of the current gem and it's vertical neighbour, 
; below
;
; input:
; output:
;********************************************************************************
setVerticalMatchBits .proc
                ; our match with the below neighbour is isolated, so we set involved match gem's bits
                lda #VERTICAL_MATCH
                ora (PlayFieldAddr)
                sta (PlayFieldAddr)
                ldy #OFF_GEM_BELOW
                lda #VERTICAL_MATCH
                ora (PlayFieldAddr),y
                sta (PlayFieldAddr),y
        rts
.endproc

;********************************************************************************
; increaseGemNumber
;
; input:
; output:
;********************************************************************************
increaseGemNumber .proc
                lda (PlayFieldAddr)
                inc a                         ; increase gem number to no long match
                and #7                        ; roll-over if needed
                sta (PlayFieldAddr)
        rts
.endproc

;********************************************************************************
; checkHorizontalMatch
;
; Checks for a horizontal match with the neighbour to the right.
;
; clobbers:
;   A, Y
; input:
;   X: current gem position
;   Temp: current match bits
; output:
;   c: 0 if match found
;   z: 0 if first match
;   Temp: new match bits
;********************************************************************************
checkHorizontalMatch .proc
                ; check for right most position, no gem to check to the right...
                txa
                and #$7                           ; check if our counter (x) is a multiple of 8 so right most
                beq noMatch                       ; we still want to check for a vertical match below
                lda (PlayFieldAddr)               ; restore gem number and check for match with gem to the right
                ldy #OFF_GEM_RIGHT
                eor (PlayFieldAddr),y
                and #7
                bne noMatch                       ; no horizontal match so we check vertical
                ; check for match amount for gem to the right
                lda #HORIZONTAL_MATCH             ; bit indicating horizontal match between two gems
                ora Temp
                sta Temp                          ; add match bit to Temp, so we can use that later to check for matches
                and (PlayFieldAddr),y             ; set z if our neighbour already was a match, else this is the first match
                clc                               ; clear c to indicate a match
                rts
noMatch
                sec                               ; set c to indicate no match
        rts
.endproc

;********************************************************************************
; checkVerticalMatch
;
; Checks for a vertial match with the neighbour below.
;
; clobbers:
;   A, Y
; input:
;   X: current gem position
;   Temp: current match bits
; output:
;   c: 0 if match found
;   z: 0 if first match
;   Temp: new match bits
;********************************************************************************
checkVerticalMatch .proc
                cpx #57                           ; check if we're on the bottom row, if so, no vertical matching is needed
                blt notBottomRow
                bra noMatch                       ; if >= 56, we're in the bottom row so no lower matches possible, but maybe horizontal
        notBottomRow
                ldy #OFF_GEM_BELOW
                lda (PlayFieldAddr)
                eor (PlayFieldAddr),y
                and #7
                bne noMatch
                lda #VERTICAL_MATCH               ; bit indicating vertical match between two gems
                ora Temp
                sta Temp                          ; add match bit to Temp, so we can use that later to check for matches
                lda #VERTICAL_MATCH
                and (PlayFieldAddr),y             ; set z if our neighbour already was a match, else this is the first match
                clc                               ; clear c to indicate a match
                rts
noMatch
                sec                               ; set c to indicate no match
        rts
.endproc

;********************************************************************************
; updateTileMap
;
; Updates the tile mape with the current playfield.
;
; input:
; output:
;********************************************************************************
updateTileMap .proc
                ; Create tilemap for PlayField                
                ; setup mmu for tile map access
                #system.setMMU 1, 8
                lda #<PlayField
                sta PlayFieldAddr
                lda #>PlayField
                sta PlayFieldAddr+1
                lda #(8*TileMapXSize)+14
                sta TileAddr
                lda #$25
                sta TileAddr+1

                ldx #8
        rowLoop
                ldy #0
        colLoop
                lda (PlayFieldAddr)
                and #7
                clc
                adc #80
                sta (TileAddr),y
                lda #0
                iny
                sta (TileAddr),y
                inc PlayFieldAddr
                iny
                cpy #16
                bne colLoop
                clc
                lda TileAddr
                adc #42
                sta TileAddr
                lda TileAddr+1
                adc #0
                sta TileAddr+1
                dex
                bne rowLoop
                #system.resetMMU 1
	rts
.endproc ; updateTileMap

;********************************************************************************
; displayScore
;
; Displays the current score.
;
; input:
; output:
;********************************************************************************
displayScore .proc
        ScorePtr = Temp0
                ; setup mmu for tile map access
                #system.setMMU 1, 8

                stz TileAddr        ; set TileAddr to start of playfield (top-left)
                lda #$25
                sta TileAddr+1

                ldx #4              ; 4 sets of two digits
                ldy #2              ; x-position of start of score (2 bytes per tile)
                lda #Score3         ; get address of highest score value
                sta ScorePtr        ; store in ScorePtr
                stz ScorePtr+1
        loop                        ; we'll loop over --x and display two digits (bcd => two digits per byte)
                lda (ScorePtr)      ; load score digits (2)
                lsr                 ; shift 4 to right to get the high nibble (the highest digit of the score)
                lsr
                lsr
                lsr
                clc
                adc #$10            ; add $10 which is the offset to the 0 character tile
                sta (TileAddr),y    ; store at position y (display at position Y)
                iny                 ; move to next tile position
                iny
                lda (ScorePtr)      ; reload score digits 
                and #$F             ; mask of all but first 4 bits (the lower nibble of the score byte)
                clc
                adc #$10            ; add $10 again
                sta (TileAddr),y
                iny                 ; increase y position to next tile
                iny
                dec ScorePtr        ; decrease ScorePtr to point to the next lower digits of score
                dex                 ; decrease loop counter
                bne loop
                #system.resetMMU 1
        rts
.endproc

.endsection 	; yam3g
.endnamespace 	; playfield
.endnamespace	; yam3g