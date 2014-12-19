
RxSliders:



rxs1:	
	
	lrv RxTimeoutLimit, 2  ; do this to get valid flags
	call GetRxChannels	

	cli				;get throttle channel value / channel 3 value
	lds xl, ThrottleL
	lds xh, ThrottleH

	rvbrflagfalse	flagCppmOn, tend

	lds xl, CppmChannel3L
	lds xh, CppmChannel3H

tend:sei

	

	call Xabs			;sanitize
	clr yh				;store in register
	b16store RxThrottle

	cli				;get roll channel value / channel 1 value
	lds xl, RollL
	lds xh, RollH

	rvbrflagfalse	flagCppmOn, rend

	lds xl, CppmChannel1L
	lds xh, CppmChannel1H

rend:sei

	call Xabs			;sanitize
	clr yh				;store in register
	b16store RxRoll

	cli				;get Pitch channel value / channel 2 value
	lds xl, PitchL
	lds xh, PitchH
	
	rvbrflagfalse	flagCppmOn, pend

	lds xl, CppmChannel2L
	lds xh, CppmChannel2H

pend:sei

	call Xabs			;sanitize
	clr yh				;store in register
	b16store RxPitch

	cli				;get yaw channel value / channel 4 value
	lds xl, YawL
	lds xh, YawH

	rvbrflagfalse	flagCppmOn, yend

	lds xl, CppmChannel4L
	lds xh, CppmChannel4H

yend:sei

	call Xabs			;sanitize
	clr yh				;store in register
	b16store RxYaw

	cli				;get Aux channel value / channel 5 value
	lds xl, AuxL
	lds xh, AuxH

	rvbrflagfalse	flagCppmOn, aend

	lds xl, CppmChannel5L
	lds xh, CppmChannel5H

aend:sei

	call Xabs			;sanitize
	clr yh				;store in register
	b16store RxAux

	rvbrflagtrue flagCppmOn, rxs0	; Skip next bit if not CPPM or Satellite
	rjmp rxs1a

rxs0:
	cli				;get Aux2 channel value / channel 6 value

	lds xl, CppmChannel6L
	lds xh, CppmChannel6H

	sei

	call Xabs			;sanitize
	clr yh				;store in register
	b16store RxAux2

	cli				;get Aux3 channel value / channel 7 value

	lds xl, CppmChannel7L
	lds xh, CppmChannel7H

	sei

	call Xabs			;sanitize
	clr yh				;store in register
	b16store RxAux3

	cli				;get Aux4 channel value / channel 8 value

	lds xl, CppmChannel8L
	lds xh, CppmChannel8H

	sei

	call Xabs			;sanitize
	clr yh				;store in register
	b16store RxAux4

rxs1a:
	b16ldi	Temp,0.4
	b16mul	RxThrottle, RxThrottle, Temp
	b16mul  RxRoll, RxRoll, Temp
	b16mul  RxPitch, RxPitch, Temp
	b16mul  RxYaw, RxYaw, Temp
	b16mul  RxAux, RxAux, Temp
	b16mul  RxAux2, RxAux2, Temp
	b16mul  RxAux3, RxAux3, Temp
	b16mul  RxAux4, RxAux4, Temp

	call LcdClear

.def	Counter = r17

	ldi Counter, 30
	ldz pixels * 2
rxs2:
	lpm	t,Z+
	sts	Xpos, t
	lpm	t,Z+
	sts Ypos, t
	call SetPixel
	dec Counter
	brne rxs2

	rvbrflagfalse flagCppmOn, rxs2b	; add extra pixels if CPPM, Satellite or SBUS

	ldi Counter, 12
rxs2a:
	lpm	t,Z+
	sts	Xpos, t
	lpm	t,Z+
	sts Ypos, t
	call SetPixel
	dec Counter
	brne rxs2a

	rvbrflagtrue flagSatRx, rxs2b	; add CH8 pixels if not Satellite rx

	ldi Counter, 6
rxs2c:
	lpm	t,Z+
	sts	Xpos, t
	lpm	t,Z+
	sts Ypos, t
	call SetPixel
	dec Counter
	brne rxs2c

rxs2b:

	lrv PixelType, 1
	lrv FontSelector, f4x6

	ldi Counter, 0
	ldz	inputs *  2
