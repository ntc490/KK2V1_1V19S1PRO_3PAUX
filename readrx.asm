
IntRoll:
	in SregSaver, sreg

	lds tt, flagCppmOn		;CPPM mode?
	tst tt
	brpl rx6
	rjmp cppm

rx6:	sbis pind,3			;rising or falling?
	rjmp rx1

	lds tt, tcnt1l			;rising, store the start value
	sts RollStartL, tt
	lds tt, tcnt1h
	sts RollStartH, tt
	
	clr tt
	sts RollDcnt, tt

	out sreg, SregSaver		;exit	
	reti

rx1:	lds tt, tcnt1l			;falling, calculate the pulse length
	lds treg, RollStartL
	sub tt, treg
	sts RollL, tt

	lds tt, tcnt1h
	lds treg, RollStartH
	sbc tt, treg
	sts RollH, tt

	out sreg, SregSaver		;exit	
	reti



IntPitch:
	in SregSaver, sreg

	sbis pind,2			;rising or falling?
	rjmp rx2

	lds tt, tcnt1l			;rising, store the start value
	sts PitchStartL, tt
	lds tt, tcnt1h
	sts PitchStartH, tt

	clr tt
	sts PitchDcnt, tt
	
	out sreg, SregSaver		;exit	
	reti

rx2:	lds tt, tcnt1l			;falling, calculate the pulse length
	lds treg, PitchStartL
	sub tt, treg
	sts PitchL, tt

	lds tt, tcnt1h
	lds treg, PitchStartH
	sbc tt, treg
	sts PitchH, tt

	out sreg, SregSaver		;exit	
	reti



IntThrottle:
	in SregSaver, sreg

	sbis pind,0			;rising or falling?
	rjmp rx3

	lds tt, tcnt1l			;rising, store the start value
	sts ThrottleStartL, tt
	lds tt, tcnt1h
	sts ThrottleStartH, tt
	
	clr tt
	sts ThrottleDcnt, tt

	out sreg, SregSaver		;exit	
	reti

rx3:	lds tt, tcnt1l			;falling, calculate the pulse length
	lds treg, ThrottleStartL
	sub tt, treg
	sts ThrottleL, tt

	lds tt, tcnt1h
	lds treg, ThrottleStartH
	sbc tt, treg
	sts ThrottleH, tt

	out sreg, SregSaver		;exit	
	reti



IntYaw:
	in SregSaver, sreg

	sbis pinb,2			;rising or falling?
	rjmp rx4

	lds tt, tcnt1l			;rising, store the start value
	sts YawStartL, tt
	lds tt, tcnt1h
	sts YawStartH, tt

	clr tt
	sts YawDcnt, tt
	
	out sreg, SregSaver		;exit	
	reti

rx4:	lds tt, tcnt1l			;falling, calculate the pulse length
	lds treg, YawStartL
	sub tt, treg
	sts YawL, tt

	lds tt, tcnt1h
	lds treg, YawStartH
	sbc tt, treg
	sts YawH, tt

	out sreg, SregSaver		;exit	
	reti



IntAux:
	in SregSaver, sreg

	sbis pinb,0			;rising or falling?
	rjmp rx5

	lds tt, tcnt1l			;rising, store the start value
	sts AuxStartL, tt
	lds tt, tcnt1h
	sts AuxStartH, tt

	clr tt
	sts AuxDcnt, tt
	
	out sreg, SregSaver		;exit	
	reti

