display		.namespace		
.section 	display

tinyVkyInit
            	stz vky.mctrl.REG_L
            	rts
initCursor	.proc
		 
.endproc

initTextLUT     .block
		ldx #$00
loop0		lda FgColorLut,x		; get Local Data
                sta system.TEXT_LUT_FG,x	; Write in LUT Memory
                inx
                cpx #$40
                bne loop0
                ; set Background LUT Second
                ldx #$00
loop1		lda BgColorLut,x		; get Local Data
                sta system.TEXT_LUT_BG,x	; Write in LUT Memory
                inx
                cpx #$40
                bne loop1
		rts
.bend ; end initTextLUT


clearScreen     .block
		ldx #$00
                lda #$00
                sta $20
                lda #$C0
                sta $21 

                ldy #$00
loopA                        
                lda #$20 
loopY                
                sta ($20),y 
                iny 
                cpy #$00 
                bne loopY
                inc $21 
                lda $21
                cmp #$D3 
                bne loopA
                rts 
.bend ; end clearScreen

fillColor       .block
		ldx #$00
                lda #$00
                sta $20
                lda #$C0
                sta $21 

                ldy #$00
loopA                        
                lda #$E1 
loopY                
                sta ($20),y 
                iny 
                cpy #$00 
                bne loopY
                inc $21
                lda $21
                cmp #$D3 
                bne loopA
                rts 
.bend ; end fillColor

splashText      .block
		lda #$00
                sta $20
                lda #$C0
                sta $21 
                lda #<Text2Display
                sta $22
                lda #>Text2Display
                sta $23
printText
                ldy #$00
loopY      
                lda ($22),y
                cmp #$00
                beq endSplash
                sta ($20),y 
                iny 
                cpy #$00 
                bne loopY
                inc $21 
                inc $23
                bne loopY
endSplash                
                rts
.bend ; end splashText

.send ; end section display

;******************************************************************************************
; Display data that sits in CPU memory range.
;******************************************************************************************

.section	data
.align 16
FgColorLut    
		.text $00, $00, $00, $FF
                .text $00, $00, $80, $FF
                .text $00, $80, $00, $FF
                .text $80, $00, $00, $FF
                .text $00, $80, $80, $FF
                .text $80, $80, $00, $FF
                .text $80, $00, $80, $FF
                .text $80, $80, $80, $FF
                .text $00, $45, $FF, $FF
                .text $13, $45, $8B, $FF
                .text $00, $00, $20, $FF
                .text $00, $20, $00, $FF
                .text $20, $00, $00, $FF
                .text $20, $20, $20, $FF
                .text $FF, $80, $00, $FF
                .text $FF, $FF, $FF, $FF

BgColorLut
		.text $00, $00, $00, $FF  ;BGRA
                .text $AA, $00, $00, $FF
                .text $00, $80, $00, $FF
                .text $00, $00, $80, $FF
                .text $00, $20, $20, $FF
                .text $20, $20, $00, $FF
                .text $20, $00, $20, $FF
                .text $20, $20, $20, $FF
                .text $1E, $69, $D2, $FF
                .text $13, $45, $8B, $FF
                .text $00, $00, $20, $FF
                .text $00, $20, $00, $FF
                .text $40, $00, $00, $FF
                .text $10, $10, $10, $FF
                .text $40, $40, $40, $FF
                .text $FF, $FF, $FF, $FF
.align 16
Text2Display    .text "                                                                                "
                .text "                ****         F256 Jr Showcase          ****                     "
                .text $00

FailedKbd       .text "THE PS2 INIT FAILED", $00
SuccessKbd      .text "THE PS2 INIT SUCCEEDED", $00
FailedSDC       .text "THE SDCARD FAILED", $00
SuccessSDC      .text "THE SDCARD INIT... SUCCESS", $00
Format          .text "N:C256JR,S", $00, "A"
HEX             .text "0123456789", $01, $02, $03, $04, $05, $00
.send ; end section data

.endn ; end namespace display