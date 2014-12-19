
FlightInit:

.def Counter=r17

	ldz eeSwitchSSPI			;have to get this first
	call ReadEepromP1
	sts flagSwitchSSPI, t
	rvbrflagfalse flagSwitchSSPI, flia
	ser t						;force use of ProfileP1 as SwitchSSPI is true
	sts flagProfileP1, t
	rjmp flib
flia:
	ldz eeProfileP1				;have to get this second
	call ReadEepromP1
	sts flagProfileP1, t

flib:
	ldi Counter, 64		;copy Mixertable from EE to RAM
	ldx RamMixerTable
	ldz EeMixerTable
fli1:	call ReadEeprom
	st x+, t
	adiw z, 1
	dec counter
	brne fli1


	ldz EeParameterTable	;copy and scale PI gain and limits from EE to 16.8 variables
	call fli2
	b16mov PgainRoll, Temp

	call fli2
	call fli5
	b16mov PlimitRoll, Temp

	call fli2
	call fli3
	b16mov IgainRoll, Temp

	call fli2
	call fli5
	b16mov IlimitRoll, Temp


	call fli2
	b16mov PgainPitch, Temp

	call fli2
	call fli5
	b16mov PlimitPitch, Temp

	call fli2
	call fli3
	b16mov IgainPitch, Temp

	call fli2
	call fli5
	b16mov IlimitPitch, Temp


	call fli2
	b16mov PgainYaw, Temp

	call fli2
	call fli5
	b16mov PlimitYaw, Temp

	call fli2
	call fli3
	b16mov IgainYaw, Temp

	call fli2
	call fli5
	b16mov IlimitYaw, Temp

	ldz EeParameterTable	;copy and scale Profile2 PI gain and limits from EE to 16.8 variables
	call fli2P2
	b16mov PgainRollP2, Temp

	call fli2P2
	call fli5
	b16mov PlimitRollP2, Temp

	call fli2P2
	call fli3
	b16mov IgainRollP2, Temp

	call fli2P2
	call fli5
	b16mov IlimitRollP2, Temp


	call fli2P2
	b16mov PgainPitchP2, Temp

	call fli2P2
	call fli5
	b16mov PlimitPitchP2, Temp

	call fli2P2
	call fli3
	b16mov IgainPitchP2, Temp

	call fli2P2
	call fli5
	b16mov IlimitPitchP2, Temp


	call fli2P2
	b16mov PgainYawP2, Temp

	call fli2P2
	call fli5
	b16mov PlimitYawP2, Temp

	call fli2P2
	call fli3
	b16mov IgainYawP2, Temp

	call fli2P2
	call fli5
	b16mov IlimitYawP2, Temp
	
	ldi Counter, 8			;Prepare the OutputRateBitmask and OutputTypeBitmask variable
	ldz RamMixerTable 
fli6:	ldd t, z + MixvalueFlags

	clc
	sbrc t, bMixerFlagRate
	sec
	ror xl

	clc
	sbrc t, bMixerFlagType
	sec
	ror xh

	adiw z, 8
	dec Counter
	brne fli6

	sts OutputRateBitmask, xl

	sts OutputTypeBitmask, xh

.undef Counter

	b16ldi Temp, 2220			;preload the servo filters
	lrv Index, 0
fli8:	b16store_array FilteredOut1, Temp
	rvinc Index
	rvcpi Index, 8
	brne fli8

	ldz eeEscLowLimit
	call fli2
	b16ldi Temper, 44.4
	b16mul EscLowLimit, Temp, Temper

	rvsetflagfalse flagRollRev
	ldz eeStickScaleRoll			;copy and scale Profile1 Stick Scale from EE to 16.8 variables
	call fli2
	tst xh
	brpl flirev1
	com xl
	com xh
	ldi t,1
	add xl,t
	clr t
	adc xh,t 
	b16store Temp
	rvsetflagtrue flagRollRev
flirev1:
	call fli3
	b16mov StickScaleRoll, Temp

	rvsetflagfalse flagPitchRev
	ldz eeStickScalePitch
	call fli2
	tst xh
	brpl flirev2
	com xl
	com xh
	ldi t,1
	add xl,t
	clr t
	adc xh,t 
	b16store Temp
	rvsetflagtrue flagPitchRev