rxs3:
	ldi	t,4
	sts	X1, t
   	lpm t,Z+
	sts Y1, t
	mov t, Counter
	call PrintChar
	inc	Counter
	cpi Counter,5
	brne rxs3

	rvbrflagfalse flagCppmOn, rxs3b	; add extra channel numbers if CPPM, Satellite or SBUS

rxs3a:
	ldi	t,4
	sts	X1, t
	lpm t,Z+
	sts Y1, t
	mov t, Counter
	call PrintChar
	inc	Counter
	cpi Counter,7
	brne rxs3a

	rvbrflagtrue flagSatRx, rxs3b

	ldi	t,4
	sts	X1, t
	lpm t,Z
	sts Y1, t
	mov t, Counter
	call PrintChar

rxs3b:

.undef	Counter

	lrv PixelType, 1
	lrv FontSelector, f4x6a

	ldi t,109
	sts	X1, t
	ldi t,0
	sts	Y1, t
	rvbrflagtrue flagRollValid, rxsroll2
	jmp rxsroll1
rxsroll2:
	b16load RxRoll
	call	Print16Signed
	b16ldi Temp, 1000
	b16sub RxRoll, RxRoll, Temp
	b16ldi Temp, 0.1
	b16mul RxRoll, RxRoll, Temp
	b16load RxRoll
	call limits
	ldi	t,10
	sts X1,t
	ldi t,2
	sts Y1,t
	sts Y2,t
	adiw xl,10
	mov	t,xl
	sts X2,t
	call Bresenham

	rjmp rxsroll3
rxsroll1:
	mPrintString rxs8	
rxsroll3:

	ldi t,109
	sts	X1, t
	ldi t,7
	sts	Y1, t
	rvbrflagtrue flagPitchValid, rxspitch2
	jmp rxspitch1
rxspitch2:
	b16load RxPitch
	call	Print16Signed
	b16ldi Temp, 1000
	b16sub RxPitch, RxPitch, Temp
	b16ldi Temp, 0.1
	b16mul RxPitch, RxPitch, Temp
	b16load RxPitch
	call limits
	ldi	t,10
	sts X1,t
	ldi t,9
	sts Y1,t
	sts Y2,t
	adiw xl,10
	mov	t,xl
	sts X2,t
	call Bresenham

	rjmp rxspitch3
rxspitch1:
	mPrintString rxs8	
rxspitch3:

	ldi t,109
	sts	X1, t
	ldi t,14
	sts	Y1, t
	rvbrflagtrue flagThrottleValid, rxsthrottle2
	jmp rxsthrottle1
rxsthrottle2:
	b16load RxThrottle
	call	Print16Signed
	b16ldi Temp, 1000
	b16sub RxThrottle, RxThrottle, Temp
	b16ldi Temp, 0.1
	b16mul RxThrottle, RxThrottle, Temp
	b16load RxThrottle
	call limits
	ldi	t,10
	sts X1,t
	ldi t,16
	sts Y1,t
	sts Y2,t
	adiw xl,10
	mov	t,xl
	sts X2,t
	call Bresenham

	rjmp rxsthrottle3
rxsthrottle1:
	mPrintString rxs8	
rxsthrottle3:

	ldi t,109
	sts	X1, t
  	ldi t,21
	sts	Y1, t
	rvbrflagtrue flagYawValid, rxsyaw2
	jmp rxsyaw1
rxsyaw2:
	b16load RxYaw
	call	Print16Signed
	b16ldi Temp, 1000
	b16sub RxYaw, RxYaw, Temp
	b16ldi Temp, 0.1
	b16mul RxYaw, RxYaw, Temp
	b16load RxYaw
	call limits
	ldi	t,10
	sts X1,t
	ldi t,23
	sts Y1,t
	sts Y2,t
	adiw xl,10
	mov	t,xl
	sts X2,t
	call Bresenham

	rjmp rxsyaw3
rxsyaw1:
	mPrintString rxs8
rxsyaw3:

	ldi t,109
	sts	X1, t
	ldi t,28
	sts	Y1, t
	rvbrflagtrue flagAuxValid, rxsaux2
	jmp rxsaux1
