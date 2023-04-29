.cpu "65c02"

yam3g       .namespace

TileMapXSize = 21
TileMapYSize = 15

PlayFieldXSize = 8
PlayFieldYSize = 8

musicPlay = Music + 3

; Located in High Memory since Vicky can Reference them directly.

.section tilelayer0
        .include "../tile_data/layer1.txm"
.send

.section tilelayer1
        .include "../tile_data/layer2.txm"
.send

.section tilelayer2
         .include "../tile_data/layer3.txm"
.send

.section tilesetdata
          .binary "../tile_data/tileset.bin"
.send

.section tilesetpalette
TileMapPalette	     .binary "../tile_data/tileset.pal.bin"
.send

; Start of actual yam3g code

.section dp
L0ScrollXL      .byte 0
L0ScrollXH      .byte 0
L1ScrollXL      .byte 0
L1ScrollXH      .byte 0
L2ScrollXL      .byte 0
L2ScrollXH      .byte 0
L2VXLO          .byte 0
L2VXHI          .byte 0
L2SLINE         .byte 0
.send

.section        yam3g

start
                jsr system.setIOPage0

                stz io.joy.VIA0_DRB    ; Make Sure the VIA is in Read Mode for the Joystick 
                stz io.joy.VIA0_DRA    ; Make Sure the VIA is in Read Mode for the Joystick

                ; put some values in the LUT for graphic use
                ; Go in Page 1 to Setup LUT
                jsr system.setIOPage1
        
                ldx #00
setLUT0_4_Tiles
                lda TileMapPalette,x
                sta vky.LUT0,x
                inx
                bne setLUT0_4_Tiles
setLUT0_4_Tiles2
                lda TileMapPalette+$100,x
                sta vky.LUT0+$100,x
                inx
                cpx #$F0
                bne setLUT0_4_Tiles2
                
                ; Go in Page 0 to program the rest
                jsr system.SetIOPage0

                ; Set the Tile Layer Map 0 Pointer
                lda #<TileMapLayer0
                sta vky.tile.T0_START_ADDY_L
                lda #>TileMapLayer0
                sta vky.tile.T0_START_ADDY_M
                lda #`TileMapLayer0
                sta vky.tile.T0_START_ADDY_H

                ; Set the Tile Layer Map 1 Pointer
                lda #<TileMapLayer1
                sta vky.tile.T1_START_ADDY_L
                lda #>TileMapLayer1
                sta vky.tile.T1_START_ADDY_M
                lda #`TileMapLayer0
                sta vky.tile.T1_START_ADDY_H

                ; Set the Tile Layer Map 2 Pointer
                lda #<TileMapLayer2
                sta vky.tile.T2_START_ADDY_L
                lda #>TileMapLayer2
                sta vky.tile.T2_START_ADDY_M
                lda #`TileMapLayer2
                sta vky.tile.T2_START_ADDY_H

                ;Now Set the Size of the MAP itself
                lda #<TileMapXSize
                sta vky.tile.T0_MAP_X_SIZE_L
                sta vky.tile.T1_MAP_X_SIZE_L
                sta vky.tile.T2_MAP_X_SIZE_L
                lda #>TileMapXSize
                sta vky.tile.T0_MAP_X_SIZE_H
                sta vky.tile.T1_MAP_X_SIZE_H
                sta vky.tile.T2_MAP_X_SIZE_H
                lda #<TileMapYSize
                sta vky.tile.T0_MAP_Y_SIZE_L
                sta vky.tile.T1_MAP_Y_SIZE_L
                sta vky.tile.T2_MAP_Y_SIZE_L
                lda #>TileMapYSize
                sta vky.tile.T0_MAP_Y_SIZE_H
                sta vky.tile.T1_MAP_Y_SIZE_H
                sta vky.tile.T2_MAP_Y_SIZE_H

                ; now Let's setup the Window Position
                lda #$08
                sta vky.tile.T0_MAP_X_POS_L
                lda #$00
                sta vky.tile.T1_MAP_X_POS_L
                sta vky.tile.T2_MAP_X_POS_L
                lda #$00    ; The position of the Window looking in to the MAP is 1 (X)
                sta vky.tile.T0_MAP_X_POS_H
                sta vky.tile.T1_MAP_X_POS_H
                sta vky.tile.T2_MAP_X_POS_H
                lda #$00
                sta vky.tile.T0_MAP_Y_POS_L
                sta vky.tile.T1_MAP_Y_POS_L
                sta vky.tile.T2_MAP_Y_POS_L
                lda #$00
                sta vky.tile.T0_MAP_Y_POS_H
                sta vky.tile.T1_MAP_Y_POS_H
                sta vky.tile.T2_MAP_Y_POS_H

                ; Now let's setup the different Tile Set Graphics Location
                ; We are in 16x16 Mode, so 1x TileSet is 65536bytes. (64K)
                lda #<TileSet0Data
                sta vky.tile.GRP_ADDY0_L
                lda #>TileSet0Data
                sta vky.tile.GRP_ADDY0_M
                lda #`TileSet0Data
                sta vky.tile.GRP_ADDY0_H

                ; let's setup the attributes for each graphic sets
                lda #vky.tile.DIM_256x256     ; (bit[3] set) The tile set is a 256x256 Graphic Block
                sta vky.tile.GRP_ADDY0_CFG

                lda #vky.tile.ENABLE     ; (bit[0] set), (bit[4] Clear = 16x16 Mode)
                sta vky.tile.T0_CONTROL_REG  ; Enable Layer0
                sta vky.tile.T1_CONTROL_REG  ; Enable Layer1
                sta vky.tile.T2_CONTROL_REG  ; Enable Layer2

                ; generate random tiles for map 1
        .block
                lda #$99
                sta rnd.seed 
                sta rnd.seed+1 
                sta rnd.seed+2
                lda #<PlayField
                sta PlayFieldAddr
                lda #>PlayField
                sta PlayFieldAddr+1

                ldx #8
        rowLoop
                ldy #16
        colLoop
                phy
                jsr rnd.galois24o
                ply                
                lsr a
                lsr a
                lsr a
                lsr a
                lsr a
                sta (PlayFieldAddr),y
                ; jmp endMatching
                phy
                cpy #16
                beq noMatching
                ; check for horizontal match
                iny
                iny                          ; y + 2
                cmp (PlayFieldAddr),y        ; previous column
                bne noMatching
                iny                          ; y + 3
                lda (PlayFieldAddr),y        ; previous column match number
                ply
                cmp #1
                bne incColumnMatches
                lda (PlayFieldAddr),y                
                inc a
                and #7
                sta (PlayFieldAddr),y
                phy
                iny
                lda #0
                sta (PlayFieldAddr),y
                ply
                bra endMatching
        incColumnMatches
                phy
                iny
                inc a
                sta (PlayFieldAddr),y        ; store match number
                iny
                iny
                sta (PlayFieldAddr),y        ; store previous column match number
                ply
                bra endMatching
        noMatching
                ply
                ; set number of matches for current column
                lda #0
                iny
                sta (PlayFieldAddr),y
                dey
        endMatching
                dey
                dey
                bne colLoop
                clc
                lda PlayFieldAddr
                adc #16
                sta PlayFieldAddr
                dex
                bne rowLoop
        .bend

        .block
                ; Create tilemap for PlayField                
                ; setup mmu for tile map access
                #system.setMMU 1, 8
                lda #<PlayField
                sta PlayFieldAddr
                lda #>PlayField
                sta PlayFieldAddr+1
                lda #(8*TileMapXSize)+12
                sta TileAddr
                lda #$25
                sta TileAddr+1

                ldx #8
        rowLoop
                ldy #16
        colLoop
                lda #0
                sta (TileAddr+1),y
                lda (PlayFieldAddr),y
                adc #80
                sta (TileAddr),y
                dey
                dey
                bne colLoop
                clc
                lda PlayFieldAddr
                adc #16
                sta PlayFieldAddr
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
        .bend
                rts

                .section dp
