;********************************************************************************
; init.asm
;
; Routines for the initialisation of the system.
;
; date:        2023-05-29
; created by:  PIG Games (Erik van der Tier)
; license:     MIT
;********************************************************************************

.cpu cpu_type

init		.namespace
.section init
; --- LET'S BEGIN --- 
		jsr system.setIOPage0		; The Color LUT for the Text Mode is in Page 0
                jsr audio.initCodec		; Make sure to setup the CODEC Very early
                jsr audio.mutePSG
		jsr yam3g.music.init
		; lda #1
  ;               jsr yam3g.music.InitSIDAddr
                ; Init Devices      ; Let's Init the Keyboard first
		jsr system.setIOPage0
                lda #$00 
                sta $D6E0           ; We don't need the mouse      

                lda #( vky.mctrl.SPRITE_EN | vky.mctrl.GRAPH_MODE_EN  | vky.mctrl.TILEMAP_EN )
                sta vky.mctrl.REG_L
                
                lda #$00
                sta vky.mctrl.REG_H
                lda #$00
                sta vky.border.CTRL_REG
                lda #$0
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

                jsr yam3g.initGameLoop

                ; Enable the SOF interrupt
                cli 
                lda interrupt.MASK_REG0
                and #~interrupt.JR0_INT00_SOF
                sta interrupt.MASK_REG0
DONE	        bra DONE

.endsection init
.endnamespace ; init
