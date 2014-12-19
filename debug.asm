


DebugMeny:

;jmp rxt35b

bbb30:	call LcdClear
	
	lrv PixelType, 1
	lrv FontSelector, f6x8

	lrv X1, 0	
	lrv Y1, 0
	mPrintString ttt1
	b16load GyroRollZero
	call Print16Signed 

	lrv X1, 0	
	rvadd Y1, 8 
	mPrintString ttt2
	b16load GyroPitchZero
	call Print16Signed 

	lrv X1, 0	
	rvadd Y1, 8 
	mPrintString ttt3
	b16load GyroYawZero
	call Print16Signed 

	lrv X1, 0	
	rvadd Y1, 8 
	mPrintString ttt4
	b16load AccXZero
	call Print16Signed 

	lrv X1, 0	
	rvadd Y1, 8 
	mPrintString ttt5
	b16load AccYZero
	call Print16Signed 

	lrv X1, 0	
	rvadd Y1, 8 
	mPrintString ttt6
	b16load AccZZero
	call Print16Signed 

	lrv X1, 0	
	rvadd Y1, 8 
	mPrintString ttt7
	b16load EscLowLimit
	call Print16Signed 

	lrv X1, 0	
	rvadd Y1, 8 
	mPrintString ttt8
	b16load BattAlarmVoltage
	call Print16Signed 

	call LcdUpdate

	call GetButtonsBlocking

	call LcdClear


	lrv X1, 0	
	lrv Y1, 0
	mPrintString ttt9
	b16ldi Temp, 100
	b16mul Temp, Temp, ServoFilter
	b16load Temp
	call Print16Signed 

	lrv X1, 0	
	rvadd Y1, 8 
	mPrintString ttt10
	b824load VectorX
	rcall b824print

	lrv X1, 0	
	rvadd Y1, 8 
	mPrintString ttt11
	b824load VectorY
	rcall b824print

	lrv X1, 0	
	rvadd Y1, 8 
	mPrintString ttt12
	b824load VectorZ
	rcall b824print

	lrv X1, 0	
	rvadd Y1, 8 
	mPrintString ttt13
	b16load AccAngleRoll
	call Print16Signed 

	lrv X1, 0	
	rvadd Y1, 8 
	mPrintString ttt14
	b16load AccAnglePitch
	call Print16Signed 

	lrv X1, 0	
	rvadd Y1, 8 
	mPrintString ttt15
	b16load BatteryVoltage
	call Print16Signed 

	lrv X1, 0	
	rvadd Y1, 8 
	mPrintString ttt16
	b824load LengthVector
	rcall b824print


	call LcdUpdate

	call GetButtonsBlocking
db2:
	call LcdClear

	lrv X1, 0	
	lrv Y1, 0
	mPrintString ttt17	;GyroXRaw
	ldi		t,0x43
	sts		TWI_address,t
	call	i2c_read_adr
	mov		xh, t
	ldi		t,0x44
	sts		TWI_address,t
	call	i2c_read_adr
	mov		xl, t
	clr		yh
	call Print16Signed  ;GyroXRaw

	lrv X1, 0	
	rvadd Y1, 8
	mPrintString ttt18	;GyroYRaw
	ldi		t,0x45
	sts		TWI_address,t
	call	i2c_read_adr
	mov		xh, t
	ldi		t,0x46
	sts		TWI_address,t
	call	i2c_read_adr
	mov		xl, t
	clr		yh
	call Print16Signed  ;GyroYRaw

	lrv X1, 0	
	rvadd Y1, 8
	mPrintString ttt19	;GyroZRaw
	ldi		t,0x47
	sts		TWI_address,t
	call	i2c_read_adr
	mov		xh, t
	ldi		t,0x48
	sts		TWI_address,t
	call	i2c_read_adr
	mov		xl, t
	clr		yh
	call Print16Signed  ;GyroZRaw

	lrv X1, 0	
	rvadd Y1, 8
	mPrintString ttt20	;AccXRaw
	ldi		t,0x3B
	sts		TWI_address,t
	call	i2c_read_adr
	mov		xh, t
	ldi		t,0x3C
	sts		TWI_address,t
	call	i2c_read_adr
	mov		xl, t
	clr		yh
	call Print16Signed  ;AccXRaw

	lrv X1, 0	
	rvadd Y1, 8
	mPrintString ttt21	;AccYRaw
	ldi		t,0x3D
	sts		TWI_address,t
	call	i2c_read_adr
	mov		xh, t
	ldi		t,0x3E
	sts		TWI_address,t
	call	i2c_read_adr
	mov		xl, t
	clr		yh
	call Print16Signed  ;AccYRaw

	lrv X1, 0	
	rvadd Y1, 8
	mPrintString ttt22	;AccZRaw
	ldi		t,0x3F
	sts		TWI_address,t
	call	i2c_read_adr
	mov		xh, t
	ldi		t,0x40
	sts		TWI_address,t
	call	i2c_read_adr
	mov		xl, t
	clr		yh
	call Print16Signed  ;AccZRaw

	lrv X1, 0	
	rvadd Y1, 8
	mPrintString ttt25	;TempRaw
	ldi		t,0x41
	sts		TWI_address,t
	call	i2c_read_adr
	mov		xh, t
	ldi		t,0x42
	sts		TWI_address,t
	call	i2c_read_adr
	mov		xl, t
	clr		yh
	call Print16Signed  ;TempRaw

	call LcdUpdate

	ldi yh, 5
