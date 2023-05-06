rnd	.namespace

.section DP
seed	.fill 4
.send

.section yam3g

generate
	lda $D6A4
        lsr a
        lsr a
        lsr a
        lsr a
        lsr a
	rts

.send ; end section yam3g
.endn ; end namespace rnd