flirev2:
	call fli3
	b16mov StickScalePitch, Temp

	rvsetflagfalse flagYawRev
	ldz eeStickScaleYaw
	call fli2
	tst xh
	brpl flirev3
	com xl
	com xh
	ldi t,1
	add xl,t
	clr t
	adc xh,t 
	b16store Temp
	rvsetflagtrue flagYawRev
flirev3:
	call fli3
	b16mov StickScaleYaw, Temp

	ldz eeStickScaleThrottle			
	call fli2
	tst xh
	brpl flirev4
	com xl
	com xh
	ldi t,1
	add xl,t
	clr t
	adc xh,t 
	b16store Temp
flirev4:
	call fli3
	b16mov StickScaleThrottle, Temp

	ldz eeStickScaleRoll			;copy and scale Profile2 Stick Scale from EE to 16.8 variables
	call fli2P2
	tst xh
	brpl flirev12
	com xl
	com xh
	ldi t,1
	add xl,t
	clr t
	adc xh,t 
	b16store Temp
flirev12:
	call fli3
	b16mov StickScaleRollP2, Temp

	ldz eeStickScalePitch
	call fli2P2
	tst xh
	brpl flirev13
	com xl
	com xh
	ldi t,1
	add xl,t
	clr t
	adc xh,t 
	b16store Temp
flirev13:
	call fli3
	b16mov StickScalePitchP2, Temp

	ldz eeStickScaleYaw
	call fli2P2
	tst xh
	brpl flirev14
	com xl
	com xh
	ldi t,1
	add xl,t
	clr t
	adc xh,t 
	b16store Temp
flirev14:
	call fli3
	b16mov StickScaleYawP2, Temp

	ldz eeStickScaleThrottle
	call fli2P2
	tst xh
	brpl flirev15
	com xl
	com xh
	ldi t,1
	add xl,t
	clr t
	adc xh,t 
	b16store Temp
flirev15:
	call fli3
	b16mov StickScaleThrottleP2, Temp

	ldz eeServoFilter
	call fli2
	b16ldi Temper, 100
	b16sub ServoFilter, Temper, Temp
	b16fdiv ServoFilter, 7


	ldz eeSelflevelPgain			;copy and scale Profile1 Self Level P gain & limit from EE to 16.8 variables
	call fli2
;	call fli3
	b16mov SelflevelPgain, Temp		
						;set flag if SLPgain is zero
	rvsetflagfalse flagSLPGZero		;assume false
	b16clr	Temp
	b16cmp SelflevelPgain, Temp
	brne fli14
	rvsetflagtrue  flagSLPGZero		;set true as SLPgain is zero
fli14:
	ldz eeSelflevelPlimit
	call fli2
	b16ldi Temper, 10
	b16mul SelflevelPlimit, Temp, Temper

	ldz eeSelflevelPgain			;copy and scale Profile2 Self Level P gain & limit from EE to 16.8 variables
	call fli2P2
;	call fli3
	b16mov SelflevelPgainP2, Temp
						;set flag if SLP2gain is zero
	rvsetflagfalse flagSLPGP2Zero		;assume false
	b16clr	Temp
	b16cmp SelflevelPgainP2, Temp
	brne fli15
	rvsetflagtrue  flagSLPGP2Zero		;set true as SLP2gain is zero
