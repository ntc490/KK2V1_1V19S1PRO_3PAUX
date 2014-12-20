


;All code by Rolf R Bakke 2011, 2012, 2013

;best viewed with a TAB-setting of 8 and monospace font.



.include "m644Pdef.inc"
.include "macros.inc"
.include "miscmacros.inc"
.include "variables.asm"
.include "hardware.asm"
.include "168mathlib_macros.inc"
.include "168fracmathlib_macros.inc"
.include "824mathlib_macros.inc"
.include "832mathlib_macros.inc"
.include "constants.asm"

.org 0x0000

	jmp reset
	jmp IntPitch
	jmp IntRoll
	jmp IntYaw
	jmp unused
	jmp IntAux
	jmp unused
	jmp IntThrottle
	jmp unused
	jmp unused
	jmp unused
	jmp unused
	jmp unused
	jmp IsrPwmStart
	jmp IsrPwmEnd
	jmp unused
	jmp unused
	jmp unused
	jmp unused
	jmp unused
	jmp IsrUsart
	jmp unused
	jmp unused
	jmp unused
	jmp unused
	jmp unused
	jmp unused
	jmp unused
	jmp unused
	jmp unused
	jmp unused

unused:	reti


;--- Hardware Init ---

reset:	ldi t,low(ramend)	;initalize stack pointer
	out spl,t
	ldi t,high(ramend)
	out sph,t

	call SetupHardware		;needs to be at the beginning so that delay is correct for satellite binding

	;---

;--- Variables init ---

	call EeInit	;needs to be done before call to setup_mpu6050

	call LcdUpdate

	lrv MainMenuCursorYposSave, 0
	lrv MainMenuListYposSave, 0
	
	lrv LoadMenuCursorYposSave, 0
	lrv LoadMenuListYposSave, 0
	
	rvsetflagfalse flagStickCommandSelfLevelOn
	rvsetflagfalse flagLMABuzzerOn

	rvsetflagfalse flagPwmGenM7M8
	rvsetflagfalse flagSelfLevelAlwaysOn
	rvsetflagfalse flagAuxMidPlus
	rvsetflagfalse flagAuxMidPlusOldState

	lrv Status, 0
	lrv StatusOldState, 0 

	b16clr PwmErrorCounter		;reset pwm error counter

	clr t
	sts RollL, t
	sts RollH, t
	sts PitchL, t
	sts PitchH, t
	sts ThrottleL, t
	sts ThrottleH, t
	sts YawL, t
	sts YawH, t
	sts AuxL, t
	sts AuxH, t

	sts CppmChannel1L, t
	sts CppmChannel1H, t
	sts CppmChannel2L, t
	sts CppmChannel2H, t
	sts CppmChannel3L, t
	sts CppmChannel3H, t
	sts CppmChannel4L, t
	sts CppmChannel4H, t
	sts CppmChannel5L, t
	sts CppmChannel5H, t
	sts CppmChannel6L, t
	sts CppmChannel6H, t
	sts CppmChannel7L, t
	sts CppmChannel7H, t
	sts CppmChannel8L, t
	sts CppmChannel8H, t
	sts CppmChannel9L, t
	sts CppmChannel9H, t

	call clrmaxmin
	b16ldi CheckRxDelay, 400 * 10

	ldz CppmChannel1L
	sts CppmPulseArrayAddressL, zl
	sts CppmPulseArrayAddressH, zh

	ldz SerialByte0                                                                                                                 
	sts SerialByteArrayAddressL, zl
	sts SerialByteArrayAddressH, zh
	rvsetflagfalse flagSerialBufferFull	

	call setup_mpu6050
	call ShowVersion				;need a delay between MPU setup and gyrocal so moved Show Version to here
	call gyrocal

	call FlightInit
		
	rvbrflagfalse flagSerialRx, skipusartsetup

	call UsartInit					;shouldn't have interrupts enabled before calling UsartInit

skipusartsetup:


;--- MAIN ----
	
	sei


;--- Throttle cal ----

	call GetButtons
	cpi t, 0x09			;both buttons 1 and 4 pressed?
	brne ma5
	call EscThrottleCalibration	;Yes
ma5:


;--- Flight loop init

