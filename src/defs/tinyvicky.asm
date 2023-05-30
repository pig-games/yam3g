;Internal Tiny VICKY Registers and Internal Memory Locations (LUTs)
; IO Page 0

vky             .namespace

mctrl           .namespace

REG_L	                = $D000
;Control Bits Fields
        TEXT_MODE_EN            = $01       ; Enable the Text Mode
        TEXT_OVERLAY            = $02       ; Enable the Overlay of the text mode on top of Graphic Mode (the Background Color is ignored)
        GRAPH_MODE_EN           = $04       ; Enable the Graphic Mode
        BITMAP_EN               = $08       ; Enable the Bitmap Module In Vicky
        TILEMAP_EN              = $10       ; Enable the Tile Module in Vicky
        SPRITE_EN               = $20       ; Enable the Sprite Module in Vicky
        GAMMA_EN                = $40       ; this Enable the GAMMA correction - The Analog and DVI have different color value, the GAMMA is great to correct the difference
        DISABLE_VID             = $80       ; This will disable the Scanning of the Video hence giving 100% bandwith to the CPU
        REG_H                   = $D001
        VIDEO_MODE              = $01       ; 0 - 640x480@60Hz : 1 - 640x400@70hz (text mode) // 0 - 320x240@60hz : 1 - 320x200@70Hz (Graphic Mode & Text mode when Doubling = 1)
        TEXT_XDOUBLE            = $02       ; X Pixel Doubling
        TEXT_YDOUBLE            = $04       ; Y Pixel Doubling
        TURN_SYNC_OFF           = $08      ; 1 = Turn off Sync
        SHOW_BG_INOVERLAY       = $10   ; 1 = Allow the Background color to show up in Overlay mode
        FONT_BANK_SET           = $20  ; 0 =(default) FONT Set 0, 1 = FONT Set 1
        
.endnamespace ; mctrl

sysctrl        .namespace
        LFSR_DATA_LO     = $D6A4
        LFSR_DATA_HI     = $D6A5
        LFSR_CTRL        = $D6A6
        LFSR_ENABLE      = $01
        LFSR_SEED_WRITE  = $02
.endnamespace ; sysctrl

; Reserved - TBD
layer           .namespace
        CTRL_REG0                = $D002
        CTRL_REG1                = $D003
.endnamespace ; layer
 
border          .namespace
        CTRL_REG         = $D004 ; Bit[0] - Enable (1 by default)  Bit[4..6]: X Scroll Offset ( Will scroll Left) (Acceptable Value: 0..7)
        CTRL_ENABLE      = $01
        COLOR_B          = $D005
        COLOR_G          = $D006
        COLOR_R          = $D007
        X_SIZE           = $D008; X-  Values: 0 - 32 (Default: 32)
        Y_SIZE           = $D009; Y- Values 0 -32 (Default: 32)
.endnamespace ; border

; Reserved - TBD

        RESERVED_02         = $D00A
        RESERVED_03         = $D00B
        RESERVED_04         = $D00C

; Valid in Graphics Mode Only
        BACKGROUND_COLOR_B      = $D00D ; When in Graphic Mode, if a pixel is "0" then the Background pixel is chosen
        BACKGROUND_COLOR_G      = $D00E
        BACKGROUND_COLOR_R      = $D00F ;

; Cursor Registers
cursor        .namespace
        TXT_CTRL_REG = $D010   ;[0]  Enable Text Mode
        ENABLE       = $01
        FLASH_RATE0  = $02
        FLASH_RATE1  = $04
        TURNOFF_FLASH  = $08
        TXT_START_ADD_PTR   = $D011   ; This is an offset to change the Starting address of the Text Mode Buffer (in x)
        TXT_CHAR_REG = $D012
        TXT_COLR_REG = $D013
        TXT_X_REG_L  = $D014
        TXT_X_REG_H  = $D015
        TXT_Y_REG_L  = $D016
        TXT_Y_REG_H  = $D017
.endnamespace ; cursor

