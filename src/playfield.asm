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

generateNew .proc
                lda #4
                jsr rnd.initGalois24o

                lda #<PlayFieldEnd-1
                sta PlayFieldAddr
                lda #>PlayFieldEnd-1
                sta PlayFieldAddr+1

                ldx #64
        loop                        ; TODO: create separate matching routines, so we can easily cross check
                ; get random number
                jsr rnd.generateGalois24o
                stz Temp
                ; store in current gem position
                sta (PlayFieldAddr)
                ; jmp endMatching

                jsr checkHorizontalMatch
                bcs checkVertical
                bne unmatchGem
                bra incMatchAmount
        checkVertical
                jsr checkVerticalMatch
                bcs noMatch
                beq incMatchAmount
        unmatchGem
                ; we have a matching gem pair below or to the right so we increase the current gem number
                lda (PlayFieldAddr)
                inc a                         ; increase gem number to no long match
                and #7                        ; roll-over if needed
                sta (PlayFieldAddr)
                ; check if the unmatch was triggered by a horizontal match, if so check if we created a new vertical match and fix if needed
                ; lda Temp
                ; bit #HORIZONTAL_MATCH
                ; beq checkVertical
                bra endMatching                
        incMatchAmount
                ; our match with the right neighbour is isolated, so we set involved match gem's amounts to 1
                lda Temp
                ora (PlayFieldAddr)
                sta (PlayFieldAddr)
                bit #HORIZONTAL_MATCH
                beq verticalMatch
                lda #HORIZONTAL_MATCH
                ldy #OFF_GEM_RIGHT
                ora (PlayFieldAddr),y
                sta (PlayFieldAddr),y
        verticalMatch
                lda Temp
                bit #VERTICAL_MATCH
                beq endMatching
                ldy #OFF_GEM_BELOW
                lda #VERTICAL_MATCH
                ora (PlayFieldAddr),y
                sta (PlayFieldAddr),y
                bra endMatching
        noMatch
                ; no match we set the current gem's match amount to 0
                lda #~(VERTICAL_MATCH | HORIZONTAL_MATCH)
                and (PlayFieldAddr)
                sta (PlayfieldAddr)
        endMatching
                ; we're done matching let's do next gem
                dec PlayFieldAddr
                dex
                bne loop
	rts
.endproc

;********************************************************************************
; checkHorizontalMatch
;
; input:
;   A: current gem value
;   X: current gem position
;   Temp: current match bits
; output:
;   c: 0 if match found
;   Temp: match bits
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
                sta Temp
                and (PlayFieldAddr),y
                ; beq noMatch
                clc
                rts
noMatch
                sec
                rts
.endproc

;********************************************************************************
; checkVerticalMatch
;
; input:
;   A: current gem value
;   X: current gem position
;   Temp: current match bits
; output:
;   c: 0 if match found
;   z: 0 if first match
;   Temp: match bits
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
                sta Temp                          ; store for match processing
                lda #VERTICAL_MATCH
                and (PlayFieldAddr),y             ; if 0, we have our first match
match
                clc
                rts
noMatch
                sec
                rts
.endproc

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