ma2:	call FlightInit

	;       76543210		;clear pending OCR1A and B interrupt
	ldi t,0b00000110
	store tifr1, t

;--- Flight Loop

;call DebugMeny

ma1:	

	;sbi OutputPin8		;OBS DEBUG

	call PwmStart			;runtime between PwmStart and B interrupt (in PwmEnd) must not exeed 1.5ms
	call GetRxChannels
	call CheckRx
	call Arming
	call Logic
	call Imu
	call HeightDampening
	call Mixer
	call CameraStab
	call Beeper
	call Lva
	call PwmEnd

	
	rvcp Status, StatusOldState			;Set LcdUpdate if Status changes and not armed
	breq ma8
	rvmov StatusOldState, Status
	rvflagnot flagA, flagArmed 
	rvflagor  flagLcdUpdate, flagLcdUpdate, flagA 
ma8:
	rvflageor flagA, flagAuxOn, flagAuxOnOldState	;set LcdUpdate true if AuxOn changes state and it is not armed
	rvflagnot flagB, flagArmed
	rvflagand flagA, flagA, flagB 
	rvflagor  flagLcdUpdate, flagLcdUpdate, flagA 
	rvflagand flagAuxOnOldState, flagAuxOn, flagAuxOn

	rvflageor flagA, flagAuxMidPlus, flagAuxMidPlusOldState
	rvflagor  flagLcdUpdate, flagLcdUpdate, flagA
	rvmov     flagAuxMidPlusOldState, flagAuxMidPlus

	rvbrflagfalse flagLcdUpdate, ma3		;Update LCD once if flagLcdUpdate is true 
	rvsetflagfalse flagLcdUpdate
	call UpdateFlightDisplay

ma3:	rvbrflagfalse flagArmed, ma7	;skip buttonreading if armed
	rjmp ma1

ma7:	load t, pinb			;read buttons
	com t
	swap t
	andi t, 0x0f
	cpi t, 0x01			;MENY button pressed?
	breq ma6
	
	rjmp ma1	

ma6:

;--- Meny 

;	        76543210		;disable OCR1A and B interrupt
	ldi t,0b00000000
	store timsk1, t
	rvsetflagfalse flagLMABuzzerOn
	call Beep

	call MainMenu

	rjmp ma2

.include "camstab.asm"
.include "trigonometry.asm"
.include "cppmsettings.asm"
.include "checkrx.asm"
.include "setuphw.asm"
.include "version.asm"
.include "reset.asm"
.include "beeper.asm"
.include "menu.asm"
.include "lva.asm"
.include "logic.asm"
.include "heightdamp.asm"
.include "loader.asm"
.include "selflevel.asm"
.include "layout.asm"
.include "MPU6050.asm"
.include "throttlecal.asm"
.include "eeinit.asm"
.include "sensorcal.asm"
.include "settingsc.asm"
.include "settingsb.asm"
.include "settingsa.asm"
.include "settingsmpu.asm"
.include "flightdisplay.asm"
.include "arm.asm"
.include "flightinit.asm"
.include "debug.asm"
.include "pieditor.asm"
.include "numedit.asm"
.include "mixedit.asm"
.include "mixer2.asm"
.include "imu.asm"
.include "pwmgen.asm"
.include "rxtest.asm"
.include "rxsliders.asm"
.include "readrx.asm"
.include "motorsliders.asm"
.include "mainmenu.asm"
.include "sensortest.asm"
.include "sensorreading.asm"
.include "i2c.asm"
.include "ST7565.asm"
.include "miscsubs.asm"
.include "168mathlib_subs.asm"
.include "168fracmathlib_subs.asm"
.include "824mathlib_subs.asm"
.include "832mathlib_subs.asm"
.include "maxmin.asm"
.include "gyrobubble.asm"
.include "accbubble.asm"
.include "misc_asm.asm"
.include "uart.asm"
.include "asettings1.asm"
.include "asettings2.asm"
.include "endpointlimits.asm"
.include "profiles.asm"
.include "donate.asm"
font6x8:
.include "font6x8.asm"
font8x12:
;.include "font8x12.asm"
font12x16:
.include "font12x16.asm"
symbols16x16:
.include "symbols16x16.asm"
font4x6:
.include "font4x6.asm"
font4x6a:
.include "font4x6a.asm"

	.db "__date__"