; Line Interrupt 
line_irq        .namespace
        CTRL_REG   = $D018 ;[0] - Enable Line 0 - WRITE ONLY
        CMP_VALUE_LO  = $D019 ;Write Only [7:0]
        CMP_VALUE_HI  = $D01A ;Write Only [3:0]
        PIXEL_X_POS_LO     = $D018 ; This is Where on the video line is the Pixel
        PIXEL_X_POS_HI     = $D019 ; Or what pixel is being displayed when the register is read
        Y_POS_LO      = $D01A ; This is the Line Value of the Raster
        Y_POS_HI      = $D01B ; 
.endnamespace ;line_irq

; Bitmap
        bitmap        .namespace
;BM0
        BM0_CTRL_REG       = $D100 
        BM0_Ctrl                = $01       ; Enable the BM0
        BM0_LUT0                = $02       ; LUT0
        BM0_LUT1                = $04       ; LUT1
        BM0_START_ADDY_L   = $D101
        BM0_START_ADDY_M   = $D102
        BM0_START_ADDY_H   = $D103
;BM1
        BM1_CTRL_REG       = $D108 
        BM1_Ctrl                = $01       ; Enable the BM0
        BM1_LUT0                = $02       ; LUT0
        BM1_LUT1                = $04       ; LUT1
        BM1_START_ADDY_L   = $D109
        BM1_START_ADDY_M   = $D10A
        BM1_START_ADDY_H   = $D10B
;BM2
        BM2_CTRL_REG       = $D110
        BM2_Ctrl                = $01       ; Enable the BM0
        BM2_LUT0                = $02       ; LUT0
        BM2_LUT1                = $04       ; LUT1
        BM2_LUT2                = $08       ; LUT2
        BM2_START_ADDY_L   = $D111
        BM2_START_ADDY_M   = $D112
        BM2_START_ADDY_H   = $D113
.endnamespace ; bitmap

; Tile Map 
tile        .namespace
        TL_CTRL0          = $D200 
; Bit Field Definition for the Control Register
        ENABLE             = $01
        SIZE               = $10   ; 0 -> 16x16, 0 -> 8x8

;
;Tile MAP Layer 0 Registers
        T0_CONTROL_REG         = $D200       ; Bit[0] - Enable, Bit[3:1] - LUT Select,
        T0_START_ADDY_L        = $D201       ; Not USed right now - Starting Address to where is the MAP
        T0_START_ADDY_M        = $D202
        T0_START_ADDY_H        = $D203
        T0_MAP_X_SIZE_L        = $D204       ; The Size X of the Map
        T0_MAP_X_SIZE_H        = $D205
        T0_MAP_Y_SIZE_L        = $D206       ; The Size Y of the Map
        T0_MAP_Y_SIZE_H        = $D207
        T0_MAP_X_POS_L         = $D208       ; The Position X of the Map
        T0_MAP_X_POS_H         = $D209
        T0_MAP_Y_POS_L         = $D20A       ; The Position Y of the Map
        T0_MAP_Y_POS_H         = $D20B
;Tile MAP Layer 1 Registers
        T1_CONTROL_REG         = $D20C       ; Bit[0] - Enable, Bit[3:1] - LUT Select,
        T1_START_ADDY_L        = $D20D       ; Not USed right now - Starting Address to where is the MAP
        T1_START_ADDY_M        = $D20E
        T1_START_ADDY_H        = $D20F
        T1_MAP_X_SIZE_L        = $D210       ; The Size X of the Map
        T1_MAP_X_SIZE_H        = $D211
        T1_MAP_Y_SIZE_L        = $D212       ; The Size Y of the Map
        T1_MAP_Y_SIZE_H        = $D213
        T1_MAP_X_POS_L         = $D214       ; The Position X of the Map
        T1_MAP_X_POS_H         = $D215
        T1_MAP_Y_POS_L         = $D216       ; The Position Y of the Map
        T1_MAP_Y_POS_H         = $D217