TileAddr        .fill 2
PlayFieldAddr   .fill 2
                .send
                .section data
        .align $100
PlayField       .fill 130,0
                .send
InterruptHandlerJoystick:

                ; Clear Interrupt Pending Register for SOF
                lda #interrupt.JR0_INT00_SOF
                bit interrupt.PENDING_REG0
                beq +
                sta interrupt.PENDING_REG0
                jsr musicPlay

                lda io.joy.VIA0_IRB    ; Read VIA Port B to get Joystick Value
                and #$1F        ; Remove Unwanted bits
                cmp #$1F        ; Any movement at all?
                bne joystickNotDone
                lda #$00
                sta io.joy.CNT_0
        +
                rts

joystickNotDone
                nop 

joystickDoneNow
                lda io.joy.VIA0_IRB
                sta io.joy.VAL
                and #$04              ; Check what value is cleared
                cmp #$00
                beq forwardX

                lda io.joy.VAL
                and #$08
                cmp #$00
                beq backwardX

                lda io.joy.VAL
                and #$01
                cmp #$00
                bne joystickDone

joystickDone
                lda #$00
                sta io.joy.CNT_0
                rts 

forwardX      
                ;cmp #$FE
                ;beq joystickDone

                lda L0ScrollXL
                clc
                adc #4
                sta L0ScrollXL
                sta vky.tile.T0_MAP_X_POS_L
                lda L0ScrollXH
                adc #0
                sta L0ScrollXH
                sta vky.tile.T0_MAP_X_POS_H

                lda L1ScrollXL
                clc
                adc #3
                sta L1ScrollXL
                sta vky.tile.T1_MAP_X_POS_L
                lda L1ScrollXH
                adc #0
                sta L1ScrollXH
                sta vky.tile.T1_MAP_X_POS_H

                lda L2ScrollXL
                clc
                adc #1;L2VX
                sta L2ScrollXL
                ; sta vky.tile.T2_MAP_X_POS_L
                lda L2ScrollXH
                adc #0
                sta L2ScrollXH
                ; sta vky.tile.T2_MAP_X_POS_H

                bra joystickDone

backwardX     
                lda L0ScrollXH
                bne scroll
                lda L0ScrollXL
                cmp #$00
                beq joystickDone
scroll
                lda L0ScrollXL
                sec
                sbc #4
                sta L0ScrollXL
                sta vky.tile.T0_MAP_X_POS_L
                lda L0ScrollXH
                sbc #0
                sta L0ScrollXH
                sta vky.tile.T0_MAP_X_POS_H

                lda L1ScrollXL
                sec
                sbc #3
                sta L1ScrollXL
                sta vky.tile.T1_MAP_X_POS_L
                lda L1ScrollXH
                sbc #0
                sta L1ScrollXH
                sta vky.tile.T1_MAP_X_POS_H

                lda L2ScrollXL
                sec
                sbc #1
                sta L2ScrollXL
                sta vky.tile.T2_MAP_X_POS_L
                lda L2ScrollXH
                sbc #0
                sta L2ScrollXH
                sta vky.tile.T2_MAP_X_POS_H
                jmp joystickDone

.send        ; end section yam3g
.endn        ; end namespace yam3g