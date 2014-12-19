
CalibrateSensors:
	rvbrflagfalse flagSelfLevelDisabled, cals1
	ret
cals1:
	call LcdClear



	lrv PixelType, 1
	lrv FontSelector, f6x8

	lrv X1,0
	lrv Y1,1
	mPrintString cel2

	lrv X1,0
	rvadd y1, 9
	mPrintString cel3

	lrv X1,0
	rvadd y1, 9
	mPrintString cel4

	lrv X1,0
	rvadd y1, 9
	mPrintString cel6

	lrv X1,0
	rvadd y1, 9
	mPrintString cel7

	lrv X1,0
	rvadd y1, 9
	mPrintString cel8

	;footer
	lrv X1, 0
	lrv Y1, 57
	mPrintString cel1

	call LcdUpdate

	
cel5:	call GetButtonsBlocking
	cpi t, 0x01		;CONTINUE?
	brne cel5

	ldi xl, '5'

	ldi xh, 0

cel15:	call LcdClear


	lrv X1,0
	lrv Y1,1
	mPrintString cel9

	lrv X1,0
	rvadd y1, 9
	mPrintString cel10

	lrv X1,0
	rvadd y1, 9
	mPrintString cel11

	lrv X1,0
	rvadd y1, 9
	mPrintString cel12

	lrv X1,0
	rvadd y1, 9
	mPrintString cel13

	lrv X1,0
	rvadd y1, 9
	mPrintString cel14


	lrv X1, 120
	lrv Y1, 1
	mov t, xl
	call PrintChar

	lrv X1, 85
	ldi t, 9
	mul xh, t
	mov t, r0
	subi t, -10
	sts Y1, t
	mPrintString cel16

	call LcdUpdate

	ldi yh, 7
cel17:	ldi yl, 0
	call wms
	dec yh
	brne cel17

	inc xh
	cpi xh, 5
	breq cel20
	rjmp cel15

cel20:	ldi xh, 0

	dec xl
	cpi xl, '/'
	breq cel21
	rjmp cel15

cel21:	call LcdClear


	
	lrv X1,25
	lrv Y1,25
	mPrintString cel19


	call LcdUpdate

	ldi yl, 0
	call wms

	ldi zl, 16					;calibrate accerellometers, average of 16 readings

	b16clr AccXZero
	b16clr AccYZero
	b16clr AccZZero

caa1:	call AdcRead

	b16add AccXZero, AccXZero, AccX
	b16add AccYZero, AccYZero, AccY
	b16add AccZZero, AccZZero, AccZ

	ldi yl, 100
	call wms

	dec zl
	breq caa2
	rjmp caa1

caa2:	b16fdiv AccXZero, 4
	b16fdiv AccYZero, 4
	b16fdiv AccZZero, 4

	ldi yh, 40
cel22:	ldi yl, 0
	call wms
	dec yh
	brne cel22

	call LcdClear		;show and check result 

	rvsetflagtrue flagSensorsOk

.set xoff = 0
.set yoff = 0


	lrv X1, xoff		;acc X
	lrv Y1, yoff + 10
	mPrintString sen5
	b16load AccXZero
	call Print16Signed 
	call AccCheck

	lrv X1, xoff		;acc Y
	lrv Y1, yoff + 19
	mPrintString sen6
	b16load AccYZero
	call Print16Signed 
	call AccCheck

	lrv X1, xoff		;acc Z
	lrv Y1, yoff + 28
	mPrintString sen7
	b16load AccZZero
	call Print16Signed 
	call AccCheck

		;footer
	lrv X1, 0
	lrv Y1, 57
	mPrintString cel1

	call LcdUpdate


	rvbrflagfalse flagSensorsOk, cel35

	ldz EeSensorCalData	;save calibration data if passed.
		
	b16load AccXZero
	call StoreEeVariable168
	b16load AccYZero
	call StoreEeVariable168
	b16load AccZZero
	call StoreEeVariable168

	ldz eeSensorsCalibrated	;OK
	setflagtrue t
	call WriteEeprom
	lrv Status, 0

	rjmp cel23

cel35:	ldz eeSensorsCalibrated	;Failed
	setflagfalse t
	call WriteEeprom
	lrv Status, 1
	

cel23:	call GetButtonsBlocking
	cpi t, 0x01		;CONTINUE?
	brne cel23

	call LcdClear

	rvbrflagfalse flagSensorsOk, cel29
	rjmp cel33

cel29:	lrv X1,0
	lrv Y1,25
	mPrintString cel24

	rjmp cel30

cel33:	lrv X1,0
	lrv Y1,25
	mPrintString cel31

cel30:		;footer
	lrv X1, 0
	lrv Y1, 57
	mPrintString cel1

	call LcdUpdate

cel32:	call GetButtonsBlocking
	cpi t, 0x01		;CONTINUE?
	brne cel32

	ret



gyrocal:
	ldi zl, 16					;calibrate gyros, average of 16 readings

	b16clr GyroRollZero
	b16clr GyroPitchZero
	b16clr GyroYawZero

cna1:	call AdcRead

	b16add GyroRollZero, GyroRollZero, GyroRoll
	b16add GyroPitchZero, GyroPitchZero, GyroPitch
	b16add GyroYawZero, GyroYawZero, GyroYaw

	ldi yl, 100
	call wms

	dec zl
	breq cna2
	rjmp cna1

cna2:	b16fdiv GyroRollZero, 4
	b16fdiv GyroPitchZero, 4
	b16fdiv GyroYawZero, 4

	rvsetflagtrue flagGyrosCalibrated

	ret



cel1:	.db "             CONTINUE", 0

cel2:	.db "Place the aircraft on", 0
cel3:   .db "a level surface and",0
cel4:	.db "press CONTINUE.",0
cel6:	.db "The FC will then wait", 0
cel7:	.db "5 sec to let the", 0, 0
cel8:	.db "aircraft settle down.", 0

cel9:	.db "     lda #$35", 0
cel10:	.db "lol: sta $0427", 0, 0
cel11:	.db "     sec", 0, 0
cel12:	.db "     sbc #$01", 0
cel13:	.db "     cmp #$2f", 0
cel14:	.db "     bne lol", 0, 0

cel16:	.db "<--", 0

cel19:	.db "Calibrating...", 0, 0

cel24:	.db "Calibration failed.", 0

cel31:	.db "Calibration succeeded", 0

