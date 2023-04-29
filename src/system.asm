.cpu "65c02"

system          .namespace

VECTORS_BEGIN   = $FFFA ;0 Byte  Interrupt vectors
VECTOR_NMI      = $FFFA ;2 Bytes Emulation mode interrupt handler
VECTOR_RESET    = $FFFC ;2 Bytes Emulation mode interrupt handler
VECTOR_IRQ      = $FFFE ;2 Bytes Emulation mode interrupt handler

ISR_BEGIN       = $FF00 ; Byte  Beginning of CPU vectors in Direct page
HRESET          = $FF00 ;16 Bytes Handle RESET asserted. Reboot computer and re-initialize the kernel.
HCOP            = $FF10 ;16 Bytes Handle the COP instruction. Program use; not used by OS
HBRK            = $FF20 ;16 Bytes Handle the BRK instruction. Returns to BASIC Ready prompt.
HABORT          = $FF30 ;16 Bytes Handle ABORT asserted. Return to Ready prompt with an error message.
HNMI            = $FF40 ;32 Bytes Handle NMI
HIRQ            = $FF60 ;32 Bytes Handle IRQ

; Zero Page Definition
KEYBOARD_SC_TMP = $20 
; Keyboard & Mouse
KBD_MSE_CTRL_REG = $D640 
;KBD_Read_Strobe = $01 ; Deprecated
KBD_Write_Strobe = $02
;MS_Read_Strobe = $04 ; Deprecated
MS_Write_Strobe = $08
KBD_FIFO_CLEAR  = $10 ; Dump entire FIFO, set to 1 and then back to 0
MSE_FIFO_CLEAR  = $20 ; Dump entire FIFO, set to 1 and then back to 0

KBD_MS_WR_DATA_REG = $D641      ; Data to Send to Keyboard or Mouse
KBD_RD_SCAN_REG = $D642         ; DATA Out from KBD FIFO
MS_RD_SCAN_REG = $D643          ; DATA Out from MSE FIFO 

KBD_MS_RD_STATUS = $D644       ; Keyboard RD/WR Status
KBD_FIFO_Empty = $01           ; Set when Keyboard FIFO is empty
MSE_FIFO_Empty = $02           ; Set when Mouse FIFO is empty
MS_Stat_Tx_Error_No_Ack = $10
MS_Stat_Tx_Ack = $20            ; When 1, it ack the Tx
KBD_Stat_Tx_Error_No_Ack = $40
KBD_Stat_Tx_Ack = $80            ; When 1, it ack the Tx

KBD_MSE_NOT_USED = $D645;       ; Reads as 0
KBD_FIFO_BYTE_CNT = $D646       ; Number of Bytes in the Keyboard FIFO
MSE_FIFO_BYTE_CNT = $D647       ; Number of Bytes in the Mouse FIFO

; IO PAGE 0
TEXT_LUT_FG      = $D800
TEXT_LUT_BG		 = $D840
; Text Memory
TEXT_MEM         = $C000 	; IO Page 2
COLOR_MEM        = $C000 	; IO Page 3
DIPSWITCH        = $D670

SPI_CTRL_REG     = $DD00  
SPI_DATA_REG     = $DD01    ;  SPI Tx and Rx - Wait for BUSY to == 0 before reading back or to send something new

; RAM Block 0 0000-1FFF - MMU Address $08
; RAM Block 1 2000-3FFF - MMU Address $09
; RAM Block 2 4000-5FFF - MMU Address $0A
; RAM Block 3 6000-7FFF - MMU Address $0B
; RAM Block 4 8000-9FFF - MMU Address $0C
; RAM Block 5 A000-BFFF - MMU Address $0D
; RAM Block 6 - Not Visible because of IO - M
; FLASH Block 0 - E000-FFFF - MMU Address $0F

.section boot
                ; boot the system
		clc           		; clear the carry flag
	        sei			; No Interrupt now baby
		ldx #$FF 		; Let's push that stack pointer right up there
		txs
                lda #$80
                sta $00
                lda #$00
                sta $08
                inc a
                sta $09
                inc a
                sta $0A
                inc a
                sta $0B
                inc a
                sta $0C
                inc a
                sta $0D
                inc a
                sta $0E 
                inc a
                sta $0F
                lda #$20 
                sta $0A            ; Assign the External RAM for S
                lda #$00
                sta $00            ; Disable edit

                lda #$FF
                ; setup the EDGE Trigger 
                sta interrupt.EDGE_REG0
                sta interrupt.EDGE_REG1
                sta interrupt.EDGE_REG2                
                ; mask all Interrupt @ This Point
                sta interrupt.MASK_REG0
                sta interrupt.MASK_REG1
                sta interrupt.MASK_REG2
                ; clear both pending interrupt
                lda interrupt.PENDING_REG0
                sta interrupt.PENDING_REG0
                lda interrupt.PENDING_REG1
                sta interrupt.PENDING_REG1    
                lda interrupt.PENDING_REG2
                sta interrupt.PENDING_REG3                 
.send

.section system
editMMU	.macro
		lda #$80
		sta $00
	.endmacro

releaseMMU .macro
		stz $00
	.endmacro

pushMMU	.macro slot
		lda $08+$\slot
		pha
	.endmacro

popMMU	.macro slot
		pla
		sta $08+$\slot
	.endmacro

setMMU	.macro slot, bank
		#system.editMMU
		#system.pushMMU \slot
                lda #\bank
                sta $08+$\slot
		#system.releaseMMU
	.endmacro
		
resetMMU .macro slot
		#system.editMMU
		#system.popMMU \slot
		#system.releaseMMU
	.endmacro

setIOPage0		
		
		lda $01		; Load Page Control Register
		and #$FC    ; isolate 2 first bit 
		sta $01     ; Write back to make sure we are on page 0
		rts 

setIOPage1		
		lda #$01		; Load Page Control Register
		;and #$FC    ; isolate 2 first bit 
		;ora #$01
		sta $01     ; Write back to make sure we are on page 0
		rts 

setIOPage2		
		lda $01		; Load Page Control Register
		and #$FC    ; isolate 2 first bit 
		ora #$02
		sta $01     ; Write back to make sure we are on page 0
		rts 

setIOPage3		
		lda $01		; Load Page Control Register
		and #$FC    ; isolate 2 first bit 
		ora #$03
		sta $01     ; Write back to make sure we are on page 0
		rts 

.send ; end section system
.endn ; end namespace system