fli15:
	ldz eeSelflevelPlimit
	call fli2P2
	b16ldi Temper, 10
	b16mul SelflevelPlimitP2, Temp, Temper

	ldz eeHeightDampeningGain
	call fli2
	b16mov HeightDampeningGain, Temp

	ldz eeHeightDampeningLimit
	call fli2
	call fli5
	b16mov HeightDampeningLimit, Temp

	ldz eeBattAdcTrim	;range -6 to +6
	call fli2
	b16ldi Temper, 4
	b16mul BattAdcTrim, Temp, Temper	;multiply by 4
	
	ldz eeBattAlarmVoltage
	call fli2
	b16ldi Temper, 3.865 ; was 3.7236 but they changed Vref
	b16mul BattAlarmVoltage, Temp, Temper
	b16add BattAlarmVoltage, BattAlarmVoltage, BattAdcTrim
	
	ldz eeAccSWFilter
	call fli2
	b16fdiv Temp, 8
	b16mov AccSWFilter, Temp

	ldz eeAccTrimRoll
	call fli2
	b16fdiv Temp, 3
	b16mov AccTrimRoll, Temp

	ldz eeAccTrimPitch
	call fli2
	b16fdiv Temp, 3
	b16mov AccTrimPitch, Temp



	ldz eeCamRollGain
	call fli2
	call fli3
	b16mov CamRollGain, Temp

	ldz eeCamRollOffset
	call fli2
	call fli9
	b16mov CamRollOffset, Temp

	ldz eeCamPitchGain
	call fli2
	call fli3
	b16mov CamPitchGain, Temp

	ldz eeCamPitchOffset
	call fli2
	call fli9
	b16mov CamPitchOffset, Temp

	ldz EeSensorCalData		;load calibration data

	call GetEeVariable168
	b16store AccXZero
	call GetEeVariable168
	b16store AccYZero
	call GetEeVariable168
	b16store AccZZero

	clr t
	sts flagSelfLevelType, t
	sts flagSelfLevelAlwaysOn, t
	sts flagSelfLevelDisabled, t

	ldz eeSelfLevelType		;read flags from EE
	call ReadEeprom

	ldz eeSelfLevelType
	call GetEeVariable8 
	sts SelfLevelType, xl

	cpi xl, 0
	brne fli11a1
	clr t
	sts flagSelfLevelType, t
	rjmp fli11a4

fli11a1:
	cpi xl, 1
	brne fli11a2
	ser t
	sts flagSelfLevelType, t
	rjmp fli11a4

fli11a2:
	cpi xl, 2
	brne fli11a3
	ser t
	sts flagSelfLevelAlwaysOn, t
	rjmp fli11a4

fli11a3:
	ser t
	sts flagSelfLevelDisabled, t


fli11a4:
	ldz eeLinkRollPitch
	call ReadEeprom
	sts flagRollPitchLink, t

	ldz eeAutoDisarm
	call ReadEeprom
	sts flagAutoDisarm, t
	
	lrv OutputRateDividerCounter, 1
	lrv OutputRateDivider, 5		;slow rate divider. f = 400 / OutputRateDivider

	rvsetflagtrue flagLcdUpdate

	rvsetflagfalse flagMutePwm

	rvsetflagfalse flagArmed
	rvsetflagfalse flagArmedOldState

	lrv RxTimeoutLimit, 250

	lrv ButtonDelay, 0
	
	b16clr AutoDisarmDelay

	b16ldi BatteryVoltageLowpass, 1023

	b16clr BeeperDelay

	b16clr ArmedBeepDds

	b16clr NoActivityTimer
	b16clr NoActivityDds
	 
	rvsetflagfalse flagGeneralBuzzerOn
	rvsetflagfalse flagLvaBuzzerOn
	rvsetflagfalse flagDebugBuzzerOn
	rvsetflagfalse flagGyrosCalibrated

	b16clr LiveUpdateTimer

	b832clr VectorX				;set 3d vector to point straight up
	b832clr VectorY
	b832ldi VectorZ, 1

	b16clr EulerAngleRoll
	b16clr EulerAnglePitch
		
	lds		t,afs_sel			; get acc setting
	andi	t,0b00011000
	lsr		t
	lsr		t
	lsr		t

	cpi		t,3					;  is it 16g?
	brge	setup16glng			;  yes
	cpi		t,2					;  is it 8g?
	brge	setup8glng				;  yes
	cpi		t,1					;  is it 4g?
	brge	setup4g				;  yes

;AccZTest : 2g = 128 : 4g = 64 : 8g = 32 : 16g = 16
;TiltAngMul : 0.33 is 2g multiplier : 0.66 is 4g multiplier : 1.32 is 8g multiplier : 2.64 is 16g multiplier

setup2g:
	b16ldi	AccZTest,128
;	b832ldi MagAccMinTest, -0.25
;	b832ldi MagAccMaxTest,  0.25
	b16ldi	TiltAngMult,0.33
	rjmp	accsetupend

setup16glng: rjmp setup16g
setup8glng:  rjmp setup8g			

setup4g:
	b16ldi	AccZTest,64
