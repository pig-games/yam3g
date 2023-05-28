audio		.namespace
.section	audio

PSG_INT_L_PORT = $D600          ; Control register for the SN76489
PSG_INT_R_PORT = $D610          ; Control register for the SN76489

; CODEC 
CODEC_LOW        = $D620
CODEC_HI         = $D621
CODEC_CTRL       = $D622

;/////////////////////////
;// CODEC
;/////////////////////////
initCodec .proc
            ;                LDA #%00011010_00000000     ;R13 - Turn On Headphones
            lda #%00000000
            sta CODEC_LOW
            lda #%00011010
            sta CODEC_HI
            lda #$01
            sta CODEC_CTRL ; 
            jsr CODEC_WAIT_FINISH
            ; LDA #%0010101000000011       ;R21 - Enable All the Analog In
            lda #%00000011
            sta CODEC_LOW
            lda #%00101010
            sta CODEC_HI
            lda #$01
            sta CODEC_CTRL ; 
            jsr CODEC_WAIT_FINISH
            ; LDA #%0010001100000001      ;R17 - Enable All the Analog In
            lda #%00000001
            sta CODEC_LOW
            lda #%00100011
            sta CODEC_HI
            lda #$01
            sta CODEC_CTRL ; 
            jsr CODEC_WAIT_FINISH
            ;   LDA #%0010110000000111      ;R22 - Enable all Analog Out
            lda #%00000111
            sta CODEC_LOW
            lda #%00101100
            sta CODEC_HI
            lda #$01
            sta CODEC_CTRL ; 
            jsr CODEC_WAIT_FINISH
            ; LDA #%0001010000000010      ;R10 - DAC Interface Control
            lda #%00000010
            sta CODEC_LOW
            lda #%00010100
            sta CODEC_HI
            lda #$01
            sta CODEC_CTRL ; 
            jsr CODEC_WAIT_FINISH
            ; LDA #%0001011000000010      ;R11 - ADC Interface Control
            lda #%00000010
            sta CODEC_LOW
            lda #%00010110
            sta CODEC_HI
            lda #$01
            sta CODEC_CTRL ; 
            jsr CODEC_WAIT_FINISH
            ; LDA #%0001100111010101      ;R12 - Master Mode Control
            lda #%01000101
            sta CODEC_LOW
            lda #%00011000
            sta CODEC_HI
            lda #$01
            sta CODEC_CTRL ; 
            jsr CODEC_WAIT_FINISH
            rts
.endproc

CODEC_WAIT_FINISH
CODEC_Not_Finished .proc
            lda CODEC_CTRL
            and #$01
            cmp #$01 
            beq CODEC_Not_Finished
            rts
.endproc
;
; Turn off both PSG "chips"
;
mutePSG .proc
            	jsr system.setIOPage0
            	lda #$9f            ; Mute channel #0 (1001111)
            	sta PSG_INT_L_PORT
            	sta PSG_INT_R_PORT

            	lda #$bf            ; Mute channel #2 (1011111)
            	sta PSG_INT_L_PORT
            	sta PSG_INT_R_PORT

            	lda #$df            ; Mute channel #3 (1101111)
            	sta PSG_INT_L_PORT
            	sta PSG_INT_R_PORT

            	lda #$ff            ; Mute channel #4 (1111111)
            	sta PSG_INT_L_PORT
            	sta PSG_INT_R_PORT
            	rts
.endproc
.send ; end section audio
.endn ; end namespace audio