rxt33a:	ldi yl, 0
	call wms
	dec yh
	brne rxt33a

	call GetButtons

	cpi t, 0x00		;Any button pressed?
	brne clearbuffer

	jmp	db2

	;clear the serial byte buffer
clearbuffer:
	ldi t,25
	ldi xl,0
	ldz SerialByte0
clearbuffer1:
	st z+, xl
	dec t
	brne clearbuffer1

rxt1a:	call LcdClear	; print out the contents of the serial buffer
	
	call GetRxChannels

	lrv PixelType, 1
	lrv FontSelector, f6x8

	lrv X1, 0
	lrv Y1, 0
	lds	xl,SerialByte0
	ldi xh,0
	call Print16Signed 

	lrv X1, 30
	lds	xl,SerialByte1
	ldi xh,0
	call Print16Signed 

	lrv X1, 60
	lds	xl,SerialByte2
	ldi xh,0
	call Print16Signed 

	lrv X1, 90
	lds	xl,SerialByte3
	ldi xh,0
	call Print16Signed 

	lrv X1, 0
	lrv Y1, 9
	lds	xl,SerialByte4
	ldi xh,0
	call Print16Signed 

	lrv X1, 30
	lds	xl,SerialByte5
	ldi xh,0
	call Print16Signed 

	lrv X1, 60
	lds	xl,SerialByte6
	ldi xh,0
	call Print16Signed 

	lrv X1, 90
	lds	xl,SerialByte7
	ldi xh,0
	call Print16Signed 

	lrv X1, 0
	lrv Y1, 18
	lds	xl,SerialByte8
	ldi xh,0
	call Print16Signed 

	lrv X1, 30
	lds	xl,SerialByte9
	ldi xh,0
	call Print16Signed 

	lrv X1, 60
	lds	xl,SerialByte10
	ldi xh,0
	call Print16Signed 

	lrv X1, 90
	lds	xl,SerialByte11
	ldi xh,0
	call Print16Signed
	 
	lrv X1, 0
	lrv Y1, 27
	lds	xl,SerialByte12
	ldi xh,0
	call Print16Signed 

	lrv X1, 30
	lds	xl,SerialByte13
	ldi xh,0
	call Print16Signed 

	lrv X1, 60
	lds	xl,SerialByte14
	ldi xh,0
	call Print16Signed 

	lrv X1, 90
	lds	xl,SerialByte15
	ldi xh,0
	call Print16Signed 

	lrv X1, 0
	lrv Y1, 38
	lds	xl,SerialByte16
	ldi xh,0
	call Print16Signed 

	lrv X1, 30
	lds	xl,SerialByte17
	ldi xh,0
	call Print16Signed 

	lrv X1, 60
	lds	xl,SerialByte18
	ldi xh,0
	call Print16Signed 

	lrv X1, 90
	lds	xl,SerialByte19
	ldi xh,0
	call Print16Signed 

	lrv X1, 0
	lrv Y1, 47
	lds	xl,SerialByte20
	ldi xh,0
	call Print16Signed 

	lrv X1, 30
	lds	xl,SerialByte21
	ldi xh,0
	call Print16Signed 

	lrv X1, 60
	lds	xl,SerialByte22
	ldi xh,0
	call Print16Signed 

	lrv X1, 90
	lds	xl,SerialByte23
	ldi xh,0
	call Print16Signed 

	lrv X1, 0
	lrv Y1, 56
	lds	xl,SerialByte24
	ldi xh,0
	call Print16Signed 

	call LcdUpdate

	ldi yh, 5
