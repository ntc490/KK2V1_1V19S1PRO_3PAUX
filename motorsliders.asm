.def	Counter = r17

MotorSliders:
	call flightinit

MotorSliders1:
	call GetRxChannels
	call Imu
	call HeightDampening
	call Mixer
;	call CameraStab
	call PwmEnds

	call LcdClear

	ldi Counter, 48
	ldz mspixels * 2
ms2:
	lpm	t,Z+
	sts	Xpos, t
	lpm	t,Z+
	sts Ypos, t
	call SetPixel
	dec Counter
	brne ms2

	lrv PixelType, 1
	lrv FontSelector, f4x6

	ldi Counter, 0
	ldz	outputs *  2
ms3:
	ldi	t,4
	sts	X1, t
	lpm t,Z+
	sts Y1, t
	mov t, Counter
	call PrintChar
	inc	Counter
	cpi Counter,8
	brne ms3

.undef	Counter

	lrv PixelType, 1
	lrv FontSelector, f4x6a

	ldi t,109
	sts	X1, t
	ldi t,0
	sts	Y1, t
	b16load Out1
    lds	yh, Out1Low
	lds yl, Out1Low+1
	lds zh, Out1High
	lds zl, Out1High+1
	call pwmconds
	b16store Out1
	b16ldi Temp, 1.8018
	b16mul Out1, Out1, Temp
	b16ldi Temp, 1000
	b16add Out1, Out1, Temp
	b16load Out1
	call Print16Signed
	b16sub Out1, Out1, Temp
	b16ldi Temp, 0.1
	b16mul Out1, Out1, Temp
	b16load Out1
	ldi	t,10
	sts X1,t
	ldi t,2
	sts Y1,t
	sts Y2,t
	adiw xl,10
	mov	t,xl
	sts X2,t
	call Bresenham

	ldi t,109
	sts	X1, t
	ldi t,7
	sts	Y1, t
	b16load Out2
    lds	yh, Out2Low
	lds yl, Out2Low+1
	lds zh, Out2High
	lds zl, Out2High+1
	call pwmconds
	b16store Out2
	b16ldi Temp, 1.8018
	b16mul Out2, Out2, Temp
	b16ldi Temp, 1000
	b16add Out2, Out2, Temp
	b16load Out2
	call Print16Signed
	b16sub Out2, Out2, Temp
	b16ldi Temp, 0.1
	b16mul Out2, Out2, Temp
	b16load Out2
	ldi	t,10
	sts X1,t
	ldi t,9
	sts Y1,t
	sts Y2,t
	adiw xl,10
	mov	t,xl
	sts X2,t
	call Bresenham

	ldi t,109
	sts	X1, t
	ldi t,14
	sts	Y1, t
	b16load Out3
    lds	yh, Out3Low
	lds yl, Out3Low+1
	lds zh, Out3High
	lds zl, Out3High+1
	call pwmconds
	b16store Out3
	b16ldi Temp, 1.8018
	b16mul Out3, Out3, Temp
	b16ldi Temp, 1000
	b16add Out3, Out3, Temp
	b16load Out3
	call Print16Signed
	b16sub Out3, Out3, Temp
	b16ldi Temp, 0.1
	b16mul Out3, Out3, Temp
	b16load Out3
	ldi	t,10
	sts X1,t
	ldi t,16
	sts Y1,t
	sts Y2,t
	adiw xl,10
	mov	t,xl
	sts X2,t
	call Bresenham

	ldi t,109
	sts	X1, t
	ldi t,21
	sts	Y1, t
	b16load Out4
    lds	yh, Out4Low
	lds yl, Out4Low+1
	lds zh, Out4High
	lds zl, Out4High+1
	call pwmconds
	b16store Out4
	b16ldi Temp, 1.8018
	b16mul Out4, Out4, Temp
	b16ldi Temp, 1000
	b16add Out4, Out4, Temp
	b16load Out4
	call Print16Signed
	b16sub Out4, Out4, Temp
	b16ldi Temp, 0.1
	b16mul Out4, Out4, Temp
	b16load Out4
	ldi	t,10
	sts X1,t
	ldi t,23
	sts Y1,t
	sts Y2,t
	adiw xl,10
	mov	t,xl
	sts X2,t
	call Bresenham

	ldi t,109
	sts	X1, t
	ldi t,28
	sts	Y1, t
	b16load Out5
    lds	yh, Out5Low
	lds yl, Out5Low+1
	lds zh, Out5High
	lds zl, Out5High+1
	call pwmconds
	b16store Out5
	b16ldi Temp, 1.8018
	b16mul Out5, Out5, Temp
	b16ldi Temp, 1000
	b16add Out5, Out5, Temp
	b16load Out5
	call Print16Signed
	b16sub Out5, Out5, Temp
	b16ldi Temp, 0.1
	b16mul Out5, Out5, Temp
	b16load Out5
	ldi	t,10
	sts X1,t
	ldi t,30
	sts Y1,t
	sts Y2,t
	adiw xl,10
	mov	t,xl
	sts X2,t
	call Bresenham

	ldi t,109
	sts	X1, t
	ldi t,35
	sts	Y1, t
	b16load Out6
    lds	yh, Out6Low
	lds yl, Out6Low+1
	lds zh, Out6High
	lds zl, Out6High+1
	call pwmconds
	b16store Out6
	b16ldi Temp, 1.8018
	b16mul Out6, Out6, Temp
	b16ldi Temp, 1000
	b16add Out6, Out6, Temp
	b16load Out6
	call Print16Signed
	b16sub Out6, Out6, Temp
	b16ldi Temp, 0.1
	b16mul Out6, Out6, Temp
	b16load Out6
	ldi	t,10
	sts X1,t
	ldi t,37
	sts Y1,t
	sts Y2,t
	adiw xl,10
	mov	t,xl
	sts X2,t
	call Bresenham

	ldi t,109
	sts	X1, t
	ldi t,42
	sts	Y1, t
	b16ldi Temp, 0.222				;scale 2500 > 555
	b16mul Out7Lowms, Out7Low, Temp
	b16mul Out7Highms, Out7High, Temp
	b16load Out7
    lds	yh, Out7Lowms
	lds yl, Out7Lowms+1
	lds zh, Out7Highms
	lds zl, Out7Highms+1
	call pwmconds
	b16store Out7
	b16ldi Temp, 1.8018
	b16mul Out7, Out7, Temp
	b16ldi Temp, 1000
	b16add Out7, Out7, Temp
	b16load Out7
	call Print16Signed
	b16sub Out7, Out7, Temp
	b16ldi Temp, 0.1
	b16mul Out7, Out7, Temp
	b16load Out7
	ldi	t,10
	sts X1,t
	ldi t,44
	sts Y1,t
	sts Y2,t
	adiw xl,10
	mov	t,xl
	sts X2,t
	call Bresenham

	ldi t,109
	sts	X1, t
	ldi t,49
	sts	Y1, t
	b16ldi Temp, 0.222				;scale 2500 > 555
	b16mul Out8Lowms, Out8Low, Temp
	b16mul Out8Highms, Out8High, Temp
	b16load Out8
    lds	yh, Out8Lowms
	lds yl, Out8Lowms+1
	lds zh, Out8Highms
	lds zl, Out8Highms+1
	call pwmconds
	b16store Out8
	b16ldi Temp, 1.8018
	b16mul Out8, Out8, Temp
	b16ldi Temp, 1000
	b16add Out8, Out8, Temp
	b16load Out8
	call Print16Signed
	b16sub Out8, Out8, Temp
	b16ldi Temp, 0.1
	b16mul Out8, Out8, Temp
	b16load Out8
	ldi	t,10
	sts X1,t
	ldi t,51
	sts Y1,t
	sts Y2,t
	adiw xl,10
	mov	t,xl
	sts X2,t
	call Bresenham

	lrv PixelType, 1
	lrv FontSelector, f6x8

	;footer
	lrv X1, 0
	lrv Y1, 57
	mPrintString ms6

	call LcdUpdate

	call GetButtons

	cpi t, 0x08		;BACK?
	brne ms7
	ret