;	b832ldi MagAccMinTest, -0.0625
;	b832ldi MagAccMaxTest,  0.0625
	b16ldi	TiltAngMult,0.66
	rjmp	accsetupend

setup8g:
	b16ldi	AccZTest,32
;	b832ldi MagAccMinTest, -0.015625
;	b832ldi MagAccMaxTest,  0.015625
	b16ldi	TiltAngMult,1.32
	rjmp	accsetupend

setup16g:
	b16ldi	AccZTest,16
;	b832ldi MagAccMinTest, -0.00390625
;	b832ldi MagAccMaxTest,  0.00390625
	b16ldi	TiltAngMult,2.64

accsetupend:

	b832ldi	MagicNumberMult, 1.830082440462336 ;1.830082440462336*(6250/4096)=2.7924841926 (all settings use this magic number as the GyroRate is scaled instead in imu.asm)

	lds		t,gfs_sel			; get gyro setting
	andi	t,0b00011000
	lsr		t
	lsr		t
	lsr		t

	cpi		t,3					;  is it 2000 dps
	brge	setup2000			;  yes
	cpi		t,2					;  is it 1000 dps
	brge	setup1000			;  yes
	cpi		t,1					;  is it  500 dps
	brge	setup500			;  yes
	rjmp	Setup250

setup2000:
	ldi	t,4
	sts GyroMult, t	
	rjmp	gyrosetupend

setup1000:
	ldi	t,2
	sts GyroMult, t	
	rjmp	gyrosetupend

setup500:
	ldi	t,1
	sts GyroMult, t	
	rjmp	gyrosetupend

Setup250:
	ldi	t,0
	sts GyroMult, t	

gyrosetupend:

	ldz eeServoOnArm
	call ReadEeprom
	sts flagServoOnArm, t

	ldz eeBoardOffset
	call ReadEeprom
	sts BoardOffset, t

	ldz eeSpinOnArm
	call ReadEeprom
	sts flagSpinOnArm, t

	ldz eeSSGimbal
	call ReadEeprom
	sts FlagSSGimbal, t

	ldz eeTXGimbal
	call ReadEeprom
	sts TXGimbal, t

	ldz eeflagLMA
	call ReadEeprom
	sts flagLMA, t

	ldz eeChannelMap
	call ReadEeprom
	sts flagChannelMap, t

	ldz eeAltSafeScreen
	call ReadEeprom
	sts flagAltSafeScreen, t

	ldz eeOut1Low
	lds t, OutputTypeBitmask			;ESC or SERVO?						
	lsr t							
	sts OutputTypeBitmaskCopy, t		
	brcc O1K							;Branch as it's a Servo so we'll use the End Point Limits				
	b16ldi Out1Low, 0					;ESC so we use limits of 0 and 555
	b16ldi Out1High, 555
	adiw z,4							;Compensate for the 4 EEPROM addresses we've skipped
	rjmp O2J
O1K:
	call fli2
	call fli10
	b16mov Out1Low, Temp

	call fli2
	call fli10
	b16mov Out1High, Temp

O2J:
	lds t, OutputTypeBitmaskCopy		;ESC or SERVO?
	lsr t							
	sts OutputTypeBitmaskCopy, t
	brcc O2K							;Branch as it's a Servo so we'll use the End Point Limits

	b16ldi Out2Low, 0					;ESC so we use limits of 0 and 555
	b16ldi Out2High, 555
	adiw z,4							;Compensate for the 4 EEPROM addresses we've skipped
	rjmp O3J
O2K:
	call fli2
	call fli10
	b16mov Out2Low, Temp

	call fli2
	call fli10
	b16mov Out2High, Temp
O3J:
	lds t, OutputTypeBitmaskCopy		;ESC or SERVO?
	lsr t							
	sts OutputTypeBitmaskCopy, t
	brcc O3K							;Branch as it's a Servo so we'll use the End Point Limits

	b16ldi Out3Low, 0					;ESC so we use limits of 0 and 555
	b16ldi Out3High, 555
	adiw z,4							;Compensate for the 4 EEPROM addresses we've skipped
	rjmp O4J
O3K:
	call fli2
	call fli10
	b16mov Out3Low, Temp

	call fli2
	call fli10
	b16mov Out3High, Temp