;Tile MAP Layer 2 Registers
        T2_CONTROL_REG         = $D218       ; Bit[0] - Enable, Bit[3:1] - LUT Select,
        T2_START_ADDY_L        = $D219       ; Not USed right now - Starting Address to where is the MAP
        T2_START_ADDY_M        = $D21A
        T2_START_ADDY_H        = $D21B
        T2_MAP_X_SIZE_L        = $D21C       ; The Size X of the Map
        T2_MAP_X_SIZE_H        = $D21D
        T2_MAP_Y_SIZE_L        = $D21E       ; The Size Y of the Map
        T2_MAP_Y_SIZE_H        = $D21F
        T2_MAP_X_POS_L         = $D220       ; The Position X of the Map
        T2_MAP_X_POS_H         = $D221
        T2_MAP_Y_POS_L         = $D222       ; The Position Y of the Map
        T2_MAP_Y_POS_H         = $D223

        DIM_256x256        = $08

        GRP_ADDY0_L    = $D280
        GRP_ADDY0_M    = $D281
        GRP_ADDY0_H    = $D282
        GRP_ADDY0_CFG  = $D283 

        GRP_ADDY1_L    = $D284
        GRP_ADDY1_M    = $D285
        GRP_ADDY1_H    = $D286
        GRP_ADDY1_CFG  = $D287

        GRP_ADDY2_L    = $D288
        GRP_ADDY2_M    = $D289
        GRP_ADDY2_H    = $D28A  
        GRP_ADDY2_CFG  = $D28B

        GRP_ADDY3      = $D28C
        GRP_ADDY4      = $D290
        GRP_ADDY5      = $D294
        GRP_ADDY6      = $D298
        GRP_ADDY7      = $D29C
.endnamespace ; tile

xymath        .namespace
        XYMATH_CTRL_REG     = $D300 ; Reserved
        XYMATH_ADDY_L       = $D301 ; W
        XYMATH_ADDY_M       = $D302 ; W
        XYMATH_ADDY_H       = $D303 ; W
        XYMATH_ADDY_POSX_L  = $D304 ; R/W
        XYMATH_ADDY_POSX_H  = $D305 ; R/W
        XYMATH_ADDY_POSY_L  = $D306 ; R/W
        XYMATH_ADDY_POSY_H  = $D307 ; R/W
        XYMATH_BLOCK_OFF_L  = $D308 ; R Only - Low Block Offset
        XYMATH_BLOCK_OFF_H  = $D309 ; R Only - Hi Block Offset
        XYMATH_MMU_BLOCK    = $D30A ; R Only - Which MMU Block
        XYMATH_ABS_ADDY_L   = $D30B ; Low Absolute Results
        XYMATH_ABS_ADDY_M   = $D30C ; Mid Absolute Results
        XYMATH_ABS_ADDY_H   = $D30D ; Hi Absolute Results
.endnamespace ; xymath

