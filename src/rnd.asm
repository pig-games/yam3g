.cpu cpu_type
rnd	.namespace

.section DP
seed	.fill 4
.send

.section yam3g

init .proc
        sta vky.sysctrl.LFSR_DATA_LO       ; store seed
        sta vky.sysctrl.LFSR_DATA_HI
        lda #vky.sysctrl.LFSR_SEED_WRITE
        sta vky.sysctrl.LFSR_CTRL          ; toggle write
        lda #vky.sysctrl.LFSR_ENABLE
        sta vky.sysctrl.LFSR_CTRL          ; enable
	rts
.endproc

generate .proc
	lda $D6A4
        lsr a
        lsr a
        lsr a
        lsr a
        lsr a
	rts
.endproc

initGalois24o .proc
	sta seed
	sta seed+1
	stz seed+2
	stz seed+3
	rts
.endproc

generateGalois24o .proc
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
.endproc


.send ; end section yam3g
.endn ; end namespace rnd
