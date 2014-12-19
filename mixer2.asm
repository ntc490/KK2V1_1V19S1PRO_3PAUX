









Mixer:					;mixer ratio at 100% mixvalue is 0.390625. To give a full trottle signal the input must be 11366.4


	ldz RamMixerTable + 0		;channel 1
	rcall mix1
	b16mov Offset1, Mixvalue
	b16mov Out1, Temp

	ldz RamMixerTable + 8		;channel 2
	rcall mix1
	b16mov Offset2, Mixvalue
	b16mov Out2, Temp

	ldz RamMixerTable + 16		;channel 3
	rcall mix1
	b16mov Offset3, Mixvalue
	b16mov Out3, Temp

	ldz RamMixerTable + 24		;channel 4
	rcall mix1
	b16mov Offset4, Mixvalue
	b16mov Out4, Temp

	ldz RamMixerTable + 32		;channel 5
	rcall mix1
	b16mov Offset5, Mixvalue
	b16mov Out5, Temp

	ldz RamMixerTable + 40		;channel 6
	rcall mix1
	b16mov Offset6, Mixvalue
	b16mov Out6, Temp

	ldz RamMixerTable + 48		;channel 7
	rcall mix1
	b16mov Offset7, Mixvalue
	b16mov Out7, Temp

	ldz RamMixerTable + 56		;channel 8
	rcall mix1
	b16mov Offset8, Mixvalue
	b16mov Out8, Temp

	ret



mix1:	clr yh
	ldd xl, Z + MixvalueOffset
	clr xh

	tst xl		;extend sign
	brpl mix2
	ser yh
	ser xh

mix2:	b16store Mixvalue

	b16ldi Temp, 44.4		;scale Mixvalue from -100 100 to -4440 4440 
	b16mul Mixvalue, Mixvalue, Temp
	
	b16load Mixvalue

	ldd t, Z + MixvalueThrottle
	b16mac RxThrottle
	 
	ldd t, Z + MixvalueRoll
	b16mac CommandRoll

	ldd t, Z + MixvaluePitch
	b16mac CommandPitch

	ldd t, Z + MixvalueYaw
	b16mac CommandYaw

	b16store Temp

	ret









