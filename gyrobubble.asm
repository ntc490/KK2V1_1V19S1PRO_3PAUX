

GyroBubble:

	call LcdClear

	call ADCRead

	lrv PixelType, 1

	ldi	t,0
	sts X1,t
	ldi t,31
	sts Y1,t
	sts Y2,t
	ldi	t,127
	sts X2,t
	call Bresenham

	ldi	t,63
	sts X1,t
	sts X2,t
	sts Y2,t
	ldi t,0
	sts Y1,t
	call Bresenham

	lrv PixelType, 1
	lrv FontSelector, s16x16

	b16sub	Temp, GyroPitchZero, GyroPitch
	b16ldi  Temper, 28
	b16add	Temp, Temp, Temper
	b16load Temp
	sts Y1,xl

	b16sub	Temp,GyroRollZero, GyroRoll
	b16ldi  Temper, 60
	b16add	Temp, Temp, Temper
	b16load Temp
	sts X1,xl

	ldi t,6
    call PrintChar

	call LcdUpdate

	call GetButtons
	cpi t, 0x00		;BACK?
	breq gb1
	ret

gb1: 
	jmp	GyroBubble
