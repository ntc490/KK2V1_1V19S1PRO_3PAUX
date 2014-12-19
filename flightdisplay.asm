

UpdateFlightDisplay:

	rvsetflagtrue flagMutePwm

	call LcdClear

	lrv PixelType, 1
	lrv FontSelector, f12x16


	;--- print armed status ---

	rvbrflagfalse flagArmed, udp3

	lrv X1, 34				;Armed
	lrv Y1, 22
	mPrintString upd5

	rjmp udp21a

udp3:	
	rvbrflagtrue flagAltSafeScreen, udp22	; Skip large SAFE or ERROR if AltSafeScreen is selected

	lrv Y1, 0

	lds t, status		;Safe or Error
	cpi t, 0x01
	brge udp3a

;	rjmp imudebug				;enable this line for IMU debug screen
	lrv X1, 38			
	mPrintString upd2	;SAFE
	rjmp udp22
udp3a:
	lrv X1, 34
	mPrintString upd4	;ERROR

udp22:

	;--- Print footer if safe or error ---

	rvbrflagtrue flagArmed, udp20


	lrv X1, 0				;footer
	lrv Y1, 57
	lrv FontSelector, f6x8
	mPrintString upd1
udp20:
	lrv X1, 0				
	lrv Y1, 0
	rvbrflagfalse flagAltSafeScreen, udp22a	;check to print little Safe or Error on first line
	lds t, status		;Safe or Error
	cpi t, 0x01
	brge udp63
	
	mPrintString udp60	;SAFE
	rjmp udp22a
udp63:
	mPrintString udp59	;ERROR
udp22a:
	rvbrflagfalse flagArmed, udp23		;skip the rest if armed
	rjmp udp21
udp23:	

	rvbrflagfalse flagSwitchSSPI, udp23a

	;--- print PI1 or PI2 in top right

	lrv X1, 109
	lrv Y1, 0
	lrv FontSelector, f6x8

	rvbrflagfalse flagProfileP1, udp23d
	mPrintString udp57
	rjmp udp23c
udp23d:
	mPrintString udp58
	rjmp udp23c

	;--- print Profile P1 or P2 in top right
udp23a:
	lrv X1, 115
	lrv Y1, 0
	lrv FontSelector, f6x8
	rvbrflagtrue flagProfileP1, udp23b
	mPrintString udp56
	rjmp udp23c
udp23b:
	mPrintString udp55
udp23c:
	;--- print Selflevel status ---

	lrv X1, 0
	lrv Y1, 18
	lrv FontSelector, f6x8

	mPrintString udp9	;"Self-level is "

	rvbrflagfalse flagSelfLevelDisabled, udp23f
	mPrintString udp11a ;"None"
	rjmp udp13

udp23f:
	rvbrflagfalse flagSelfLevelOn, udp12   ; If self level is NOT On, it is "Off"

	rvflagnot flagB, flagProfileP1
	rvflagand flagA, flagB, flagSwitchSSPI
	rvbrflagtrue flagA, udp12a

	rvbrflagtrue flagSLPGZero, udp12	   ; If Profile 1 SL P Gain is zero then self level is "Off"
	rjmp udp12b

udp12a:
	rvbrflagtrue flagSLPGP2Zero, udp12	   ; If Profile 2 SL P Gain is zero then self level is "Off"

udp12b:
	mPrintString udp10	;"On"
	rjmp udp13
udp12:	mPrintString udp11	;"Off"
udp13:	

	;--- Print status ----

	lrv X1, 0
	lrv Y1, 27

	ldz udp24*2
	lds t, status
	lsl t
	add zl, t
	clr t
	adc zh, t

	lpm xl, z+
	lpm xh, z
	
	movw z, x
	
	call PrintString
	 

	;--- Print battery voltage

	b16ldi Temp, 13.25 
	b16mul Temp, BatteryVoltage, Temp
	b16ldi	Temper, 8    ; prevent rounding
	b16add  Temp, Temp, Temper
	b16fdiv Temp, 9		 ;(13.25/512 = 0.02587890625)

	b16ldi Temper, 0	;Now we have trim, set to display zero if trimmed voltage is less than zero
	b16cmp Temp, Temper
	brge udp13a
	b16ldi Temp, 0

udp13a:	
	lrv X1, 0
	lrv Y1, 36
	lrv FontSelector, f6x8

	mPrintString udp30

	lrv X1, (5*6)-2

	b16load Temp
 	call Print16Signed 
	
	ldi t,'.'
	call PrintChar

	mov xl, yh
	clr xh
	b16store Temp

	b16ldi Temper, 0.0390625
	b16mul Temp, Temp, Temper

	b16ldi Temper,10		; stops printing XX.10V by rounding down
	b16cmp Temp, Temper
	brne printv
	b16ldi Temper,1
	b16sub Temp, Temp, Temper

