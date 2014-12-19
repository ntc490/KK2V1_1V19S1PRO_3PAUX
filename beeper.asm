
	;--- turn off buzzer when BeeperDelay runs out ----

Beeper:	b16clr Temp					;is BeeperDelay == 0 ?
	b16cmp BeeperDelay, Temp
	breq bee1

	b16dec BeeperDelay				;No, subtract one and exit
	rjmp bee2


bee1:	rvsetflagfalse flagGeneralBuzzerOn		;yes, turn off buzzer and exit


bee2:

	;--- Make a short beep regulary when armed and throttle at idle ----

	rvflagand flagA, flagArmed, flagThrottleZero
	rvbrflagfalse FlagA, bee4
	
	b16dec ArmedBeepDds

	b16clr Temp
	b16cmp ArmedBeepDds, Temp
	brge bee4

	b16ldi ArmedBeepDds, 400*2

	rvsetflagtrue flagGeneralBuzzerOn
	b16ldi BeeperDelay, 20


bee4:

	;--- No activity alarm ---

	rvflageor flagA, flagArmed, flagArmedOldState		;flagA == true if flagArmed changes state
	rvflagand flagArmedOldState, flagArmed, flagArmed

	rvbrflagfalse flagA, bee5				;activity?
	
	b16clr NoActivityTimer					;Yes, reset timer

bee5:	b16ldi Temp, 0.004					;add 3.90625ms to timer
	b16add NoActivityTimer, NoActivityTimer, Temp

	b16ldi Temp, 32000					;avoid wrap-around
	b16cmp NoActivityTimer, Temp
	brlt bee7
	b16mov NoActivityTimer, Temp
	

bee7:	b16ldi Temp, 937.5 * 3					;30 minutes without activity? (arming or disarming)
	b16cmp NoActivityTimer, Temp
	brlt bee6

	b16dec NoActivityDds					;yes, beep 1 s every 5s
	b16clr Temp
	b16cmp NoActivityDds, Temp
	brge bee6
	
	b16ldi NoActivityDds, 400*5
	rvsetflagtrue flagGeneralBuzzerOn
	b16ldi BeeperDelay, 400

bee6:


	;--- turn buzzer on/off depending on flags ---

	rvflagor flagA, flagGeneralBuzzerOn, flagLvaBuzzerOn
;	rvflagor flagA, flagA, flagDebugBuzzerOn
	rvflagor flagA, flagA, flagLMABuzzerOn
	rvbrflagtrue flagA, bee3
	BuzzerOff
	ret

bee3:	BuzzerOn
	ret


	;---

Beep:	push t		;a short beep
	push yl

	BuzzerOn
	ldi yl, 50
	call wms
	BuzzerOff
		
	pop yl
	pop t

	ret