O4J:
	lds t, OutputTypeBitmaskCopy		;ESC or SERVO?
	lsr t							
	sts OutputTypeBitmaskCopy, t
	brcc O4K							;Branch as it's a Servo so we'll use the End Point Limits

	b16ldi Out4Low, 0					;ESC so we use limits of 0 and 555
	b16ldi Out4High, 555
	adiw z,4							;Compensate for the 4 EEPROM addresses we've skipped
	rjmp O5J
O4K:
	call fli2
	call fli10
	b16mov Out4Low, Temp

	call fli2
	call fli10
	b16mov Out4High, Temp
O5J:
	lds t, OutputTypeBitmaskCopy		;ESC or SERVO?
	lsr t							
	sts OutputTypeBitmaskCopy, t
	brcc O5K							;Branch as it's a Servo so we'll use the End Point Limits

	b16ldi Out5Low, 0					;ESC so we use limits of 0 and 555
	b16ldi Out5High, 555
	adiw z,4							;Compensate for the 4 EEPROM addresses we've skipped
	rjmp O6J
O5K:
	call fli2
	call fli10
	b16mov Out5Low, Temp

	call fli2
	call fli10
	b16mov Out5High, Temp
O6J:
	lds t, OutputTypeBitmaskCopy		;ESC or SERVO?
	lsr t							
	sts OutputTypeBitmaskCopy, t
	brcc O6K							;Branch as it's a Servo so we'll use the End Point Limits

	b16ldi Out6Low, 0					;ESC so we use limits of 0 and 555
	b16ldi Out6High, 555
	adiw z,4							;Compensate for the 4 EEPROM addresses we've skipped
	rjmp O7J
O6K:
	call fli2
	call fli10
	b16mov Out6Low, Temp

	call fli2
	call fli10
	b16mov Out6High, Temp
O7J:
	lds t, OutputTypeBitmaskCopy		;ESC or SERVO?
	lsr t							
	sts OutputTypeBitmaskCopy, t
	brcc O7K							;Branch as it's a Servo so we'll use the End Point Limits
			
	b16ldi Out7Low, 3					;ESC so we use limits of 3 and 2500
	b16ldi Out7High, 2500
	adiw z,4							;Compensate for the 4 EEPROM addresses we've skipped
	rjmp O8J
O7K:
	call fli2
	call fli12
	b16mov Out7Low, Temp

	call fli2
	call fli12
	b16mov Out7High, Temp
O8J:
	lds t, OutputTypeBitmaskCopy		;ESC or SERVO?
	lsr t							
	brcc O8K							;Branch as it's a Servo so we'll use the End Point Limits
			
	b16ldi Out8Low, 3					;ESC so we use limits of 3 and 2500
	b16ldi Out8High, 2500
	rjmp OutEnd
O8K:
	call fli2
	call fli12
	b16mov Out8Low, Temp

	call fli2
	call fli12
	b16mov Out8High, Temp

OutEnd:
	; check if a motor layout is selected

	lds t,Status	; Clear motor layout bit
	andi t,0x07
	sts Status,t

	ldz eeSelectedMotorLayout
	call ReadEeprom
	sts SelectedMotorLayout, t

	cpi t, 0xFF
	breq fli13a
	rjmp fli13
fli13a:
	lrv Status, 8
	ret

fli13:
	rvbrflagtrue flagSelfLevelDisabled, fli11
	ldz eeSensorsCalibrated
	call ReadEeprom
	brflagtrue t, fli11
	lrv Status, 1
	ret

fli11:	call SanityCheck
	ret
	
	
	;---

fli3:	b16fdiv Temp, 4		;divide temp by 16
	ret


	;---

fli2:	call ReadEeprom		;Temp = (Z+)
	adiw z, 1
	mov xl, t
	call ReadEeprom
	adiw z, 1
	mov xh, t
	clr yh
	b16store Temp
	ret

fli2P2:	call ReadEepromP2		;Temp = (Z+)
	adiw z, 1
	mov xl, t
	call ReadEepromP2
	adiw z, 1
	mov xh, t
	clr yh
	b16store Temp
	ret

fli5:	b16ldi Temper, 113.664	;most limit values (0-100%) are scaled with 113.664 to fit to the 11366.4 full throttle value
	b16mul Temp, Temp, Temper
	ret