rx5:	lds tt, tcnt1l			;falling, calculate the pulse length
	lds treg, AuxStartL
	sub tt, treg
	sts AuxL, tt

	lds tt, tcnt1h
	lds treg, AuxStartH
	sbc tt, treg
	sts AuxH, tt

	out sreg, SregSaver		;exit	
	reti

	;--- USART ISR ---

	//************************************************************
	//* Spektrum Satellite format (8-N-1/115Kbps) MSB sent first
	//* DX7/DX6i: One data-frame at 115200 baud every 22ms.
	//* DX7se:    One data-frame at 115200 baud every 11ms.
	//*
	//*    byte1: is a frame loss counter
	//*    byte2: [0 0 0 R 0 0 N1 N0]
	//*    byte3:  and byte4:  channel data (FLT-Mode)	= FLAP 6
	//*    byte5:  and byte6:  channel data (Roll)		= AILE A
	//*    byte7:  and byte8:  channel data (Pitch)		= ELEV E
	//*    byte9:  and byte10: channel data (Yaw)		= RUDD R
	//*    byte11: and byte12: channel data (Gear Switch) GEAR 5
	//*    byte13: and byte14: channel data (Throttle)	= THRO T
	//*    byte15: and byte16: channel data (AUX2)		= AUX2 8
	//* 
	//* DS9 (9 Channel): One data-frame at 115200 baud every 11ms,
	//* alternating frame 1/2 for CH1-7 / CH8-9
	//*
	//*   1st Frame:
	//*    byte1: is a frame loss counter
	//*    byte2: [0 0 0 R 0 0 N1 N0]
	//*    byte3:  and byte4:  channel data
	//*    byte5:  and byte6:  channel data
	//*    byte7:  and byte8:  channel data
	//*    byte9:  and byte10: channel data
	//*    byte11: and byte12: channel data
	//*    byte13: and byte14: channel data
	//*    byte15: and byte16: channel data
	//*   2nd Frame:
	//*    byte1: is a frame loss counter
	//*    byte2: [0 0 0 R 0 0 N1 N0]
	//*    byte3:  and byte4:  channel data
	//*    byte5:  and byte6:  channel data
	//*    byte7:  and byte8:  0xffff
	//*    byte9:  and byte10: 0xffff
	//*    byte11: and byte12: 0xffff
	//*    byte13: and byte14: 0xffff
	//*    byte15: and byte16: 0xffff
	//* 
	//* Each channel data (16 bit= 2byte, first msb, second lsb) is arranged as:
	//* 
	//* Bits: F 00 C3 C2 C1 C0  D9 D8 D7 D6 D5 D4 D3 D2 D1 D0 for 10-bit data (0 to 1023) or
	//* Bits: F C3 C2 C1 C0 D10 D9 D8 D7 D6 D5 D4 D3 D2 D1 D0 for 11-bit data (0 to 2047) 
	//* 
	//* R: 0 for 10 bit resolution 1 for 11 bit resolution channel data
	//* N1 to N0 is the number of frames required to receive all channel data. 
	//* F: 1 = indicates beginning of 2nd frame for CH8-9 (DS9 only)
	//* C3 to C0 is the channel number. 0 to 9 (4 bit, as assigned in the transmitter)
	//* D9 to D0 is the channel data 
	//*		(10 bit) 0xaa..0x200..0x356 for 100% transmitter-travel
	//*		(11 bit) 0x154..0x400..0x6ac for 100% transmitter-travel
	//*
	//* The data values can range from 0 to 1023/2047 to define a servo pulse width 
	//* from approximately 0.75ms to 2.25ms (1.50ms difference). 1.465us per digit.
	//* A value of 171/342 is 1.0 ms
	//* A value of 512/1024 is 1.5 ms
	//* A value of 853/1706 is 2.0 ms
	//* 0 = 750us, 1023/2047 = 2250us
	//*
	//************************************************************
	

	// This code only supports DSM2 1024/22ms
	// Tested with OrangeRX R100 Satellite and AR7/8000 Satellite
	// CH0 = Throttle, CH1 = Aileron, CH2 = Elevator, CH3 = Rudder, CH4 = Gear, etc....

IsrUsart:
	in SregSaver, sreg

    push zh
    push zl
    push xh
	push xl
   
	lds xl, tcnt1l			;X = TCNT1 - SerialRxStart, SerialRxStart = TCNT1
	lds xh, tcnt1h
	lds zl, SerialRxStartL
	lds zh, SerialRxStartH
	sts SerialRxStartL, xl
	sts SerialRxStartH, xh
	sub xl, zl
	sbc xh, zh

	brpl IU8			;X = ABS(X)
	ldz 0
	sub zl, xl
	sbc zh, xh
	movw x, z
IU8:	
	ldz 6250			;have we waited longer than 2.5ms?
	cp  xl, zl
	cpc xh, zh
	brlo IU11			; No

	rjmp IU3		;yes, reset array address sequence and exit

IU11:
	lds tt, flagSatRx
	tst tt
	brmi IU12			;Jump to Sat Rx code

	rjmp IU11SB			;Jump to SBus Rx code

IU12:	;code for Sat Rx
	lds zl, SerialByteArrayAddressL
	lds zh, SerialByteArrayAddressH

	ldx SerialByte15		; End of array reached?
	cp  zl, xl
	cpc zh, xh
	brlo IU1			; No
						; Yes

	// Routine when 16 bytes received
	
	lds	tt, UDR0					; Save 16th byte to array
	sts SerialByte15, tt

	ser	tt							; Show that we have successfully received 16 bytes
	sts flagSerialBufferFull, tt

