
Imu:	;--- Get Sensor Data ---

	call AdcRead					;Calculate gyro output
	b16sub GyroRoll, GyroRoll, GyroRollZero
	b16sub GyroPitch, GyroPitch, GyroPitchZero
	b16sub GyroYaw, GyroYaw, GyroYawZero

	b16sub AccX, AccX, AccXZero			;remove offset from Acc
	b16sub AccY, AccY, AccYZero
	b16sub AccZ, AccZ, AccZZero

;Board Offset 0 = -90 deg, 1 = -45 deg, 2 = 0 deg (normal), 3 = +45 deg, 4= +90 deg, 5 = 180 deg

	lds t, BoardOffset

	cpi t, 2							; 0 deg offset
	brne boff0
	rjmp boff7

boff0:
	cpi t, 0							; -90 deg offset
	breq boff1
	rjmp boff1a
boff1:
	b16mov Temp, GyroPitch
	b16neg GyroRoll
	b16mov GyroPitch, GyroRoll
	b16mov GyroRoll, Temp

	b16mov Temp, Accy	
	b16neg AccX
	b16mov AccY, AccX
	b16mov AccX, Temp

	rjmp boff7

boff1a:
	cpi t, 1							; -45 degrees offset
	breq boff2
	rjmp boff2a
boff2:
	ldi yl,0b10110101				; 0.7071 = (2^0.5)/2
	b16sub Temp, GyroPitch, GyroRoll		
	b168fracmul Temp, Temp				; multiply by 0.7071
	b16add GyroRoll, GyroPitch, GyroRoll
	b168fracmul GyroRoll, GyroRoll			; multiply by 0.7071
	b16mov GyroPitch, Temp	

	b16sub Temp, AccX, AccY		
	b168fracmul Temp, Temp				; multiply by 0.7071
	b16add AccY, AccX, AccY
	b168fracmul AccY, AccY				; multiply by 0.7071
	b16mov AccX, Temp

	rjmp boff7	

boff2a:		
	cpi t, 3								; +45 degrees offset
	breq boff3
	rjmp boff3a	
boff3:
	ldi yl,0b10110101				; 0.7071 = (2^0.5)/2
	b16add Temp, GyroPitch, GyroRoll		
	b168fracmul Temp, Temp				; multiply by 0.7071
	b16sub GyroRoll, GyroRoll, GyroPitch
	b168fracmul GyroRoll, GyroRoll			; multiply by 0.7071
	b16mov GyroPitch, Temp
	
	b16add Temp, AccX, AccY		
	b168fracmul Temp, Temp				; multiply by 0.7071
	b16sub AccY, AccY, AccX
	b168fracmul AccY, AccY				; multiply by 0.7071
	b16mov AccX, Temp
	
	rjmp boff7

boff3a:
	cpi t, 4								; +90 degrees offset
	breq boff4
	rjmp boff4a	
boff4:
	b16mov Temp, GyroRoll			; +90 deg offset test code
	b16neg GyroPitch
	b16mov GyroRoll, GyroPitch
	b16mov GyroPitch, Temp

	b16mov Temp, AccX	
	b16neg AccY
	b16mov AccX, AccY
	b16mov AccY, Temp		

	rjmp boff7

boff4a:									; 180 deg offset
	b16neg GyroPitch
	b16neg GyroRoll
	b16neg AccX
	b16neg AccY

boff7:	; end of Board Offset code

	b16add AccX, AccX, AccTrimPitch			;add trim
	b16add AccY, AccY, AccTrimRoll


	;SF LP filter the accelerometers.  Acc SW Filter / 256 = 8 / 256 = 0.03125 as default
	b16sub Error, AccX, AccXfilter
	b16mul Error, Error, AccSWFilter
	b16add AccXfilter, AccXfilter, Error

	b16sub Error, AccY, AccYfilter
	b16mul Error, Error, AccSWFilter
	b16add AccYfilter, AccYfilter, Error

	b16sub Error, AccZ, AccZfilter
	b16mul Error, Error, AccSWFilter
	b16add AccZfilter, AccZfilter, Error


	;---  calculate tilt angle with the acc. (this approximation is good to about 20 degrees) --

    ;0.33 is 2g multiplier : 0.66 is 4g multiplier : 1.32 is 8g multiplier : 2.64 is 16g multiplier

	b16mul AccAngleRoll, AccYfilter, TiltAngMult
	b16mul AccAnglePitch, AccXfilter, TiltAngMult