; Sprite Block0
sprite        .namespace
        ENABLE      = $01
        LUT0        = %00000000
        LUT1        = %00000010
        LUT2        = %00000100
        LUT3        = %00000110
        DEPTH_L3    = %00000000
        DEPTH_L2    = %00001000
        DEPTH_L1    = %00010000
        DEPTH_L0    = %00011000
        SIZE_32     = %00000000
        SIZE_24     = %00100000
        SIZE_16     = %01000000
        SIZE_8      = %01100000
        
        SP0_Ctrl           = $D900
        SP0_Addy_L         = $D901
        SP0_Addy_M         = $D902
        SP0_Addy_H         = $D903
        SP0_X_L            = $D904 
        SP0_X_H            = $D905 
        SP0_Y_L            = $D906  ; In the Jr, only the L is used (200 & 240)
        SP0_Y_H            = $D907  ; Always Keep @ Zero '0' because in Vicky the value is still considered a 16bits value
        
        SP1_Ctrl           = $D908
        SP1_Addy_L         = $D909
        SP1_Addy_M         = $D90A
        SP1_Addy_H         = $D90B
        SP1_X_L            = $D90C 
        SP1_X_H            = $D90D 
        SP1_Y_L            = $D90E  ; In the Jr, only the L is used (200 & 240)
        SP1_Y_H            = $D90F  ; Always Keep @ Zero '0' because in Vicky the value is still considered a 16bits value
        
        SP2_Ctrl           = $D910
        SP2_Addy_L         = $D911
        SP2_Addy_M         = $D912
        SP2_Addy_H         = $D913
        SP2_X_L            = $D914 
        SP2_X_H            = $D915 
        SP2_Y_L            = $D916  ; In the Jr, only the L is used (200 & 240)
        SP2_Y_H            = $D917  ; Always Keep @ Zero '0' because in Vicky the value is still considered a 16bits value
        
        SP3_Ctrl           = $D918
        SP3_Addy_L         = $D919
        SP3_Addy_M         = $D91A
        SP3_Addy_H         = $D91B
        SP3_X_L            = $D91C 
        SP3_X_H            = $D91D 
        SP3_Y_L            = $D91E  ; In the Jr, only the L is used (200 & 240)
        SP3_Y_H            = $D91F  ; Always Keep @ Zero '0' because in Vicky the value is still considered a 16bits value

        SP4_Ctrl           = $D920
        SP4_Addy_L         = $D921
        SP4_Addy_M         = $D922
        SP4_Addy_H         = $D923
        SP4_X_L            = $D924 
        SP4_X_H            = $D925 
        SP4_Y_L            = $D926  ; In the Jr, only the L is used (200 & 240)
        SP4_Y_H            = $D927  ; Always Keep @ Zero '0' because in Vicky the value is still considered a 16bits value
.endnamespace ; sprite

; PAGE 1
LUT0              = $D000 ; -$D000 - $D3FF
LUT1              = $D400 ; -$D400 - $D7FF
LUT2              = $D800 ; -$D800 - $DBFF
LUT3              = $DC00 ; -$DC00 - $DFFF


;DMA
dma        .namespace
        DMA_CTRL_REG        = $DF00
        DMA_CTRL_Enable     = $01
        DMA_CTRL_1D_2D      = $02
        DMA_CTRL_Fill       = $04
        DMA_CTRL_Int_En     = $08
        DMA_CTRL_NotUsed0   = $10
        DMA_CTRL_NotUsed1   = $20
        DMA_CTRL_NotUsed2   = $40
        DMA_CTRL_Start_Trf  = $80

        DMA_DATA_2_WRITE    = $DF01 ; Write Only
        DMA_STATUS_REG      = $DF01 ; Read Only
        DMA_STATUS_TRF_IP   = $80   ; Transfer in Progress
        DMA_RESERVED_0      = $DF02 
        DMA_RESERVED_1      = $DF03

        ; Source Addy
        DMA_SOURCE_ADDY_L   = $DF04
        DMA_SOURCE_ADDY_M   = $DF05
        DMA_SOURCE_ADDY_H   = $DF06
        DMA_RESERVED_2      = $DF07
        ; Destination Addy
        DMA_DEST_ADDY_L     = $DF08
        DMA_DEST_ADDY_M     = $DF09
        DMA_DEST_ADDY_H     = $DF0A
        DMA_RESERVED_3      = $DF0B
        ; Size in 1D Mode
        DMA_SIZE_1D_L       = $DF0C
        DMA_SIZE_1D_M       = $DF0D
        DMA_SIZE_1D_H       = $DF0E
        DMA_RESERVED_4      = $DF0F
        ; Size in 2D Mode
        DMA_SIZE_X_L        = $DF0C
        DMA_SIZE_X_H        = $DF0D
        DMA_SIZE_Y_L        = $DF0E
        DMA_SIZE_Y_H        = $DF0F
        ; Stride in 2D Mode
        DMA_SRC_STRIDE_X_L  = $DF10
        DMA_SRC_STRIDE_X_H  = $DF11
        DMA_DST_STRIDE_Y_L  = $DF12
        DMA_DST_STRIDE_Y_H  = $DF13

        DMA_RESERVED_5      = $DF14
        DMA_RESERVED_6      = $DF15
        DMA_RESERVED_7      = $DF16
        DMA_RESERVED_8      = $DF17
.endnamespace ; dma

.endnamespace ; vky