IU3:
	ldz SerialByte0					; Reset to start of array
	rjmp IU2

IU1:						; Routine when < 16 bytes received	

	lds	tt, UDR0			; Get byte from buffer
	st	z+, tt				; Save byte to array and inc array address pointer
IU2:
	sts SerialByteArrayAddressL, zl	; Save array address pointer
	sts SerialByteArrayAddressH, zh

	clr tt							; reset timeout counter
	sts CppmTimeoutCounter, tt

	pop	xl
	pop	xh
	pop	zl
	pop zh

	out sreg, SregSaver		
	reti

	//************************************************************
	//* Futaba S-Bus format (8-E-2/100Kbps)
	//*	S-Bus decoding algorithm borrowed in part from Arduino
	//*
	//* The protocol is 25 Bytes long and is sent every 14ms (analog mode) or 7ms (highspeed mode).
	//* One Byte = 1 startbit + 8 data bit + 1 parity bit + 2 stopbit (8E2), baudrate = 100,000 bit/s
	//*
	//* The highest bit is sent first. The logic is inverted :( Stupid Futaba.
	//*
	//* [startbyte] [data1] [data2] .... [data22] [flags][endbyte]
	//* 
	//* 0 startbyte = 11110000b (0xF0)
	//* 1-22 data = [ch1, 11bit][ch2, 11bit] .... [ch16, 11bit] (Values = 0 to 2047)
	//* 	channel 1 uses 8 bits from data1 and 3 bits from data2
	//* 	channel 2 uses last 5 bits from data2 and 6 bits from data3
	//* 	etc.
	//* 
	//* 23 flags = 
	//*		bit7 = ch17 = digital channel (0x80)
	//* 	bit6 = ch18 = digital channel (0x40)
	//* 	bit5 = Frame lost, equivalent red LED on receiver (0x20)
	//* 	bit4 = failsafe activated (0x10)
	//* 	bit3 = n/a
	//* 	bit2 = n/a
	//* 	bit1 = n/a
	//* 	bit0 = n/a
	//* 24 endbyte = 00000000b
	//*
	//************************************************************

IU11SB:					;code for SBus Rx
	lds zl, SerialByteArrayAddressL
	lds zh, SerialByteArrayAddressH

	ldx SerialByte24		; End of array reached?
	cp  zl, xl
	cpc zh, xh
	brlo IU1SB			; No
						; Yes

	// Routine when 25 bytes received
	
	lds	tt, UDR0					; Save 25th byte to array
	sts SerialByte24, tt

	ser	tt							; Show that we have successfully received 25 bytes
	sts flagSerialBufferFull, tt

	ldz SerialByte0					; Reset to start of array
	rjmp IU2SB

IU1SB:						; Routine when < 24 bytes received	

	lds	tt, UDR0			; Get byte from buffer
	st	z+, tt				; Save byte to array and inc array address pointer
IU2SB:
	sts SerialByteArrayAddressL, zl	; Save array address pointer
	sts SerialByteArrayAddressH, zh

	clr tt							; reset timeout counter
	sts CppmTimeoutCounter, tt

	pop	xl
	pop	xh
	pop	zl
	pop zh

	out sreg, SregSaver		
	reti

	;--- CPPM ISR ---

cppm:	sbic pind,3			;rising or falling?
	rjmp rx7

	out sreg, SregSaver		;falling, exit	
	reti

rx7:	push xl				;rising, calculate pulse length:
	push xh
	push zl
	push zh
	
	lds xl, tcnt1l			;X = TCNT1 - CppmPulseStart, CppmPulseStart = TCNT1
	lds xh, tcnt1h
	lds zl, CppmPulseStartL
	lds zh, CppmPulseStartH
	sts CppmPulseStartL, xl
	sts CppmPulseStartH, xh
	sub xl, zl
	sbc xh, zh

	brpl rx8			;X = ABS(X)
	ldz 0
	sub zl, xl
	sbc zh, xh
	movw x, z
rx8:	
	ldz 6250			;pulse longer than 2.5ms?
	cp  xl, zl
	cpc xh, zh
	brlo rx11

	ldz CppmChannel1L		;yes, reset cppm sequence and exit
	rjmp rx10

rx11:	lds zl, CppmPulseArrayAddressL	;store channel in channel array.
	lds zh, CppmPulseArrayAddressH

	st z+, xl
	st z+, xh

	ldx CppmChannel9L		;end of array reached?
	cp  zl, xl
	cpc zh, xh
	brlo rx10
	breq rx10

	ldz CppmChannel9L		;yes, limit

