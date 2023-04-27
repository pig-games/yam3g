init		.namespace
.section init
; --- LET'S BEGIN --- 
		jsr system.setIOPage0		; The Color LUT for the Text Mode is in Page 0
                jsr display.tinyVkyInit
                jsr audio.initCodec		; Make sure to setup the CODEC Very early
                jsr audio.mutePSG
		jsr Music
		jsr display.initTextLUT	; Init the Text Color Table                      
                ; Set the Backgroud Color
		jsr system.setIOPage3		;
                jsr display.fillColor                
                ; Fill the Screen with Spaces
                jsr system.setIOPage2		;
                jsr display.clearScreen    ;
                ; Display Something on Screen
                ; jsr display.splashText
		jsr system.setIOPage0
                ; Init Devices      ; Let's Init the Keyboard first
		jsr system.setIOPage0
                lda #$00 
                sta $D6E0           ; We don't need the mouse      

                ; VICKY - Bitmap Code test
                lda #( vky.mctrl.GRAPH_MODE_EN  | vky.mctrl.TILEMAP_EN | vky.mctrl.TEXT_MODE_EN | vky.mctrl.TEXT_OVERLAY )
                sta vky.mctrl.REG_L
                
                lda #$00
                sta vky.mctrl.REG_H
                lda #$00
                sta vky.border.CTRL_REG
                lda #$20
                sta vky.BACKGROUND_COLOR_B
                stz vky.BACKGROUND_COLOR_G
                sta vky.BACKGROUND_COLOR_R

                jsr system.setIOPage0
                ; These are to setup the Layer Attributes
                ; Full on 3 Layers of Tiles
                lda #$54
                sta vky.layer.CTRL_REG0
                lda #$06
                sta vky.layer.CTRL_REG1
                jsr yam3g.start

                ; Enable the SOF interrupt
                cli 
                lda interrupt.MASK_REG0
                and #~interrupt.JR0_INT00_SOF
                sta interrupt.MASK_REG0
DONE	        JMP DONE

.send ; end section init
.endn ; end namespace init
