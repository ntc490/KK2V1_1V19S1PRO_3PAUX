
.def	Counter = r17

EeInit:

	ldz 0		;EE initalized? (only check P1)
	call ReadEepromP1
	adiw z, 1
	cpi t, 0x19
	brne eei1

	call ReadEepromP1
	adiw z, 1
	cpi t, 0x03
	brne eei1

	call ReadEepromP1
	adiw z, 1
	cpi t, 0x73
	brne eei1

	call ReadEepromP1
	adiw z, 1
	cpi t, 0x19
	brne eei1

	ret		;Yes, return

eei1:			;no, initalize

	rvsetflagfalse flagProfileP1		;Reset P2
	call P1P2Reset
	rvsetflagtrue  flagProfileP1	    ;Reset P1
	call P1P2Reset

	ldi Counter, 5
eei6:	call Beep
	ldi yl, 0
	call wms
	dec Counter
	brne eei6

	call SensorTest

	call LoadMixer

	ret

P1P2Reset:

	ldz 0			
	ldi t, 0x19
	call WriteEeprom
	adiw z, 1
	ldi t, 0x03
	call WriteEeprom
	adiw z, 1
	ldi t, 0x73
	call WriteEeprom
	adiw z, 1
	ldi t, 0x19
	call WriteEeprom
	adiw z, 1

	ldx EeMixerTable	;Mixertable
	ldy eei2 * 2
	ldi Counter, 64
eei3:	movw z, y
	lpm t, z
	movw z, x
	call WriteEeprom
	adiw x, 1
	adiw y, 1
	dec Counter
	brne eei3


	ldx EeParameterTable	;ParameterTable
	ldy eei4 * 2
	ldi Counter, 24
eei5:	movw z, y
	lpm t, z
	movw z, x
	call WriteEeprom
	adiw x, 1
	adiw y, 1
	dec Counter
	brne eei5

	ldx EeStickScaleRoll	;Stick Scaling
	ldy eei7 * 2
	ldi Counter, 8
eei8:	movw z, y
	lpm t, z
	movw z, x
	call WriteEeprom
	adiw x, 1
	adiw y, 1
	dec Counter
	brne eei8


	ldx 10
	ldz eeEscLowLimit
	call StoreEeVariable16

	ldx 0x20
	ldz eeLcdContrast
	call StoreEeVariable16


	ldx 75
	ldz eeSelflevelPgain
	call StoreEeVariable16

	ldx 20
	ldz eeSelflevelPlimit
	call StoreEeVariable16


	ldx 0
	ldz eeHeightDampeningGain
	call StoreEeVariable16

	ldx 30
	ldz eeHeightDampeningLimit
	call StoreEeVariable16

	ldx 0
	ldz eeBattAlarmVoltage
	call StoreEeVariable16

	ldx 50
	ldz eeServoFilter
	call StoreEeVariable16

	ldx 8
	ldz eeAccSWFilter
	call StoreEeVariable16


	ldx 0
	ldz eeAccTrimRoll
	call StoreEeVariable16

	ldx 0
	ldz eeAccTrimPitch
	call StoreEeVariable16

	ldx 1 
	ldz eeCppmRoll
	call StoreEeVariable8
	ldx 2
	ldz eeCppmPitch
	call StoreEeVariable8
	ldx 3
	ldz eeCppmThrottle
	call StoreEeVariable8
	ldx 4
	ldz eeCppmYaw
	call StoreEeVariable8
	ldx 5
	ldz eeCppmAux
	call StoreEeVariable8

	ldx 0
	ldz eeCamRollGain
	call StoreEeVariable16
	ldx 50
	ldz eeCamRollOffset
	call StoreEeVariable16
	ldx 0
	ldz eeCamPitchGain
	call StoreEeVariable16
	ldx 50
	ldz eeCamPitchOffset
	call StoreEeVariable16

	setflagfalse xl
	ldz eeSelfLevelType
	call StoreEeVariable8

	setflagtrue xl
	ldz eeLinkRollPitch
	call StoreEeVariable8

	setflagtrue xl
	ldz eeAutoDisarm
	call StoreEeVariable8

	clr xl
	ldz eeRxType
	call StoreEeVariable8

	ldx 0x08
	ldz eegfs_sel
	call StoreEeVariable8

	ldx 0x08
	ldz eeafs_sel
	call StoreEeVariable8

	ldx 0
	ldz eedlpf
	call StoreEeVariable8

	ldx 2
	ldz eeBoardOffset
	call StoreEeVariable8

	setflagfalse xl
	ldz eeSpinOnArm
	call StoreEeVariable8

	setflagfalse xl
	ldz eeServoOnArm
	call StoreEeVariable8

	setflagfalse xl
	ldz eeSensorsCalibrated
	call StoreEeVariable8	

	setflagtrue xl
	ldz eeProfileP1
	call StoreEeVariable8

    setflagfalse xl
    ldz eeSwitchSSPI
    call StoreEeVariable8

	setflagfalse xl
	ldz eeSSGimbal
	call StoreEeVariable8

	setflagfalse xl
	ldz eeTXGimbal
	call StoreEeVariable8

	setflagtrue xl
	ldz eeflagLMA
	call StoreEeVariable8	
	
	setflagfalse xl
	ldz eeAltSafeScreen
	call StoreEeVariable8

	setflagfalse xl
	ldz eeChannelMap
	call StoreEeVariable8

	ldi xl,0xFF
	ldz eeSelectedMotorLayout
	call StoreEeVariable8

	ldx 0
	ldz eeBattAdcTrim
	call StoreEeVariable16

	ldx 0
	ldz eeOut1Low
	call StoreEeVariable16
	ldz eeOut2Low
	call StoreEeVariable16
	ldz eeOut3Low
	call StoreEeVariable16
	ldz eeOut4Low
	call StoreEeVariable16
	ldz eeOut5Low
	call StoreEeVariable16
	ldz eeOut6Low
	call StoreEeVariable16
	ldz eeOut7Low
	call StoreEeVariable16
	ldz eeOut8Low
	call StoreEeVariable16

	ldx 100
	ldz eeOut1High
	call StoreEeVariable16
	ldz eeOut2High
	call StoreEeVariable16
	ldz eeOut3High
	call StoreEeVariable16
	ldz eeOut4High
	call StoreEeVariable16
	ldz eeOut5High
	call StoreEeVariable16
	ldz eeOut6High
	call StoreEeVariable16
	ldz eeOut7High
	call StoreEeVariable16
	ldz eeOut8High
	call StoreEeVariable16

	ret



eei2:	
	.db  0, 0 , 0, 0, 0 , 0 , 0 , 0
	.db  0, 0 , 0, 0, 0 , 0 , 0 , 0
	.db  0, 0 , 0, 0, 0 , 0 , 0 , 0
	.db  0, 0 , 0, 0, 0 , 0 , 0 , 0
	.db  0, 0 , 0, 0, 0 , 0 , 0 , 0
	.db  0, 0 , 0, 0, 0 , 0 , 0 , 0
	.db  0, 0 , 0, 0, 0 , 0 , 0 , 0
	.db  0, 0 , 0, 0, 0 , 0 , 0 , 0
	


eei4:	.dw 65,100,30,20
	.dw 65,100,30,20
	.dw 65,20,50,10


eei7:	.dw 30, 30, 45, 90


.undef Counter