rx10:	sts CppmPulseArrayAddressL, zl	;store array pointer
	sts CppmPulseArrayAddressH, zh

	clr tt				;reset timeout counter
	sts CppmTimeoutCounter, tt

	pop zh
	pop zl
	pop xh
	pop xl

	out sreg, SregSaver		;exit	
	reti


	;---


GetRxChannels:

	; If using a satellite, need to move channels into Cppm Channel Array
	; Only supports 10 bit and all channels in a single frame (16 bytes)

	rvbrflagtrue flagSerialBufferFull, sat4		;only shuffle channels if buffer is full
	rjmp skipsatchannelmove
sat4:						
	rvbrflagtrue flagDSM2Rx, sat5	;code for DSM2
	rvbrflagtrue flagDSMXRx, sat4a  ;code for DSMX
	rjmp sbus1
sat4a:
	rjmp satx5
sat5:					; code for DSM2
	ldx SerialByte2		; Skip first 2 bytes
	ldy SerialByte15+1	; used as loop counter
	
	; Set CPPM Array to 1st location
sat3:
	ldz CppmChannel1L
	ld	t,x
	lsr t
	andi t, 0x0E		; Mask Channel Number
	inc t			; Add one so we end up at CppmChannelXH
	
	add zl,t		; Increase CPPM Channel Array Pointer for current sat channel
	brcc	sat2
	inc zh
sat2:
	ld t,x+
	andi t,0x03		; Mask for D9 & D8
	st z,t			; Store and decrement pointer
	sbiw z,1
	ld t,x+			; Get D0 to D7
	st z,t			; Store D0 to D7

	; Check to see if we have got to Byte 16 (X is actully pointing to Byte17)
	cp  yl, xl
	cpc yh, xh

	brne sat3

	; Go through CPPM Channel Array and do some maths so the values are meaningful

	ldx	CppmChannel9H+1
	ldy CppmChannel1L
	ldz CppmChannel9H+1

sat7:
	ld t,-x
	mov r5,t
	ld t,-x
	mov r6,t
	
	ldi r23,high(512)			;(r5,r6) = (r5,r6)-512
	ldi r24,low(512)
	sub r6, r24
	sbc r5, r23

	mov r17, r6					;(r24,r2)=(r18,r17)*r19
	mov r18, r5
	ldi r19, 0b11101110			;0.9296875

	mov r4, r18					;calculate result sign
	tst r4						;r18=ABS(r18)
	brpl mulf1s2
	com r17
	com r18
	ldi r23,1
	add r17, r23
	clr r23
	adc r18, r23

mulf1s2:	
	clr r24
	clr r23

	mul r17, r19				;mul #1
	mov r3,r0
	mov r2, r1

	mul r18, r19				;mul #2
	add r2, r0
	adc r24, r1

	lsl r3						;round off

	adc r2, r23
	adc r24, r23

 	tst r4						;negate result if sign set.
	brpl mulf2s2
	com r2
	com r24
	ldi r23,1
	add r2, r23
	clr r23
	adc r24, r23
mulf2s2:	
	
	lsl r6						;(r5,r6) = (r5,r6)*2
	rol r5
	add r6, r2					;(r5,r6) = (r5,r6)+0.9296875
	adc r5, r24

	ldi r23,high(3750)			;(r5,r6) = (r5,r6)+3750
	ldi r24,low(3750)
	add r6, r24
	adc r5, r23

	mov t, r5
	st -z,t
	mov t, r6
	st -z,t

	cp  yl, xl		; Did we reach CppmChannel1L yet?
	cpc yh, xh

	brne sat8
	rjmp channelmoveexit
sat8:jmp sat7	

;code for DSMX

satx5:
	ldx SerialByte2	; Skip first 2 bytes
	ldy SerialByte15+1	; used as loop counter
	
	; Set CPPM Array to 1st location
satx3:
	ldz CppmChannel1L
	ld	t,x
	lsr t
	lsr t
	andi t, 0x0E	; Mask Channel Number
	inc t			; Add one so we end up at CppmChannelXH
	
	add zl,t		; Increase CPPM Channel Array Pointer for current sat channel
	brcc	satx2
	inc zh
satx2:
	ld t,x+
	andi t,0x07		; Mask for D9 & D8
	st z,t			; Store and decrement pointer
	sbiw z,1
	ld t,x+			; Get D0 to D7
	st z,t			; Store D0 to D7

	; Check to see if we have got to Byte 16 (X is actully pointing to Byte17)
	cp  yl, xl
	cpc yh, xh

	brne satx3

	; Go through CPPM Channel Array and do some maths so the values are meaningful

	ldx	CppmChannel9H+1
	ldy CppmChannel1L
	ldz CppmChannel9H+1