;--- Code to change values of GyroRoll, GyroPitch and GyroYaw instead of changing PI gains and stick scaling

	lds t, GyroMult
	cpi		t,4					;  is it 2000 dps
	brge	setup2000pr			;  yes
	cpi		t,2					;  is it 1000 dps
	brge	setup1000pr 		;  yes
	cpi		t,1					;  is it  500 dps
	brge	setup500pr			;  yes
	rjmp	Setup250pr

setup500pr:
	rjmp im30a

setup2000pr:	
	b16fmul GyroRoll, 2
	b16fmul GyroPitch, 2
	b16fmul GyroYaw, 2
	rjmp im30a

setup1000pr:	
	b16fmul GyroRoll, 1
	b16fmul GyroPitch, 1
	b16fmul GyroYaw, 1
	rjmp im30a

setup250pr:
	b16fdiv GyroRoll, 1
	b16fdiv GyroPitch, 1
	b16fdiv GyroYaw, 1	

im30a:

	;--- Add correction data to gyro inputs based on difference between Euler angles and acc angles ---

	b16mov GyroRollVC, GyroRoll			;fork gyrovalues to be used in 3D vector calc.
	b16mov GyroPitchVC, GyroPitch
    ;rjmp im41 ; uncomment to check magic number without +-20 deg correction
	b16ldi Temp, 20					;skip correction at angles greater than +-20
	b16cmp AccAnglePitch, Temp
	longbrge im41
	b16cmp AccAngleRoll, Temp
	longbrge im41

	b16neg Temp
	b16cmp AccAnglePitch, Temp
	longbrlt im41
	b16cmp AccAngleRoll, Temp
	longbrlt im41

	b16mov Temp, AccZTest
	b16cmp AccZfilter, Temp		;skip correction if vertical accelleration is outside 0.5 to 1.5 G
	longbrge im41					; 2g = 128 : 4g = 64 : 8g = 32 : 16g = 16

	b16neg Temp
	b16cmp AccZfilter, Temp
	longbrlt im41

/*	something for the future?
	;skip correction if total acceleration magnitude is outside 0.5 to 1.5 G 
	;m = sqrt(AccX^2 + AccY^2 + AccZ^2)
	;m^2 = (AccX^2 + AccY^2 + AccZ^2)

	b16load AccXfilter
	clr yl
	clr zh
	b832store AccXfilter832
	b832mul AccXSqd, AccXfilter832, AccXfilter832

	b16load AccYfilter
	clr yl
	clr zh
	b832store AccYfilter832
	b832mul AccYSqd, AccYfilter832, AccYfilter832

	b16load AccZfilter
	clr yl
	clr zh
	b832store AccZfilter832
	b832mul AccZSqd, AccZfilter832, AccZfilter832

	b832add TempB, AccYSqd, AccXSqd
	b832add TempA, TempB, AccZSqd

	b832cmp TempA, MagAccMaxTest		;skip correction if vertical accelleration is outside > 1.5 G
	longbrge im41						; 2g = (128/256)^2 : 4g = (64/256)^2 : 8g = (32/256)^2 : 16g = (16/256)^2

	b832cmp TempA, MagAccMinTest		;skip correction if vertical accelleration is outside < 0.5 G
	longbrlt im41						; 2g = -(128/256)^2 : 4g = -(64/256)^2 : 8g = -(32/256)^2 : 16g = -(16/256)^2

*/
	b16sub Temp, EulerAngleRoll, AccAngleRoll	;add roll correction
	b16fdiv Temp, 2
	b16add GyroRollVC, GyroRollVC, Temp

	b16sub Temp, EulerAnglePitch, AccAnglePitch	;add pitch correction
	b16fdiv Temp, 2
	b16add GyroPitchVC, GyroPitchVC, Temp

im41:
	
	;--- Rotate up-direction 3D vector with gyro inputs ---

	call Rotate3dVector

	call Lenght3dVector
	
	call ExtractEulerAngles

	;--debug
