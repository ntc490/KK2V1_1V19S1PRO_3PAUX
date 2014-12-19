





Arming:	rvflagand flagA, flagThrottleZero, flagAutoDisarm	;Auto disarm logic
	rvflagand flagA, flagA, flagArmed
	rvbrflagtrue flagA, arm10	

	b16clr AutoDisarmDelay					;if throttle is non zero or autodisarm is off, clear counter
	rjmp arm12

arm10:	b16inc AutoDisarmDelay					;if throttle is zero and autodisarm is on, inc counter
	b16ldi Temp, 400 * 20
	b16cmp AutoDisarmDelay, Temp				;counter = 20 sec?
	brne arm12

	b16clr AutoDisarmDelay					;Yes, auto disarm
	rvsetflagfalse flagArmed
	rvsetflagtrue flagLcdUpdate
	rvbrflagfalse flagLMA, arm10a
	rvsetflagtrue flagLMABuzzerOn			;Turn on lost model alarm
arm10a:	ret
arm12:

	;--- 

	rvbrflagfalse flagThrottleZero, arm1	;Stick: 

	b16ldi Temp, -500			;Rudder in Arming position?
	b16cmp RxYaw, Temp
	brlt arm2

	b16ldi Temp, 500			;Rudder in Safe position?
	b16cmp RxYaw, Temp
	brge arm2
	
arm1:	lrv ArmingDelay, 0			;no, clear delay counter and exit
	ret

arm2:	rvinc ArmingDelay			;yes, ArmingDelay++
	lds t, ArmingDelay
	cpi t, 255
	breq arm9				;Delay reached?
	rjmp arm3

arm9:	b16load RxYaw
	tst xh					;Yes, set or clear flagArmed depending on the rudder direction
	brpl arm6a

	rvcpi Status, 0				;skip arming if status is not OK.
	breq arm5
	ret

arm6a: rjmp arm6

arm5:	rvsetflagtrue flagArmed			;Arm	
	rvsetflagfalse flagLMABuzzerOn		;Turn off lost model alarm
	b16ldi BeeperDelay, 300
	call gyrocal				;calibrate gyros
	b16clr PwmErrorCounter		;reset pwm error counter
	b832clr VectorX				;set 3d vector to point straigth up
	b832clr VectorY
	b832ldi VectorZ, 1
	rjmp Arm11

arm6:	rvsetflagfalse flagArmed		;Disarm
	rvsetflagfalse flagLMABuzzerOn		;Turn off lost model alarm
	b16ldi BeeperDelay, 150
	
arm11:	rvsetflagtrue flagGeneralBuzzerOn
	rvsetflagtrue flagLcdUpdate
	b16ldi ArmedBeepDds, 400*2
	b16clr AutoDisarmDelay

	;---

	b16ldi Temp, 500
	b16cmp RxRoll, Temp
	brge arm7				;Roll stick in selflevel on position?

	b16ldi Temp, -500
	b16cmp RxRoll, Temp
	brlt arm8				;Roll stick in selflevel off position?

	rjmp arm3

arm7:	rvsetflagtrue flagStickCommandSelfLevelOn
	rjmp arm3

arm8:	rvsetflagfalse flagStickCommandSelfLevelOn
	rjmp arm3

arm3:	ret					;No, exit