satx7:
	ld t,-x
	mov r5,t
	ld t,-x
	mov r6,t
	
	ldi r23,high(1024)			;(r5,r6) = (r5,r6)-1024
	ldi r24,low(1024)
	sub r6, r24
	sbc r5, r23

	mov r17, r6					;(r24,r2)=(r18,r17)*r19
	mov r18, r5
	ldi r19, 0b01110111			;0.46484375

	mov r4, r18					;calculate result sign
	tst r4						;r18=ABS(r18)
	brpl mulf1sx
	com r17
	com r18
	ldi r23,1
	add r17, r23
	clr r23
	adc r18, r23

mulf1sx:	
	clr r24
	clr r23

	mul r17, r19				;mul #1
	mov r3,r0
	mov r2, r1

	mul r18, r19				;mul #2
	add r2, r0
	adc r24, r1

	lsl r3						;round off

	adc r2, r23
	adc r24, r23

 	tst r4						;negate result if sign set.
	brpl mulf2sx
	com r2
	com r24
	ldi r23,1
	add r2, r23
	clr r23
	adc r24, r23
mulf2sx:	

	add r6, r2					;(r5,r6) = (r5,r6)*1.46484375
	adc r5, r24

	ldi r23,high(3750)			;(r5,r6) = (r5,r6)+3750
	ldi r24,low(3750)
	add r6, r24
	adc r5, r23

	mov t, r5
	st -z,t
	mov t, r6
	st -z,t

	cp  yl, xl		; Did we reach CppmChannel1L yet?
	cpc yh, xh

	brne satx8
	rjmp channelmoveexit
satx8:jmp satx7	

channelmoveexit:
	
	clr	t
	sts flagSerialBufferFull, t

skipsatchannelmove:

; check to see if standard receiver channels are to be mapped

	rvbrflagfalse flagChannelMap, rx11a
	rjmp rx11am

	;--- Roll ---
rx11a:
	rvbrflagfalse flagCppmOn, rx12

	ldz eeCppmRoll
	rcall GetCppmChannel
	rjmp rx13


rx12:	cli				;get roll channel value
	lds xl, RollL
	lds xh, RollH
	sei

rx13:	rcall gt1m1			;sanitize
	
	rvbrflagfalse flagRollRev, rx13a	; reverse the direction if flag set
	com xl
	com xh

	ldi t,1
	add xl,t
	clr t
	adc xh,t 
rx13a:
	clr yh				;store in register
	b16store RxRoll

	
	;--- Pitch

	rvbrflagfalse flagCppmOn, rx14

	ldz eeCppmPitch
	rcall GetCppmChannel
	rjmp rx15

rx14:	cli				;get Pitch channel value
	lds xl, PitchL
	lds xh, PitchH
	sei

rx15:	rcall gt1m1			;sanitize
	rvbrflagfalse flagPitchRev, rx15a	; reverse the direction if flag set
	com xl
	com xh

	ldi t,1
	add xl,t
	clr t
	adc xh,t 
rx15a:
	clr yh				;store in register
	b16store RxPitch


	;--- Throttle ---

	rvbrflagfalse flagCppmOn, rx16

	ldz eeCppmThrottle
	rcall GetCppmChannel
	rjmp rx17

rx16:	cli				;get Throttle channel value
	lds xl, ThrottleL
	lds xh, ThrottleH
	sei

rx17:	rvsetflagfalse flagThrottleZero

	rcall Xabs			;X = ABS(X)

	ldz 2875			;X = X - 2875 (1.15ms)
	sub xl, zl
	sbc xh, zh

	ldz 0				;X < 0 ?
	cp  xl, zl
	cpc xh, zh
	brge gt8m8

	rjmp rx30			;yes, set to zero

gt8m8:	ldz 3125			;X > 3125? (1.25ms)
	cp  xl, zl
	cpc xh, zh
	brlt gt7m2

rx30:	ldx 0				;Yes, set to zero
	rvsetflagtrue flagThrottleZero

gt7m2:	clr yh				;store in register
	b16store RxThrottle


	;--- Yaw ---

	rvbrflagfalse flagCppmOn, rx18

	ldz eeCppmYaw
	rcall GetCppmChannel
	rjmp rx19