ms7: 
	jmp	MotorSliders1

	ret

PwmEnds:	
	b16ldi Temp, 888		;make sure the EscLowLimit is not too high. (hardcoded limit of 20%)
	b16cmp EscLowLimit, Temp
	brlt pwm58s
	b16mov EscLowLimit, Temp
pwm58s:

	;loop setup

	lrv Index, 0		
	 
	lds t, OutputTypeBitmask
	sts OutputTypeBitmaskCopy, t
	
	;loop body

pwm50s:	b16load_array PwmOutput, Out1


	lds t, OutputTypeBitmaskCopy		;ESC or SERVO?
	lsr t
	sts OutputTypeBitmaskCopy, t
	brcc pwm51fixs
	rjmp pwm51s
pwm51fixs:

	;---

	rvbrflagfalse flagThrottleZero, pwm52fixs	;SERVO, active or inactive?
	rjmp pwm52s
pwm52fixs:
	b16load_array Temp, FilteredOut1 	;servo active, apply low pass filter
	b16sub Error, PwmOutput, Temp
	
	b16mul Error, Error, ServoFilter

	b16add PwmOutput, Temp, Error
	b16store_array FilteredOut1, PwmOutput
	
	rjmp pwm55s

pwm52s:	b16load_array PwmOutput, Offset1	;servo inactive, set to offset value
	rjmp pwm55s

	;---

