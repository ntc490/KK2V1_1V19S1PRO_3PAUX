

Lva:	b16sub Error, BatteryVoltage, BatteryVoltageLowpass		;lowpass filter
	b16fdiv Error, 8
	b16add BatteryVoltageLowpass, BatteryVoltageLowpass, Error

	b16sub Error, BattAlarmVoltage, BatteryVoltageLowpass		;Calculate error
	brpl lva3
	rjmp lva1
lva3:
	b16fdiv Error, 2

	b16ldi Temp, 16							;limit error
	b16cmp Error, Temp
	brlt lva2
	b16mov Error, Temp
lva2:
	b16add LvaDdsAcc, LvaDdsAcc, Error				;DDS
	b16load LvaDdsAcc
	tst xl
	brmi lva1
	rvsetflagtrue flagLvaBuzzerOn
	ret

lva1:	rvsetflagfalse flagLvaBuzzerOn

	ret