/*
	b824load vectorX
	call transfer824168
	b16store debug5
	b16ldi Temp, 2220
	b16mul debug5, debug5, Temp

	b824load vectorY
	call transfer824168
	b16store debug6
	b16ldi Temp, 2220
	b16mul debug6, debug6, Temp

	b824load vectorZ
	call transfer824168
	b16store debug7
	b16ldi Temp, 2220
	b16mul debug7, debug7, Temp
*/



	;--- Calculate Stick and Gyro  ---

	rvbrflagfalse flagThrottleZero, im7	;reset integrals if throttle closed 
	b16clr IntegralRoll
	b16clr IntegralPitch
	b16clr IntegralYaw

im7:	b16fdiv RxRoll, 4			;Right align to the 16.4 multiply usable bit limit.
	b16fdiv RxPitch, 4
	b16fdiv RxYaw, 4

	rvbrflagfalse flagSwitchSSPI, im9	;use Profile 1 SS & PI if false
	rvbrflagfalse flagAuxOn, im9	;SwitchSSPI is true so check if Aux switch is off to use Profile 1 SS & PI
	rjmp switchedP2						;use Profile 2 SS & PI

	;use Profile 1 SS & PI
im9: 
	b16mul RxRoll, RxRoll, StickScaleRoll	;scale Stick input. 
	b16mul RxPitch, RxPitch, StickScalePitch
	b16mul RxYaw, RxYaw, StickScaleYaw
	b16mul RxThrottle, RxThrottle, StickScaleThrottle


	;----- Self level ----

	rvbrflagtrue flagSelflevelOn, im31a	;if self level is off, skip SL code
	rjmp im30	
im31a:
	rvbrflagfalse flagSLPGZero,im31		;execute SL code if SL P Gain is > zero
	rjmp im30				;skip SL code if SL P Gain is zero

im31:	

;--- Roll Axis Self-level P ---

	b16neg RxRoll
	
	b16fdiv RxRoll, 1

	b16sub Error, EulerAngleRoll, RxRoll	;calculate error
	b16fdiv Error, 4

	b16mul Value, Error, SelflevelPgain	;Proposjonal gain

	b16mov LimitV, SelflevelPlimit		;Proposjonal limit
	rcall limiter
	b16mov RxRoll, Value

	b16fdiv RxRoll, 1


;--- Pitch Axis Self-level P ---

	b16neg RxPitch
	
	b16fdiv RxPitch, 1

	b16sub Error, EulerAnglePitch, RxPitch	;calculate error
	b16fdiv Error, 4

	b16mul Value, Error, SelflevelPgain	;Proposjonal gain

	b16mov LimitV, SelflevelPlimit		;Proposjonal limit
	rcall limiter
	b16mov RxPitch, Value

	b16fdiv RxPitch, 1
im30:

;--- Roll Axis PI ---
	
	b16sub Error, GyroRoll, RxRoll		;calculate error
	b16fdiv Error, 1

	b16mul Value, Error, PgainRoll		;Proposjonal gain

	b16mov LimitV, PlimitRoll		;Proposjonal limit
	rcall limiter
	b16mov CommandRoll, Value

	b16fdiv Error, 3
	b16mul Temp, Error, IgainRoll		;Integral gain
	b16add Value, IntegralRoll, Temp

	b16mov LimitV, IlimitRoll 		;Integral limit
	rcall limiter
	b16mov IntegralRoll, Value

	b16add CommandRoll, CommandRoll, IntegralRoll


;--- Pitch Axis PI ---

	b16sub Error, RxPitch, GyroPitch	;calculate error
	b16fdiv Error, 1

	b16mul Value, Error, PgainPitch		;Proposjonal gain

	b16mov LimitV, PlimitPitch		;Proposjonal limit
	rcall limiter
	b16mov CommandPitch, Value

	b16fdiv Error, 3
	b16mul Temp, Error, IgainPitch		;Integral gain
	b16add Value, IntegralPitch, Temp

	b16mov LimitV, IlimitPitch 		;Integral limit
	rcall limiter
	b16mov IntegralPitch, Value

	b16add CommandPitch, CommandPitch, IntegralPitch


;--- Yaw Axis PI ---

	b16sub Error, RxYaw, GyroYaw		;calculate error
	b16fdiv Error, 1

	b16mul Value, Error, PgainYaw		;Proposjonal gain

	b16mov LimitV, PlimitYaw		;Proposjonal limit
	rcall limiter
	b16mov CommandYaw, Value

	b16fdiv Error, 3
	b16mul Temp, Error, IgainYaw		;Integral gain
	b16add Value, IntegralYaw, Temp

	b16mov LimitV, IlimitYaw 		;Integral limit
	rcall limiter
	b16mov IntegralYaw, Value

	b16add CommandYaw, CommandYaw, IntegralYaw


