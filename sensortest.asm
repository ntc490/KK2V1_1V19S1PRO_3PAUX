
.set xoff = 0
.set yoff = 0

SensorTest:


sen1:	call LcdClear



	call AdcRead

	lrv PixelType, 1
	lrv FontSelector, f6x8

	lrv X1, xoff		;gyro X
	lrv Y1, yoff
	mPrintString sen2
	b16load GyroPitch
	call Print16Signed 
	call GyroCheck
	
	lrv X1, xoff		;gyro Y
	lrv Y1, yoff + 9
	mPrintString sen3
	b16load GyroRoll
	call Print16Signed 
	call GyroCheck

	lrv X1, xoff		;gyro Z
	lrv Y1, yoff + 18
	mPrintString sen4
	b16load GyroYaw
	call Print16Signed 
	call GyroCheck

	lrv X1, xoff		;acc X
	lrv Y1, yoff + 27
	mPrintString sen5
	b16load AccX
	call Print16Signed 
	call AccCheck

	lrv X1, xoff		;acc Y
	lrv Y1, yoff + 36
	mPrintString sen6
	b16load AccY
	call Print16Signed 
	call AccCheck

	lrv X1, xoff		;acc Z
	lrv Y1, yoff + 45
	mPrintString sen7
	b16load AccZ
	call Print16Signed 
	call AccCheck

	lrv X1, 0
	lrv Y1, 57
	mPrintString sen9

	call LcdUpdate

	ldi yh, 5
sen10:	ldi yl, 0
	call wms
	dec yh
	brne sen10
	
	call GetButtons
	cpi t, 0x08		;BACK?
	brne sen16

	ret	

sen16:	jmp sen1





GyroCheck:
	lrv X1, 76
	ldy GyroLowlimit
	call CmpXy
	brlo sen11
	ldy GyroHighLimit
	call CmpXy
	brsh sen11
	mPrintString sen12
	ret
sen11:	mPrintString sen13
	rvsetflagfalse flagSensorsOk
	ret

AccCheck:
	lrv X1, 76
	ldy AccLowlimit
	call CmpXy
	brlo sen14
	ldy AccHighLimit
	call CmpXy
	brsh sen14
	mPrintString sen12
	ret
sen14:	mPrintString sen13
	rvsetflagfalse flagSensorsOk
	ret



sen2:	.db "Gyro X: ", 0,0
sen3:	.db "Gyro Y: ", 0,0
sen4:	.db "Gyro Z: ", 0,0
sen5:	.db " Acc X: ", 0,0
sen6:	.db " Acc Y: ", 0,0
sen7:	.db " Acc Z: ", 0,0
sen9:	.db "BACK",0,0
sen12:	.db "OK",0,0
sen13:	.db "Not OK",0,0