rx18:	cli				;get Yaw channel value
	lds xl, YawL
	lds xh, YawH
	sei

rx19:	rcall gt1m1			;sanitize
	rvbrflagfalse flagYawRev, rx19a		; reverse the direction if flag set
	com xl
	com xh

	ldi t,1
	add xl,t
	clr t
	adc xh,t 
rx19a:
	clr yh				;store in register
	b16store RxYaw

	
	;--- AUX ---

	rvbrflagfalse flagCppmOn, rx20

	ldz eeCppmAux
	rcall GetCppmChannel
	rjmp rx21

rx20:	cli				;get Aux channel value
	lds xl, AuxL
	lds xh, AuxH
	sei

rx21:	rcall gt1m1			;sanitize

	rvsetflagfalse flagAuxOn
	tst xh
	brmi gt9m3
	breq gt9m3
	rvsetflagtrue flagAuxOn
	
gt9m3:	clr yh				;store in register
	b16store RxAux

	rvsetflagfalse flagAuxMidPlus

	ldz -75
	cp  xl, zl
	cpc xh, zh
	brlt gt9m4
	rvsetflagtrue flagAuxMidPlus
gt9m4:

	;--- AUX2 ---

	rvbrflagtrue flagCppmOn, rx21aaaa	;if we are using CPPM, SBux or Satellite, process Aux 2, 3 & 4
	rjmp rx21aaa

rx21aaaa:
  	ldi	t,5		;AUX2 is on CPPM/SAT/SBUS CH6
	mov r0, t
	ldzarray CppmChannel1L, 2, r0
	cli
	ld xl, z+
	ld xh, z
	sei

	rcall gt1m1			;sanitize
	
	clr yh				;store in register
	b16store RxAux2

	;--- AUX3 ---

	ldi	t,6		;AUX3 is on CPPM/SAT/SBUS CH7
	mov r0, t
	ldzarray CppmChannel1L, 2, r0
	cli
	ld xl, z+
	ld xh, z
	sei

	rcall gt1m1			;sanitize
	
	clr yh				;store in register
	b16store RxAux3

	;--- AUX4 ---

	rvbrflagtrue flagSatRX, rx21aaa	;if we are not using Satellite, skip Aux 4

	ldi	t,7		;AUX4 is on CPPM/SBUS CH8
	mov r0, t
	ldzarray CppmChannel1L, 2, r0
	cli
	ld xl, z+
	ld xh, z
	sei

	rcall gt1m1			;sanitize
	
	clr yh				;store in register
	b16store RxAux4

	;--- Check rx ---
	;Ignore check for Aux2, Aux3 & Aux 4

rx21aaa:
	ser t						;RC911 more efficient code
	sts flagRollValid, t
	sts flagPitchValid, t
	sts flagThrottleValid, t
	sts flagYawValid, t
	sts flagAuxValid, t	

	rvbrflagtrue flagCppmOn, rx22
	rjmp rx24

rx22:	rvinc CppmTimeoutCounter			;CPPM timeout?
	rvcp CppmTimeoutCounter, RxTimeoutLimit
	brlo rx23			
	rvdec CppmTimeoutCounter
	clr t						;yes, set flags to false and values to 0
	sts flagRollValid, t
	sts flagPitchValid, t
	sts flagThrottleValid, t
	sts flagYawValid, t
	sts flagAuxValid, t	
;	b16clr RxRoll
;	b16clr RxPitch
	b16clr RxThrottle
	rvsetflagtrue flagThrottleZero
	b16clr RxYaw
	b16clr RxAux
	rvsetflagfalse flagAuxOn

rx23:	ret


rx24:	rvinc RollDcnt					;signal timed out?
	rvcp RollDcnt, RxTimeoutLimit
	brlo rx25			
	rvdec RollDcnt
	rvsetflagfalse flagRollValid			;Yes, set flag to false
;	b16clr RxRoll					;Don't reset Roll to zero so it recovers better
	rvsetflagtrue flagThrottleZero			;Kill throttle to stop it flipping
	b16clr RxThrottle

rx25:	rvinc PitchDcnt					;signal timed out?
	rvcp PitchDcnt, RxTimeoutLimit
	brlo rx26			
	rvdec PitchDcnt
	rvsetflagfalse flagPitchValid			;Yes, set flag to false
;	b16clr RxPitch					;Don't reset Pitch to zero so it recovers better
	rvsetflagtrue flagThrottleZero			;Kill throttle to stop it flipping
	b16clr RxThrottle

