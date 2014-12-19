.def	Op1_2=r17
.def	Op1_1=r18
.def	Op1_0=r19

.def	Result2=r23
.def	Result1=r24
.def	Result0=r2
.def	Resultm1=r3
.def	Sign=r4

multfracc:	
	mov Sign, Op1_2		;calculate result sign

	tst Op1_2		;Op1=ABS(Op1)
	brpl mulf1
	com Op1_0
	com Op1_1
	com Op1_2
	ldi t,1
	add Op1_0, t
	clr t
	adc Op1_1, t
	adc Op1_2, t

mulf1:	clr Result1
	clr Result2

	mul Op1_0, yl		;mul #1
	mov Resultm1,r0
	mov Result0, r1
	clr t

	mul Op1_1, yl		;mul #2
	add Result0, r0
	adc Result1, r1
	adc Result2, t

	mul Op1_2, yl		;mul #3
	add Result1, r0
	adc Result2, r1
		
	lsl Resultm1		;round off

	adc Result0, t
	adc result1, t
	adc result2, t

				;no overflow test as we're multiplying with a fraction :-)

 	tst Sign		;negate result if sign set.
	brpl mulf2
	com Result0
	com Result1
	com Result2
	ldi t,1
	add Result0, t
	clr t
	adc Result1, t
	adc Result2, t

mulf2:	ret

.undef	Op1_2
.undef	Op1_1
.undef	Op1_0

.undef	Result2
.undef	Result1
.undef	Result0
.undef  Resultm1
.undef	Sign