rxt34a:	ldi yl, 0
	call wms
	dec yh
	brne rxt34a

	call GetButtons
	cpi t, 0x00		;Anything pressed?
	breq rxt35a
	rjmp rxt35c

rxt35a:
	rjmp rxt1a	

rxt35c:
	ldi yh, 5
rxt37a:	ldi yl, 0
	call wms
	dec yh
	brne rxt37a
	
	ret

/*

rxt35b:
	call	LcdClear

	call	imu
		
	lrv PixelType, 1
	lrv FontSelector, f6x8

	lrv X1, 0	
	lrv Y1, 10
	mPrintString ttt30
	b16load EulerAngleRoll
	call Print16Signed 

	lrv X1, 0	
	rvadd Y1, 8 
	mPrintString ttt31
	b16load AccAngleRoll
	call Print16Signed 

	lrv X1, 0	
	rvadd Y1, 8 
	mPrintString ttt32
	b16load EulerAnglePitch
	call Print16Signed 

	lrv X1, 0	
	rvadd Y1, 8 
	mPrintString ttt33
	b16load AccAnglePitch
	call Print16Signed 


	lrv X1, 0	
	rvadd Y1, 8 
	b832load MagicNumber
	call b832print 



	call	LcdUpdate

	call GetButtons
	cpi t, 0x00		;Anything pressed?
	breq rxt36a

	ret	

rxt36a: jmp rxt35b

*/


ttt1:	.db "GyroRollZero: ",0,0
ttt2:	.db "GyroPitchZero: ",0
ttt3:	.db "GyroYawZero: ",0
ttt4:	.db "AccXZero: ",0,0
ttt5:	.db "AccYZero: ",0,0
ttt6:	.db "AccZZero: ",0,0
ttt7:	.db "EscLowLimit: ",0
ttt8:	.db "BattAlarmVoltage:",0

ttt9:	.db "ServoFilter: ",0
ttt10:	.db "VectorX: ",0
ttt11:	.db "VectorY: ",0
ttt12:	.db "VectorZ: ",0
ttt13:	.db "AccAngleRoll: ",0,0
ttt14:	.db "AccAnglePitch: ",0
ttt15:	.db "BatteryVoltage:",0
ttt16:	.db "VectorLen: ",0

ttt17:	.db "GyroXRaw: ",0,0
ttt18:	.db "GyroYRaw: ",0,0
ttt19:	.db "GyroZRaw: ",0,0
ttt20:	.db "AccXRaw : ",0,0
ttt21:	.db "AccYRaw : ",0,0
ttt22:	.db "AccZRaw : ",0,0
ttt25:  .db "TempRaw : ",0,0
ttt23:  .db "Satellite Buffer",0,0

ttt30:  .db "EuAngRoll  : ",0
ttt31:  .db "AccAngRoll : ",0
ttt32:  .db "EuAngPitch : ",0
ttt33:  .db "AccAngPitch: ",0


