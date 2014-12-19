clrmaxmin:

	b16clr	Temp
	b16mov	GyroRollMax, Temp
	b16mov	GyroPitchMax, Temp
	b16mov	GyroYawMax, Temp
	b16mov	AccXMax, Temp
	b16mov	AccYMax, Temp
	b16mov	AccZMax, Temp

	ret


logmaxmin:

	b16ldi Temper, 512

	b16mov  Temp, GyroRoll
	call adjustmm
	b16cmp	GyroRollMax, Temp
	brge	adc21
	b16mov	GyroRollMax, Temp

adc21:
	b16mov  Temp, GyroPitch
	call adjustmm
	b16cmp	GyroPitchMax, Temp
	brge	adc22
	b16mov	GyroPitchMax, Temp

adc22:
	b16mov  Temp, GyroYaw
	call adjustmm
	b16cmp	GyroYawMax, Temp
	brge	adc23
	b16mov	GyroYawMax, Temp

adc23:
	b16mov  Temp, AccX
	call adjustmm
	b16cmp	AccXMax, Temp
	brge	adc24
	b16mov	AccXMax, Temp

adc24:
	b16mov  Temp, AccY
	call adjustmm
	b16cmp	AccYMax, Temp
	brge	adc25
	b16mov	AccYMax, Temp

adc25:
	b16mov  Temp, AccZ
	call adjustmm
	b16cmp	AccZMax, Temp
	brge	adc26
	b16mov	AccZMax, Temp

adc26:
	ret

adjustmm:
	b16sub Temp, Temp, Temper
	b16load Temp
	call	xabs
	b16store Temp
	b16add Temp, Temp, Temper
	ret

SensorMaxMin:

.set xoff = 0
.set yoff = 0
	
mm1:	call LcdClear

	lrv PixelType, 1
	lrv FontSelector, f6x8

	lrv X1, 0		
	lrv Y1, 0

	b16clr	Temper
	b16mov	Temp, AccZMax
	b16cmp  Temp, Temper
	brne printvalues
	mPrintString mm5
	jmp footermm

printvalues:
	mPrintString sen2
	b16load GyroPitchMax
	b16ldi Temp, 512
	b16sub Temp, GyroPitchMax, Temp
	call printgmax

	lrv X1, xoff		;gyro y
	lrv Y1, yoff + 9
	mPrintString sen3
	b16load GyroRollMax
	b16ldi Temp, 512
	b16sub Temp, GyroRollMax, Temp
	call printgmax

	lrv X1, xoff		;gyro z
	lrv Y1, yoff + 18
	mPrintString sen4
	b16load GyroYawMax
	b16ldi Temp, 512
	b16sub Temp, GyroYawMax, Temp
	call printgmax

	lrv X1, xoff		;acc X
	lrv Y1, yoff + 27
	mPrintString sen5
	b16load AccXMax
	b16ldi Temp, 512
	b16sub Temp, AccXMax, Temp
	call printmax

	lrv X1, xoff		;acc Y
	lrv Y1, yoff + 36
	mPrintString sen6
	b16load AccYMax
	b16ldi Temp, 512
	b16sub Temp, AccYMax, Temp
	call printmax

	lrv X1, xoff		;acc Z
	lrv Y1, yoff + 45
	mPrintString sen7
	b16load AccZMax
	b16ldi Temp, 512
	b16sub Temp, AccZMax, Temp
	call printmax

footermm:
	lrv X1, 0		;footer
	lrv Y1, 57
	mPrintString mm2

	call LcdUpdate
	
	call GetButtons
	cpi t, 0x08		;BACK?
	brne mm3
	ret	

mm3:	
	cpi t, 0x01		;CLEAR?
	brne mm4
	call clrmaxmin

mm4:	jmp mm1

printmax:
	lds		t,afs_sel
	andi	t,0b00011000
	lsr		t
	lsr		t
	lsr		t

	cpi		t,0
	brne	div9
	b16fdiv Temp,8
	call printmax1
	ret
div9:
	cpi		t,1
	brne	div10
	b16fdiv Temp,7
	call printmax1
	ret
div10:
	cpi		t,2
	brne	div11
	b16fdiv Temp,6
	call printmax1
	ret
div11:
	b16fdiv Temp,5
	call printmax1
	ret

printmax1:
	b16load Temp
	call Print16Signed 

	ldi t,'.'
	call PrintChar

	mov xl, yh
	clr xh
	b16store Temp
	b16ldi Temper, 0.0390625
	b16mul Temp, Temp, Temper
	b16load Temp
 	call Print16Signed 
	ldi t,'g'
	call PrintChar
	ret

printgmax:
	lds		t,gfs_sel
	andi	t,0b00011000
	lsr		t
	lsr		t
	lsr		t

	cpi		t,0
	brne	div1
	b16fdiv Temp,1
	call printmax2
	ret
div1:
	cpi		t,1
	brne	div2
	call printmax2
	ret
div2:
	cpi		t,2
	brne	div3
	b16fmul Temp,1
	call printmax2
	ret
div3:
	b16fmul Temp,2
	call printmax2
	ret

printmax2:
	b16load Temp
	call Print16Signed 

	ldi t,'.'
	call PrintChar

	mov xl, yh
	clr xh
	b16store Temp
	b16ldi Temper, 0.0390625
	b16mul Temp, Temp, Temper
	b16load Temp
 	call Print16Signed 
	mPrintString gdps
	ret

gdps:   .db "deg/s", 0
mm2:    .db "BACK            CLEAR",0
mm5:	.db "No recorded values",0 ,0

/*  The below are actually in SensorTest
sen2:	.db "Gyro X: ", 0,0
sen3:	.db "Gyro Y: ", 0,0
sen4:	.db "Gyro Z: ", 0,0
sen5:	.db " Acc X: ", 0,0
sen6:	.db " Acc Y: ", 0,0
sen7:	.db " Acc Z: ", 0,0
sen9:	.db "BACK",0,0
*/