fli9:	b16ldi Temper, 44.4
	b16mul Temp, Temp, Temper
	ret

fli10:	b16ldi Temper, 5.55		;for the 555 Timer ESC / Servos
	b16mul Temp, Temp, Temper
	b16ldi Temper, 555
	b16cmp Temp, Temper
	brge fli10a
	ret
fli10a: b16mov Temp, Temper		;limit max to 555
	ret

fli12:	b16ldi Temper, 25		;for the Timer1 ESC / Servos
	b16mul Temp, Temp, Temper
	b16ldi Temper, 2500			;limit max to 2500
	b16cmp Temp, Temper
	brge fli12a
	b16ldi Temper, 3			;limit min to 3
	b16cmp Temp, Temper
	brlt fli12a
	ret
fli12a: b16mov Temp, Temper		;set to limit
	ret

	;---

SanityCheck:
	call LcdClear
	
	lrv PixelType, 1
	lrv FontSelector, f6x8

;	CheckLimit SelflevelGain, 0, 501, san1
;	CheckLimit SelflevelLimit, 0, 3411, san1			;30%
	

	CheckLimit EscLowLimit, 0, 888, san1				;20%

	CheckLimit HeightDampeningGain, 0, 501 ,san1
	CheckLimit HeightDampeningLimit, 0, 3411 ,san1			;30%


	CheckLimit GyroRollZero, GyroLowLimit, GyroHighLimit, san2
	CheckLimit GyroPitchZero, GyroLowLimit, GyroHighLimit, san2
	CheckLimit GyroYawZero, GyroLowLimit, GyroHighLimit, san2

	rvbrflagtrue flagSelfLevelDisabled, sanc1
	CheckLimit AccXZero, AccLowLimit, AccHighLimit, san2
	CheckLimit AccYZero, AccLowLimit, AccHighLimit, san2
	CheckLimit AccZZero, AccLowLimit, AccHighLimit, san2
sanc1:
	call AdcRead
	call AdcRead

	CheckLimit GyroRoll, 100, 900, san3
	CheckLimit GyroPitch, 100, 900, san3
	CheckLimit GyroYaw, 100, 900, san3

	rvbrflagtrue flagSelfLevelDisabled, sanc2
	CheckLimit AccX, 100, 900, san3
	CheckLimit AccY, 100, 900, san3
	CheckLimit AccZ, 100, 900, san3
sanc2:
	ret 				;No errors, return


san1:	lrv X1,0			;yes, print error message			
	lrv Y1,15
	mPrintString mad1
	lrv X1,0
	lrv Y1,24
	mPrintString mad2
	rjmp san4


		
san2:	lrv X1,0			;yes, print error message			
	lrv Y1,15
	mPrintString mad5
	lrv X1,0
	lrv Y1,24
	mPrintString mad6
	rjmp san4

		
san3:	lrv X1,0			;yes, print error message			
	lrv Y1,15
	mPrintString mad7
	lrv X1,0
	lrv Y1,24
	mPrintString mad6


san4:	lrv Status, 7			;Error
	
	lrv X1,0
	lrv Y1,40
	mPrintString mad3

	lrv X1,35
	lrv Y1,1
	mPrintString mad8

	lrv X1, 0
	lrv Y1, 57
	mPrintString mad4

	call LcdUpdate

	BuzzerOn
	ldi yh, 39
san5:	ldi yl, 0
	call wms
	dec yh
	brne san5
	BuzzerOff

san6:	call GetButtonsBlocking
	cpi t, 0x01
	brne san6	

	ret





limit:
	cp  xl, yl	;less?
	cpc xh, yh
	brlt lim1
	cp  xl, zl	;greater?
	cpc xh, zh
	brge lim1
	clc		;OK
	ret
lim1:	sec		;not OK
	ret




mad1:	.db "One or more setting", 0
mad2:	.db "is outside its limits", 0

mad3:	.db "Check your settings.", 0, 0

mad4:	.db "             CONTINUE", 0

mad5:	.db "Sensor calibration", 0, 0
mad6:	.db "data out of limits.", 0

mad7:	.db "Sensor raw data", 0

mad8:	.db "WARNING!", 0, 0

;call SerOut16
;ldi xl, 0x0d
;call SerByteOut

