.macro b168fracmul 

;usage b168fracmul @0, @1

;Multiply a 16.8 bit signed integer (@1) by an 0.8 bit unsigned fraction (yl) and store result in the 16.8 bit sram location @0.  @0 = @1 * yl    

.def	Op1_2=r17
.def	Op1_1=r18
.def	Op1_0=r19

.def	Result2=r23
.def	Result1=r24
.def	Result0=r2
.def	Resultm1=r3
.def	Sign=r4

	lds Op1_2, @1 + 0
	lds Op1_1, @1 + 1
	lds Op1_0, @1 + 2

	call multfracc		;code is moved out of the macro to optimize for size with very little speed penalty.

	sts @0 + 0, Result2
	sts @0 + 1, Result1
	sts @0 + 2, Result0

.undef	Op1_2
.undef	Op1_1
.undef	Op1_0

.undef	Result2
.undef	Result1
.undef	Result0
.undef	resultm1
.undef	Sign



.endmacro
