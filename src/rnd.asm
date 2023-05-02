;*************************************************************************************************
;
; Random routine 'converted' to 64tass from Brad Smith: https://github.com/bbbradsmith/prng_6502.
;
;*************************************************************************************************
; overlapped
; 73 cycles
; 38 bytes

rnd	.namespace

.section DP
seed	.fill 4
.send

.section yam3g

galois24o
	; rotate the middle byte left
	ldy seed+1 ; will move to seed+2 at the end
	; compute seed+1 ($1B>>1 = %1101)
	lda seed+2
	lsr
	lsr
	lsr
	lsr
	sta seed+1 ; reverse: %1011
	lsr
	lsr
	eor seed+1
	lsr
	eor seed+1
	eor seed+0
	sta seed+1
	; compute seed+0 ($1B = %00011011)
	lda seed+2
	asl
	eor seed+2
	asl
	asl
	eor seed+2
	asl
	eor seed+2
	sty seed+2 ; finish rotating byte 1 into 2
	sta seed+0

        lsr a
        lsr a
        lsr a
        lsr a
        lsr a
	rts

.send ; end section yam3g
.endn ; end namespace rnd
