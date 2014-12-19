



EscThrottleCalibration:

	call LcdClear
	
	lrv PixelType, 1
	lrv FontSelector, f6x8

	lrv X1,1
	lrv Y1,25
	mPrintString esc1
	lrv X1,0


	call LcdUpdate


	lrv OutputRateBitmask, 0x00	;low rate on all channels
	lrv OutputTypeBitmask, 0x00	;servo type on all channels
	lrv OutputRateDividerCounter, 1
	lrv OutputRateDivider, 8	;slow rate divider. f = 400 / OutputRateDivider
	rvsetflagtrue flagArmed
	b16ldi ServoFilter, 1

	LedOn

	;       76543210		;clear pending OCR1A and B interrupt
	ldi t,0b00000110
	store tifr1, t


esc2:	call PwmStart

	call GetRxChannels
	rvsetflagfalse flagThrottleZero

	b16ldi Temp, 200		;amplify the throttle signal to make sure it covers the 1-2ms range.
	b16sub Temp, RxThrottle, Temp

	b16clr Temper
	b16cmp Temp, Temper
	brge esc3
	b16clr Temp

esc3:	b16ldi Temper, 6
	b16mul Temp, Temp, Temper

	b16ldi Temper, 88.8
	b16add Temp, Temp, Temper

	b16mov Out1, Temp
	b16mov Out2, Temp
	b16mov Out3, Temp
	b16mov Out4, Temp
	b16mov Out5, Temp
	b16mov Out6, Temp
	b16mov Out7, Temp
	b16mov Out8, Temp

	call PwmEnd


	load t, pinb			;read buttons
	com t
	swap t
	andi t, 0x0f
	cpi t, 0x09			;Both button 1 and 4 still pressed?
	brne esc4
	rjmp esc2			;Yes, goto start of loop

esc4:	LedOff				;No, leave ESC throttle cal.

	ret






esc1:	.db "Throttle pass-through",0