;------
	ret

;use Profile 2 SS & PI

switchedP2:

	b16mul RxRoll, RxRoll, StickScaleRollP2	;scale Stick input. 
	b16mul RxPitch, RxPitch, StickScalePitchP2
	b16mul RxYaw, RxYaw, StickScaleYawP2
	b16mul RxThrottle, RxThrottle, StickScaleThrottleP2


	;----- Check if Self level is on! ------

	rvbrflagtrue flagSelfLevelOn,P2SLCheck ; 
	rjmp im30P2				;skip SL code as SL is not on 
P2SLCheck:
	rvbrflagfalse flagSLPGP2Zero,im31P2	;execute SL code if P2 SL P Gain is > zero
	rjmp im30P2				;skip SL code if P2 SL P Gain is zero

im31P2:	

;--- Roll Axis Self-level P ---

	b16neg RxRoll
	
	b16fdiv RxRoll, 1

	b16sub Error, EulerAngleRoll, RxRoll	;calculate error
	b16fdiv Error, 4

	b16mul Value, Error, SelflevelPgainP2	;Proposjonal gain

	b16mov LimitV, SelflevelPlimitP2		;Proposjonal limit
	rcall limiter
	b16mov RxRoll, Value

	b16fdiv RxRoll, 1


;--- Pitch Axis Self-level P ---

	b16neg RxPitch
	
	b16fdiv RxPitch, 1

	b16sub Error, EulerAnglePitch, RxPitch	;calculate error
	b16fdiv Error, 4

	b16mul Value, Error, SelflevelPgainP2	;Proposjonal gain

	b16mov LimitV, SelflevelPlimitP2		;Proposjonal limit
	rcall limiter
	b16mov RxPitch, Value

	b16fdiv RxPitch, 1
im30P2:

;--- Roll Axis PI ---
	
	b16sub Error, GyroRoll, RxRoll		;calculate error
	b16fdiv Error, 1

	b16mul Value, Error, PgainRollP2		;Proposjonal gain

	b16mov LimitV, PlimitRollP2		;Proposjonal limit
	rcall limiter
	b16mov CommandRoll, Value

	b16fdiv Error, 3
	b16mul Temp, Error, IgainRollP2		;Integral gain
	b16add Value, IntegralRoll, Temp

	b16mov LimitV, IlimitRollP2 		;Integral limit
	rcall limiter
	b16mov IntegralRoll, Value

	b16add CommandRoll, CommandRoll, IntegralRoll


;--- Pitch Axis PI ---

	b16sub Error, RxPitch, GyroPitch	;calculate error
	b16fdiv Error, 1

	b16mul Value, Error, PgainPitchP2		;Proposjonal gain

	b16mov LimitV, PlimitPitchP2		;Proposjonal limit
	rcall limiter
	b16mov CommandPitch, Value

	b16fdiv Error, 3
	b16mul Temp, Error, IgainPitchP2		;Integral gain
	b16add Value, IntegralPitch, Temp

	b16mov LimitV, IlimitPitchP2 		;Integral limit
	rcall limiter
	b16mov IntegralPitch, Value

	b16add CommandPitch, CommandPitch, IntegralPitch


;--- Yaw Axis PI ---

	b16sub Error, RxYaw, GyroYaw		;calculate error
	b16fdiv Error, 1

	b16mul Value, Error, PgainYawP2		;Proposjonal gain

	b16mov LimitV, PlimitYawP2		;Proposjonal limit
	rcall limiter
	b16mov CommandYaw, Value

	b16fdiv Error, 3
	b16mul Temp, Error, IgainYawP2		;Integral gain
	b16add Value, IntegralYaw, Temp

	b16mov LimitV, IlimitYawP2 		;Integral limit
	rcall limiter
	b16mov IntegralYaw, Value

	b16add CommandYaw, CommandYaw, IntegralYaw


;------
	ret


limiter:
	b16cmp Value, LimitV	;high limit
	brlt lim5
	b16mov Value, LimitV

lim5:	b16neg LimitV		;low limit
	b16cmp Value, LimitV
	brge lim6
	b16mov Value, LimitV

lim6:	ret








/*

	b16mov LimitV, 
	b16mov Value, 
	rcall limiter
	b16mov , Value

*/