rxsaux2:
	b16load RxAux
	call	Print16Signed
	b16ldi Temp, 1000
	b16sub RxAux, RxAux, Temp
	b16ldi Temp, 0.1
	b16mul RxAux, RxAux, Temp
	b16load RxAux
	call limits
	ldi	t,10
	sts X1,t
	ldi t,30
	sts Y1,t
	sts Y2,t
	adiw xl,10
	mov	t,xl
	sts X2,t
	call Bresenham
	rjmp rsxaux1a
rxsaux1:
	mPrintString rxs8

rsxaux1a:
	rvbrflagtrue flagCppmOn, rxs60
	jmp rxs5

rxs60:				;Routine to display channels 6, 7 and 8 if CPPM, Satellite or SBUS enabled

	ldi t,109
	sts	X1, t
	ldi t,35
	sts	Y1, t
	rvbrflagtrue flagAuxValid, rxs61
	mPrintString rxs8
	jmp rxs62
rxs61:
	b16load RxAux2
	call	Print16Signed
	b16ldi Temp, 1000
	b16sub RxAux2, RxAux2, Temp
	b16ldi Temp, 0.1
	b16mul RxAux2, RxAux2, Temp
	b16load RxAux2
	call limits
	ldi	t,10
	sts X1,t
	ldi t,37
	sts Y1,t
	sts Y2,t
	adiw xl,10
	mov	t,xl
	sts X2,t
	call Bresenham

rxs62:
	ldi t,109
	sts	X1, t
	ldi t,42
	sts	Y1, t
	rvbrflagtrue flagAuxValid, rxs63
	mPrintString rxs8
	jmp rxs63a
rxs63:
	b16load RxAux3
	call	Print16Signed
	b16ldi Temp, 1000
	b16sub RxAux3, RxAux3, Temp
	b16ldi Temp, 0.1
	b16mul RxAux3, RxAux3, Temp
	b16load RxAux3
	call limits
	ldi	t,10
	sts X1,t
	ldi t,44
	sts Y1,t
	sts Y2,t
	adiw xl,10
	mov	t,xl
	sts X2,t
	call Bresenham

rxs63a:
	rvbrflagfalse flagSatRx, rxs64
	rjmp rxs5

rxs64:
	ldi t,109
	sts	X1, t
	ldi t,49
	sts	Y1, t
	rvbrflagtrue flagAuxValid, rxs65
	mPrintString rxs8
	jmp rxs5
rxs65:
	b16load RxAux4
	call	Print16Signed
	b16ldi Temp, 1000
	b16sub RxAux4, RxAux4, Temp
	b16ldi Temp, 0.1
	b16mul RxAux4, RxAux4, Temp
	b16load RxAux4
	call limits
	ldi	t,10
	sts X1,t
	ldi t,51
	sts Y1,t
	sts Y2,t
	adiw xl,10
	mov	t,xl
	sts X2,t
	call Bresenham


rxs5:		
	lrv PixelType, 1
	lrv FontSelector, f6x8

	;footer
	lrv X1, 0
	lrv Y1, 57
	mPrintString rxs6

	call LcdUpdate

	call GetButtons

	cpi t, 0x08		;BACK?
	brne rxs7
	ret

rxs7: 
	jmp	rxs1

limits:

	ldz 0		;X < 0
	cp  xl, zl
	cpc xh, zh
	brlt gtrxs1

	ldz 100		;X > 100?
	cp  xl, zl
	cpc xh, zh
	brge gtrxs2
	ret

gtrxs1:
	ldx	0
	ret

gtrxs2:
	ldx 100
	ret

rxs6:	.db "BACK", 0, 0
rxs8:	.db "----", 0, 0

pixels:

	;Channels 1 to 5
	.db 10,1,10,3,10,8,10,10,10,15,10,17,10,22,10,24,10,29,10,31
	.db 58,1,58,3,58,8,58,10,58,15,58,17,58,22,58,24,58,29,58,31
	.db 107,1,107,3,107,8,107,10,107,15,107,17,107,22,107,24,107,29,107,31
	;Channels 6 & 7
	.db 10,36,10,38,10,43,10,45,58,36,58,38,58,43,58,45,107,36,107,38,107,43,107,45
	;Channel 8
	.db 10,50,10,52,58,50,58,52,107,50,107,52

inputs:

	.db 0,7,14,21,28,35,42,49