pwm51s:	
	rvbrflagfalse flagSpinOnArm, pwm51as	;If not spin on arm, run normal code
;	rvbrflagfalse flagArmed, pwm54s			;If not armed, clear output
	rvbrflagfalse flagThrottleZero, pwm51bs	;If not throttle zero, must be armed so run normal code
	b16mov PwmOutput, EscLowLimit			;Must be armed, with throttle zero and spin on arm
	rjmp pwm55s

pwm51as:
	rvbrflagtrue flagThrottleZero, pwm54s	;ESC, active or inactive?
pwm51bs:
	b16cmp PwmOutput, EscLowLimit		;ESC active, limit to EscLowLimit
	brge pwm56s
	b16mov PwmOutput, EscLowLimit
pwm56s:
	rjmp pwm55s

pwm54s:	b16clr PwmOutput			;ESC inactive, set to zero 


	;---

pwm55s:	b16store_array Out1, PwmOutput


	;loop looper

	rvinc Index
	rvcpi Index, 8
	breq pwm57s
	rjmp pwm50s
pwm57s:
	ret

pwmconds:
	
	asr xh		;divide by 8
	ror xl
	asr xh
	ror xl
	asr xh
	ror xl

	cp  xl, yl
	cpc xh, yh
	brge pwm22s	;x < min limit ?
    mov	xh, yh
	mov xl, yl
	ret

pwm22s:
	cp  xl, zl
	cpc xh, zh
	brlt pwm23s	;x >= max limit ?
    mov	xh, zh
	mov xl, zl

pwm23s:	ret

ms6:	.db "BACK", 0, 0

outputs:

	.db 0,7,14,21,28,35,42,49

mspixels:

	.db 10,1,10,3,10,8,10,10,10,15,10,17,10,22,10,24,10,29,10,31,10,36,10,38,10,43,10,45,10,50,10,52
	.db 58,1,58,3,58,8,58,10,58,15,58,17,58,22,58,24,58,29,58,31,58,36,58,38,58,43,58,45,58,50,58,52
	.db 107,1,107,3,107,8,107,10,107,15,107,17,107,22,107,24,107,29,107,31,107,36,107,38,107,43,107,45,107,50,107,52
