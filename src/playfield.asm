.namespace	yam3g
playfield	.namespace

PlayFieldXSize = 8
PlayFieldYSize = 8

HORIZONTAL_MATCH = %01000000
VERTICAL_MATCH   = %10000000
OFF_GEM_MN       = 1
OFF_GEM_RIGHT    = 2
OFF_GEM_RIGHT_MN = 3
OFF_GEM_BELOW    = 16
OFF_GEM_BELOW_MN = 17

.section	data
        .align $100
PlayField       .fill 128,0
PlayFieldEnd

.endsection

.section dp
	TileAddr        .fill 2
	PlayFieldAddr   .fill 2
	Temp            .byte 0
.endsection

.section	yam3g

generateNew     .proc
                lda #$65
                sta rnd.seed 
                sta rnd.seed+1 
                sta rnd.seed+2
                lda #<PlayFieldEnd-2
                sta PlayFieldAddr
                lda #>PlayFieldEnd
                sta PlayFieldAddr+1

                ldx #64
        loop
                ; get random number
                jsr rnd.galois24o
                stz Temp
                ; store in current gem position
                sta (PlayFieldAddr)
                ; check for right most position, no gem to check to the right...
                txa
                and #$7                           ; check if our counter (x) is a multiple of 8 so right most
                beq checkVertical                 ; we still want to check for a vertical match below
                ; restore gem number and check for match with gem to the right
                lda (PlayFieldAddr)
                ldy #OFF_GEM_RIGHT
                cmp (PlayFieldAddr),y
                bne checkVertical                 ; no horizontal match so we check vertical
                ; check for match amount for gem to the right
                ldy #OFF_GEM_RIGHT_MN
                lda #HORIZONTAL_MATCH             ; bit indicating horizontal match between two gems
                sta Temp                          ; store for match processing, later on
                and (PlayFieldAddr),y
                beq checkVertical
                bra unmatchGem
        checkVertical
                cpx #57                           ; check if we're on the bottom row, if so no vertical matching is needed
                bcc +
                lda Temp                          ; no horizontal match so we're done
                beq noMatch
                bra incMatchAmount                ; if >= 56, we're in the bottom row so no lower matches possible, but maybe horizontal
        + 
                ldy #OFF_GEM_BELOW
                lda (PlayFieldAddr)
                cmp (PlayFieldAddr),y
                bne incMatchAmount
                ldy #OFF_GEM_BELOW_MN
                lda #VERTICAL_MATCH               ; bit indicating vertical match between two gems
                ora Temp
                sta Temp                          ; store for match processing
                lda #VERTICAL_MATCH
                and (PlayFieldAddr),y
                beq incMatchAmount
        unmatchGem
                ; we have a matching gem pair below or to the right so we increase the current gem number
                lda (PlayFieldAddr)
                inc a                         ; increase gem number to no long match
                and #7                        ; roll-over if needed
                sta (PlayFieldAddr)           ; store new gem value
                ; set current gem match amount to 0
                lda #0
                ldy #OFF_GEM_MN
                sta (PlayFieldAddr),y
                bra endMatching                
        incMatchAmount
                ; our match with the right neighbour is isolated, so we set involved match gem's amounts to 1
                ldy #OFF_GEM_MN
                lda Temp
                sta (PlayFieldAddr),y
                bit #HORIZONTAL_MATCH
                beq verticalMatch
                ldy #OFF_GEM_RIGHT_MN
                lda #HORIZONTAL_MATCH
                ora (PlayFieldAddr),y
                sta (PlayFieldAddr),y
        verticalMatch
                lda Temp
                bit #VERTICAL_MATCH
                beq endMatching
                ldy #OFF_GEM_BELOW_MN
                lda #VERTICAL_MATCH
                ora (PlayFieldAddr),y
                sta (PlayFieldAddr),y
                bra endMatching
        noMatch
                ; no match we set the current gem's match amount to 0
                lda #0
                ldy #OFF_GEM_MN
                sta (PlayfieldAddr),y
        endMatching
                ; we're done matching let's do next gem
                dec PlayFieldAddr
                dec PlayFieldAddr
                dex
                bne loop
		rts
        .endproc

updateTileMap   .proc
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
                clc
                adc #80
                sta (TileAddr),y
                lda #0
                iny
                sta (TileAddr),y
                dey
                inc PlayFieldAddr
                inc PlayFieldAddr
                iny
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