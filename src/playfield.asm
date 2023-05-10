;********************************************************************************
; playfield.asm
;
; Routines for generation and manipulation of YAM3G playfields.
;
; date:        2023-05-10
; created by:  PIG Games (Erik van der Tier)
; license:     MIT
;********************************************************************************
.namespace	yam3g
playfield	.namespace

PlayFieldXSize = 8
PlayFieldYSize = 8

HORIZONTAL_MATCH = %01000000
VERTICAL_MATCH   = %10000000
OFF_GEM_MN       = 0
OFF_GEM_RIGHT    = 1
OFF_GEM_BELOW    = 8

.section data
        .align $100
	PlayField       .fill 64,0
	PlayFieldEnd
.endsection

.section dp
	TileAddr        .fill 2
	PlayFieldAddr   .fill 2
	Temp            .byte 0
.endsection

.section yam3g

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
                lda Temp
                bit #HORIZONTAL_MATCH
                beq recheckVertical               ; we didn't have a horizontal match, but may have had a vertical match so recheck on that
                jsr checkVerticalMatch            ; we did unmatch a horizontal match, so check if we created a new vertical match
                bcs recheckVertical               ; we didn't introduce a new vertical match, so go recheck potential vertical match
                bne +
                jsr setVerticalMatchBits          ; we have a match and it is our first vertical (z is set), set bits
                bra recheckVertical
        +
                jsr increaseGemNumber             ; we have a match and it's the third vertical so increase gem number one more
        recheckVertical
                lda Temp
                bit #VERTICAL_MATCH
                beq endMatching                   ; we didn't have a horizontal match, so we're really done here
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
                bcc notBottomRow
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

.endsection 	; yam3g
.endnamespace 	; playfield
.endnamespace	; yam3g