printv:
	b16load Temp
 	call Print16Signed 

	ldi t,'V'
	call PrintChar

	;--- Print MPU6050 temperature

	lrv X1, 60
	lrv Y1, 36
	lrv FontSelector, f6x8
	mPrintString udp32

	b16ldi	Temp, 12420.2
	b16add	Temp, MPU6050Temperature, Temp
	b16ldi  Temper, 1.50588
	b16mul	Temp, Temp, Temper
	b16fdiv Temp, 9
	b16load Temp
	call Print16Signed
	ldi t,'.'
	call PrintChar

	mov xl, yh
	clr xh
	b16store Temp

	b16ldi Temper, 0.0390625
	b16mul Temp, Temp, Temper

	b16ldi Temper,10		; stops printing XX.10V by rounding down
	b16cmp Temp, Temper
	brne printt
	b16ldi Temper,1
	b16sub Temp, Temp, Temper

printt:
	b16load Temp
 	call Print16Signed 

	ldi t,'C'
	call PrintChar

	lrv X1, 0			;show Euler angles
	lrv Y1, 45
	mPrintString udp18
	b16load EulerAngleRoll
	rvbrflagfalse flagGyrosCalibrated, udp40
 	call Print16Signed 
udp40:
	lrv X1, 0
	lrv Y1, 54
	mPrintString udp19
	b16load EulerAnglePitch
	rvbrflagfalse flagGyrosCalibrated, udp41
 	call Print16Signed 
udp41:

	lrv X1, 0			;display pwmerrorcoutner in top left if there were 2 or more errors
	lrv Y1, 0
	b16ldi Temp, 2		;you always get one error when the screen is updated with "ARMED" so we ignore it
	b16cmp PwmErrorCounter, Temp
	brlt udp21
	b16load PwmErrorCounter
	call Print16Signed 

udp21:

	rvbrflagfalse flagAltSafeScreen, udp21a ;check to see if we display motor layout on second line

	;display Motor Layout Selected
	
	lds t, SelectedMotorLayout
	cpi t,0xFF
	breq udp21a

	mov xl,t

	ldzarray loa1 * 2, 20, xl

	lrv X1, 0			
	lrv Y1, 9

	ldi xh,19

udp21b:
	lpm t,z+
	call PrintChar
	dec xh
	brpl udp21b


udp21a:	call LcdUpdate

	rvsetflagfalse flagMutePwm

	ret


upd1:	.db "                 MENU",0
upd2:	.db 66,58,61,60, 0, 0		;the text "SAFE" in the mangled 12x16 font
upd4:   .db 60,65,65,64,65, 0		;the text "ERROR" in the mangled 12x16 font
upd5:	.db 58,65,62,60,59, 0		;the text "ARMED" in the mangled 12x16 font

udp9:	.db "Self-level is ",0,0
udp10:	.db "ON",0,0
udp11:	.db "OFF",0
udp11a:  .db "None",0,0

udp30:	.db "Batt:",0
udp32:	.db "Temp:",0

udp18:	.db " Roll Angle:", 0, 0
udp19:	.db "Pitch Angle:", 0, 0

udp55:  .db "P1", 0, 0
udp56:  .db "P2", 0, 0
udp57:  .db "PI1",0
udp58:  .db "PI2",0



sta0:	.db "OK.",0
sta1:	.db "Error: Calibrate ACC ",0
sta2:	.db "Error: no Roll input ",0
sta3:	.db "Error: no Pitch input",0
sta4:	.db "Error: no Thro input ",0
sta5:	.db "Error: no Yaw input  ",0
sta6:	.db "Error: no AUX input  ",0
sta7:	.db "Error: Sanity check  ",0
sta8:   .db "Error No Motor Layout",0

udp59:  .db "        ERROR        ",0
udp60:  .db "        SAFE         ",0
  


udp24:	.dw sta0*2, sta1*2, sta2*2, sta3*2, sta4*2, sta5*2, sta6*2, sta7*2, sta8*2


/*

	;--- 3D vector debug code, show vector and angles

imudebug:

	lrv PixelType, 1
	lrv FontSelector, f6x8

	lrv X1, 0
	lrv Y1, 0
	b824load VectorX
	call b824print

	rvadd X1, 8
	b824load VectorY
	call b824print

	lrv X1, 0
	lrv Y1, 8
	b824load VectorZ
	call b824print

	rvadd X1, 8
	b824load LengthVector
	call b824print


	lrv X1, 0
	lrv Y1, 20
	b16load gyroRoll
	clr yl 
	call b824print
	
	lrv X1, 64
	lrv Y1, 20
	b16load EulerAngleRoll
	clr yl 
	call b824print




	lrv X1, 0
	lrv Y1, 45
	mPrintString udp18
	b16load EulerAngleRoll
 	call Print16Signed 


	lrv X1, 0
	lrv Y1, 54
	mPrintString udp19
	b16load EulerAnglePitch
 	call Print16Signed 


	lrv X1, 100
	lrv Y1, 45
	b16load AccAngleRoll
 	call Print16Signed 


	lrv X1, 100
	lrv Y1, 54
	b16load AccAnglePitch
 	call Print16Signed 





	rjmp udp21




	;---- end of debug code

*/