rx26:	rvinc ThrottleDcnt				;signal timed out?
	rvcp ThrottleDcnt, RxTimeoutLimit
	brlo rx27			
	rvdec ThrottleDcnt
	rvsetflagfalse flagThrottleValid		;Yes, set flag to false and set value to 0
	b16clr RxThrottle
	rvsetflagtrue flagThrottleZero

rx27:	rvinc YawDcnt					;signal timed out?
	rvcp YawDcnt, RxTimeoutLimit
	brlo rx28			
	rvdec YawDcnt
	rvsetflagfalse flagYawValid			;Yes, set flag to false and set value to 0 to stop it yawing
	b16clr RxYaw

rx28:	rvinc AuxDcnt					;signal timed out?
	rvcp AuxDcnt, RxTimeoutLimit
	brlo rx29			
	rvdec AuxDcnt
	rvsetflagfalse flagAuxValid			;Yes, set flag to false and set value to 0
	b16clr RxAux
	rvsetflagfalse flagAuxOn

rx29:	ret


; routine to run if standard receiver channels are to be mapped

rx11am:

	cli						;get roll input channel value
	lds xl, RollL
	lds xh, RollH
	sei

	sts CppmChannel1L, xl	;save in CPPM Channel Array
	sts CppmChannel1H, xh

	cli						;get pitch input channel value
	lds xl, PitchL
	lds xh, PitchH
	sei

	sts CppmChannel2L, xl	;save in CPPM Channel Array
	sts CppmChannel2H, xh

	cli						;get throttle input channel value
	lds xl, ThrottleL
	lds xh, ThrottleH
	sei

	sts CppmChannel3L, xl	;save in CPPM Channel Array
	sts CppmChannel3H, xh

	cli						;get yaw input channel value
	lds xl, YawL
	lds xh, YawH
	sei

	sts CppmChannel4L, xl	;save in CPPM Channel Array
	sts CppmChannel4H, xh

	cli						;get Aux input channel value
	lds xl, AuxL
	lds xh, AuxH
	sei

	sts CppmChannel5L, xl	;save in CPPM Channel Array
	sts CppmChannel5H, xh

	;--- Roll ---

	ldz eeCppmRoll
	rcall GetCppmChannel

	rcall gt1m1			;sanitize
	rvbrflagfalse flagRollRev, rx13b	; reverse the direction if flag set
	com xl
	com xh

	ldi t,1
	add xl,t
	clr t
	adc xh,t 
rx13b:
	clr yh				;store in register
	b16store RxRoll

	;--- Pitch

	ldz eeCppmPitch
	rcall GetCppmChannel

	rcall gt1m1			;sanitize
	rvbrflagfalse flagPitchRev, rx13c	; reverse the direction if flag set
	com xl
	com xh

	ldi t,1
	add xl,t
	clr t
	adc xh,t 
rx13c:
	clr yh				;store in register
	b16store RxPitch


	;--- Throttle ---

	ldz eeCppmThrottle
	rcall GetCppmChannel

	rvsetflagfalse flagThrottleZero

	rcall Xabs			;X = ABS(X)

	ldz 2875			;X = X - 2875 (1.15ms)
	sub xl, zl
	sbc xh, zh

	ldz 0				;X < 0 ?
	cp  xl, zl
	cpc xh, zh
	brge gt8m8m

	rjmp rx30m			;yes, set to zero

gt8m8m:	ldz 3125			;X > 3125? (1.25ms)
	cp  xl, zl
	cpc xh, zh
	brlt gt7m2m

rx30m:	ldx 0				;Yes, set to zero
	rvsetflagtrue flagThrottleZero

gt7m2m:	

	clr yh				;store in register
	b16store RxThrottle

	;--- Yaw ---

	ldz eeCppmYaw
	rcall GetCppmChannel

	rcall gt1m1			;sanitize
	rvbrflagfalse flagYawRev, rx13d	; reverse the direction if flag set
	com xl
	com xh

	ldi t,1
	add xl,t
	clr t
	adc xh,t 
rx13d:
	clr yh				;store in register
	b16store RxYaw
	
	;--- AUX ---

	ldz eeCppmAux
	rcall GetCppmChannel

	rcall gt1m1			;sanitize

	rvsetflagfalse flagAuxOn
	tst xh
	brmi gt9m3m
	breq gt9m3m
	rvsetflagtrue flagAuxOn
	
