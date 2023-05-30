interrupt        .namespace
; Pending Interrupt (Read and Write Back to Clear)
        PENDING_REG0 = $D660 ;
        PENDING_REG1 = $D661 ;
        PENDING_REG2 = $D662 ; IEC Signals Interrupt
        PENDING_REG3 = $D663 ; NOT USED
; Polarity Set
        POL_REG0     = $D664 ;
        POL_REG1     = $D665 ;
        POL_REG2     = $D666 ; IEC Signals Interrupt
        POL_REG3     = $D667 ; NOT USED
; Edge Detection Enable
        EDGE_REG0    = $D668 ;
        EDGE_REG1    = $D669 ;
        EDGE_REG2    = $D66A ; IEC Signals Interrupt
        EDGE_REG3    = $D66B ; NOT USED
; Mask
        MASK_REG0    = $D66C ;
        MASK_REG1    = $D66D ;
        MASK_REG2    = $D66E ; IEC Signals Interrupt
        MASK_REG3    = $D66F ; NOT USED
; Interrupt Bit Definition
; Register Block 0
        JR0_INT00_SOF        = $01  ;Start of Frame @ 60FPS or 70hz (depending on the Video Mode)
        JR0_INT01_SOL        = $02  ;Start of Line (Programmable)
        JR0_INT02_KBD        = $04  ;PS2 Keyboard
        JR0_INT03_MOUSE      = $08  ;PS2 Mouse 
        JR0_INT04_TMR0       = $10  ;Timer0
        JR0_INT05_TMR1       = $20  ;Timer1
        JR0_INT06_RSVD0      = $40  ;Reserved 
        JR0_INT07_CRT        = $80  ;Cartridge
; Register Block 1
        JR1_INT00_UART       = $01  ;UART
        JR1_INT01_TVKY2      = $02  ;TYVKY NOT USED
        JR1_INT02_TVKY3      = $04  ;TYVKY NOT USED
        JR1_INT03_TVKY4      = $08  ;TYVKY NOT USED
        JR1_INT04_RTC        = $10  ;Real Time Clock
        JR1_INT05_VIA0       = $20  ;VIA0 (Jr & K)
        JR1_INT06_VIA1       = $40  ;VIA1 (K Only) - Local Keyboard
        JR1_INT07_SDCARD     = $80  ;SDCard Insert Int
; Register Block 1
        JR2_INT00_IEC_DAT    = $01  ;IEC_DATA_i
        JR2_INT01_IEC_CLK    = $02  ;IEC_CLK_i
        JR2_INT02_IEC_ATN    = $04  ;IEC_ATN_i
        JR2_INT03_IEC_SREQ   = $08  ;IEC_SREQ_i
        JR2_INT04_RSVD1      = $10  ;Reserved
        JR2_INT05_RSVD2      = $20  ;Reserved
        JR2_INT06_RSVD3      = $40  ;Reserved
        JR2_INT07_RSVD4      = $80  ;Reserved
.endnamespace ; interrupt