;********************************************************************************
; yam3g.asm
;
; The 'root' file for the yam3g game logic.
;
; date:        2023-05-25
; created by:  PIG Games (Erik van der Tier)
; license:     MIT
;********************************************************************************

.cpu cpu_type

yam3g       .namespace

TileMapXSize = 21
TileMapYSize = 15
STATE_TITLE  = 00
STATE_MENU   = 01
STATE_GAME   = 02

; Located in High Memory since Vicky can Reference them directly.

.section tilelayer0

        TileMapLayer0 = d_tilelayer0
               .include "../tile_data/layer1.txm"

.endsection tilelayer0

.section tilelayer1

        TileMapLayer1 = d_tilelayer1
                .include "../tile_data/layer2.txm"

.endsection tilelayer1

.section tilelayer2

        TileMapLayer2 = d_tilelayer2
                .include "../tile_data/layer3.txm"

.endsection tilelayer2

.section tilesetdata

        TileSet0Data = d_tilesetdata
                .binary "../tile_data/tileset.bin"

.endsection tilesetdata

.section spritedata

        SpriteData = d_spritedata
                .binary "../tile_data/cursor.bin"

.endsection spritedata

.section tilesetpalette

        TileMapPalette        .binary "../tile_data/tileset.pal.bin"

.endsection tilesetpalette

; Start of actual yam3g code

.section dp
        State           .byte 0
        JoyWait         .byte 0        
        CurPosX         .byte 0
        CurPosY         .byte 0
        ButtonStatus    .byte 0
        HorizontalMatchTotal    .byte 0
        VerticalMatchTotal      .byte 0
        Score0          .byte 0
        Score1          .byte 0
        Score2          .byte 0
        Score3          .byte 0
        Temp0           .byte 0
        Temp1           .byte 0
        Temp2           .byte 0
        Temp3           .byte 0
        Temp4           .byte 0
.endsection dp

.section yam3g

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
                jsr system.setIOPage0

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

                lda #STATE_TITLE
                jsr changeState
                
        rts

changeState .proc
                sta State
                bne checkMenu
                jsr title.init
                rts
        checkMenu
                cmp #STATE_MENU
                bne checkGame
                jsr menu.init
                rts
        checkGame
                jsr game.init
        rts
.endproc

InterruptHandlerJoystick .block

                ; Clear Interrupt Pending Register for SOF
                lda #interrupt.JR0_INT00_SOF
                bit interrupt.PENDING_REG0
                beq done
                sta interrupt.PENDING_REG0
                jsr music.play
                lda JoyWait
                beq +
                dec JoyWait
                bra done
        +
                lda #8
                sta JoyWait
                lda io.joy.VIA0_IRB     ; Read VIA Port B to get Joystick Value
                eor #$FF                ; flip bits
                and #$7F                ; Remove Unwanted bits
                sta io.joy.VAL
                bne process             ; if not zero, there is some joy activity
                stz JoyWait
        done
                rts

        process
                lda State
                bne checkMenu
                pha
                jsr title.processJoystick
                pla
                rts
        checkMenu
                cmp #STATE_MENU
                bne checkGame
                pha
                jsr menu.processJoystick
                pla
                rts
        checkGame
                pha
                jsr game.processJoystick
                pla
        end
                rts 

.bend        ; end block 

.endsection yam3g
.endnamespace ; yam3g