gt9m3m:	
	clr yh				;store in register
	b16store RxAux

	rjmp rx21aaa			;return to standard code

	;----

	;SBUS Channel Map Code.  Stores Ch1 to Ch7 in CPPM array

	//* 0 startbyte = 11110000b (0xF0)
	//* 1-22 data = [ch1, 11bit][ch2, 11bit] .... [ch16, 11bit] (Values = 0 to 2047)
	//* 	channel 1 uses 8 bits from data1 and 3 bits from data2
	//* 	channel 2 uses last 5 bits from data2 and 6 bits from data3
	//* 	etc.

	// Thanks to RC911 for saving me the pain of working out the right shifts :-)

sbus1:

	ldz		CppmChannel1L
	lds		xl, SerialByte1		;CH1
	lds		xh, SerialByte2
	rcall	sbuspulsewidth

	lds		xl, SerialByte2		;CH2
	lds		xh, SerialByte3
	ror		xh
	ror		xl
	ror		xh
	ror		xl
	ror		xh
	ror		xl
	rcall	sbuspulsewidth

	lds		yh, SerialByte3		;CH3
	lds		xl, SerialByte4
	lds		xh, SerialByte5
	rol		yh
	rol		xl
	rol		xh
	rol		yh
	rol		xl
	rol		xh
	rcall	sbuspulsewidth

	lds		xl, SerialByte5		;CH4
	lds		xh, SerialByte6
	ror		xh
	ror		xl
	rcall	sbuspulsewidth

	lds		xl, SerialByte6		;CH5
	lds		xh, SerialByte7
	ror		xh
	ror		xl
	ror		xh
	ror		xl
	ror		xh
	ror		xl
	ror		xh
	ror		xl
	rcall	sbuspulsewidth

	lds		yh, SerialByte7		;CH6
	lds		xl, SerialByte8
	lds		xh, SerialByte9
	rol		yh
	rol		xl
	rol		xh
	rcall	sbuspulsewidth

	lds		xl, SerialByte9		;CH7
	lds		xh, SerialByte10
	ror		xh
	ror		xl
	ror		xh
	ror		xl
	rcall	sbuspulsewidth

	lds		xl, SerialByte10	;CH8
	lds		xh, SerialByte11
	ror xh
	ror xl
	ror xh
	ror xl
	ror xh
	ror xl
	ror xh
	ror xl
	ror xh
	ror xl
	rcall	sbuspulsewidth

	rjmp	channelmoveexit		;jump back to the CCPM code now

sbuspulsewidth:

	andi xh, 0x07

	ldy 1024			;(xh,xl) = (xh,xl)-1024
	sub xl, yl
	sbc xh, yh

	mov r17, xl			;(r24,r2)=(r18,r17)*r19
	mov r18, xh
	ldi r19, 0b01110111	;0.46484375

	mov r4, r18			;calculate result sign
	tst r4				;r18=ABS(r18)
	brpl mulf1s
	com r17
	com r18
	ldi r23,1
	add r17, r23
	clr r23
	adc r18, r23

mulf1s:	
	clr r24
	clr r23

	mul r17, r19			;mul #1
	mov r3,r0
	mov r2, r1

	mul r18, r19			;mul #2
	add r2, r0
	adc r24, r1

	lsl r3					;round off

	adc r2, r23
	adc r24, r23

 	tst r4					;negate result if sign set.
	brpl mulf2s
	com r2
	com r24
	ldi r23,1
	add r2, r23
	clr r23
	adc r24, r23
mulf2s:	

	add xl, r2				;(xh,xl) = (xh,xl)*1.46484375
	adc xh, r24

	ldy 3750				;(xh,xl) = (xh,xl)+3750
	add xl, yl
	adc xh, yh

	st	z+, xl				;save in CPPM Channel Array
	st	z+, xh

	ret

	;----

GetCppmChannel:
	call ReadEeprom
	dec t
	mov r0, t
	ldzarray CppmChannel1L, 2, r0
	cli
	ld xl, z+
	ld xh, z
	sei

	ret

gt1m1:	rcall Xabs	;X = ABS(X)

	ldz 3750	;X = X - 3750 (1.5ms)
	sub xl, zl
	sbc xh, zh

	ldz -1750	;X < -1750?  (0.7ms)
	cp  xl, zl
	cpc xh, zh
	brlt gt1m2

	ldz 1750	;X > 1750?
	cp  xl, zl
	cpc xh, zh
	brge gt1m2

	ret		;No, exit

gt1m2:	ldx 0		;Yes, set to zero
	ret





Xabs:	tst xh		;X = ABS(X)
	brpl xa1

	com xl
	com xh
	
	ldi t,1
	add xl,t
	clr t
	adc xh,t

xa1:	ret




