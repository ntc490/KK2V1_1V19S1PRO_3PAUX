.def	i	=r17
.def	twidata	=r18


AdcRead:

	ldi t, 3
	store admux, t		;channel to be read

	;        76543210
	ldi t, 0b11000111
	store adcsra, t		;start ADC

	ldi		t,0x3B
	sts		TWI_address,t		; Read MPU6050 from 0X3B
	ldi		twidata,14			; Read 14 addresses
	call 	i2c_read_adr_d

	ldx 2500		;timeout limit (X * 8 cycles) for ADC
	
	clr yh

adc2:	sbiw x, 1		;wait until finished or timeout
	brcs adc1
	lds t, adcsra
	sbrc t, adsc
	rjmp adc2
	
	cli
	load xl, adcl		;X = ADC
	load xh, adch
	sei

adc1:	;log timeout error here

	b16store BatteryVoltage
	b16add BatteryVoltage, BattAdcTrim, BatteryVoltage

	rvflagnot flagA, flagAuxOn
	rvflagand flagB, flagArmed, flagA	; only update max and min if armed and self level off
	rvbrflagfalse flagB, adc20

	call logmaxmin

adc20:
	ret



.undef	i	
.undef	twidata	