/*

debugCU:


	b16ldi Temp, -1
	b16mul Temp, Debug5, Temp
	b16ldi Temper, 2220
	b16add Out5, Temper, Temp

	b16ldi Temp, -1
	b16mul Temp, Debug6, Temp
	b16ldi Temper, 2220
	b16add Out6, Temper, Temp


	b16ldi Temp, -1
	b16mul Temp, Debug7, Temp
	b16ldi Temper, 2220
	b16add Out7, Temper, Temp

	b16ldi Temp, -1
	b16mul Temp, Debug8, Temp
	b16ldi Temper, 2220
	b16add Out8, Temper, Temp

	ret






DebugPwm:
	push t
	sbi OutputPin8
deb3:	sbci t,1
	brcc deb3
	cbi OutputPin8
	pop t
	ret


DebugPwm16_200: 	;FS is 200uS
	push xl
	push xh
	ldi t, low(32768)
	add xl, t
	ldi t, high(32768)
	adc xh, t

	ldi t, 6
deb5:	lsr xh
	ror xl
	dec t
	brne deb5

	sbi OutputPin7
deb4:	sbiw x,1
	brcc deb4
	cbi OutputPin7
	pop xh
	pop xl
	ret


;DebugPwm16: 	;
	push xl
	push xh
	ldi t, low(1000)
	add xl, t
	ldi t, high(1000)
	adc xh, t


	sbi OutputPin8
deb6:	sbiw x,1
	brcc deb6
	cbi OutputPin8
	pop xh
	pop xl
	ret





;Dump:
			
	call LcdClear

	lrv PixelType, 1
	lrv FontSelector, f6x8

	lrv X1, 0
	lrv Y1, 0

	mPrintString deb1
	

	lrv X1, 0
	lrv Y1, 10

	call print16signed


	call LcdUpdate


	ret
	rjmp pc



deb1:	.db "DEBUG:",0,0






;TimeStart:
	cli
	load xl, tcnt1l	
	load xh, tcnt1h
	sei

	sts TimeStampL, xl
	sts TimeStampH, xh
	
	ret
	
;TimeEnd:
	cli
	load xl, tcnt1l	
	load xh, tcnt1h
	sei
	
	lds yl, TimeStampL
	lds yh, TimeStampH

	sub xl, yl
	sbc xh, yh

	brpl tim1

	com xl
	com xh
	ldi t, 1
	add xl, t
	clr t
	adc xh, t

tim1:	ldy 2500
	cp  xl, yl
	cpc xh, yh
	brlo tim2

;	jmp dump

tim2:	ret






	;--- Debug: Output byte Templ (ASCII) to serial port pin at 115200 8N1 ----

SerByteAsciiOut:


	push xl
	swap xl
	rcall su1		;high nibble
	pop xl
	rjmp su1		;low nibble

su1:	andi xl,0x0f
	ldi zl,low(su2*2)	;output one nibble in ASCII
	add zl,xl
	ldi zh,high(su2*2)
	clr xl
	adc zh,xl
	lpm xl,z
	rjmp SerByteOut

su2:	.db "0123456789ABCDEF"


		
SerOut16:
	push xh
	push xl

	mov xl, xh
	rcall SerByteAsciiOut
	pop xl
	push xl
	rcall SerByteAsciiOut

	pop xl
	pop xh
	ret



	


	;--- Debug: Output byte xl (binary) to serial port pin at 28800 8N1 ----

SerByteOut:
	cbi OutputPin8		;startbit
	nop
	nop
	nop

	rcall BaudRateDelay	

	ldi xh,8		;databits

sa3:	ror xl

	brcc sa1
	nop
	sbi OutputPin8
	rjmp sa2
sa1:	cbi OutputPin8
	nop
	nop

sa2:	rcall BaudRateDelay

	dec xh
	brne sa3

	nop
	nop
	nop
	nop

	sbi OutputPin8			;stopbit
	nop 
	nop
	nop
	rcall BaudRateDelay

	ret

BaudRatedelay:

	ldi t,231		;this delay may need tweaking to give errorfree transfer
ba1:	dec t
	brne ba1
	ret


*/



b824print:
	mov t, xh
	rcall hexprint
	mov t, xl
	rcall hexprint
	mov t, yh
	rcall hexprint
	mov t, yl
	rcall hexprint
	ret

b832print:
	mov t, xh
	rcall hexprint
	mov t, xl
	rcall hexprint
	mov t, yh
	rcall hexprint
	mov t, yl
	rcall hexprint
	mov t, zh
	rcall hexprint
	ret

b840print:
	mov t, xh
	rcall hexprint
	mov t, xl
	rcall hexprint
	mov t, yh
	rcall hexprint
	mov t, yl
	rcall hexprint
	mov t, zh
	rcall hexprint
	mov t, zl
	rcall hexprint
	ret


hexprint:
	pushz
	push t

	swap t
	andi t, 0x0f

	rcall hex2

	pop t
	andi t, 0x0f
	rcall hex2

	popz
	ret

hex2:	ldz hex1*2
	add zl, t
	clr t
	adc zh, t

	lpm t, z
	call PrintChar
	ret

hex1:	.db "0123456789ABCDEF"




