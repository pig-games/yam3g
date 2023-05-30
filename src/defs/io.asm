io		.namespace

joy		.namespace

.section dp
	VAL		.byte 0
.endsection
	BUTTON_0_MASK   = #$10
	BUTTON_1_MASK   = #$20
	BUTTON_2_MASK	= #$40
	VIA0_IRB        = $DC00   ;Joystick 0
	VIA0_IRA        = $DC01   ;Joystick 1 
	VIA0_DRB        = $DC02 
	VIA0_DRA        = $DC03 

.endnamespace ; joy
.endnamespace ; io