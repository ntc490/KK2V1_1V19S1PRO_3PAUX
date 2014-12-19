
.def Counter	=r17

LoadMixer:

loa13:	ldy loa1 * 2

	lds xl, LoadMenuListYposSave
	lds xh, LoadMenuCursorYposSave

	ldi t, 20

	call Menu

	sts LoadMenuListYposSave, yl
	sts LoadMenuCursorYposSave, yh


	brcs loa22		;BACK pressed?
	ret			;Yes, return


loa22:	call LcdClear		

	lrv PixelType, 1
	lrv FontSelector, f6x8

	lrv X1, 20
	lrv Y1, 25
	mPrintString loa16	;Print "Are you sure?"

	;footer
	lrv X1, 0
	lrv Y1, 57
	mPrintString loa17

	call LcdUpdate

	call GetButtonsBlocking

	cpi t, 0x01		;Yes
	breq loa18

	rjmp loa13		;no


loa18:	BuzzerOn

	sts SelectedMotorLayout, xl	;save motor layout selected

	ldzarray mod0 * 2, 64, xl
	movw X, Z
	ldy eeMixerTable
	ldi Counter, 64
	
loa19:	movw Z, X		;copy mixertable to EEPROM
	lpm t, Z
	movw Z, Y
	call WriteEeprom
	adiw X, 1
	adiw Y, 1
	dec Counter
	brne loa19
	
	BuzzerOff		

	lds xl,SelectedMotorLayout	;save motor layout to eeprom
	ldz eeSelectedMotorLayout
	call StoreEeVariable8
	
	call FlightInit		;update RAM with new table

	call MotorLayout

	rjmp loa13

.undef Counter



loa1:	.db "SingleCopter 2M 2S  "
	.db "SingleCopter 1M 4S  "
	.db "DualCopter          "
	.db "TriCopter Servo M4  "
	.db "TriCopter Servo M7  "
	.db "Y6                  "
	.db "QuadroCopter + mode "
	.db "QuadroCopter x mode "
	.db "X8           + mode "
	.db "X8           x mode "
	.db "HexaCopter   + mode "
	.db "HexaCopter   x mode "
	.db "OctoCopter   + mode "
	.db "OctoCopter   x mode "
	.db "H6                  "
	.db "H8                  "
	.db "V6                  "
	.db "V8                  "
;	.db "Airplane 1S Aileron "
;	.db "Airplane 2S Aileron "
;	.db "Flying Wing         "
	.db "Y4                  "
	.db "V-Tail              "

loa16:	.db "Are you sure?", 0
loa17:	.db "CANCEL            YES",0




mod0:
	;    thr roll pitch yaw offs flags unused
	.db  100, 0  , 0  , 100, 0  , 3  , 0  , 0	;m1
	.db  100, 0  , 0  ,-100, 0  , 3  , 0  , 0	;m2
	.db  0  , 100, 0  , 0  , 50 , 0  , 0  , 0	;m3
	.db  0  , 0  , 100, 0  , 50 , 0  , 0  , 0	;m4
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m5
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m6
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m7
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m8

	;    thr roll pitch yaw offs flags unused
	.db  100, 0  , 0  , 0  , 0  , 3  , 0  , 0	;m1
	.db  0  , 100, 0  , 100, 50 , 0  , 0  , 0	;m2
	.db  0  , 0  , 100, 100, 50 , 0  , 0  , 0	;m3
	.db  0  ,-100, 0  , 100, 50 , 0  , 0  , 0	;m4
	.db  0  , 0  ,-100, 100, 50 , 0  , 0  , 0	;m5
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m6
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m7
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m8

	;    thr roll pitch yaw offs flags unused
	.db  100, 100, 0  , 0  , 0  , 3  , 0  , 0	;m1
	.db  100,-100, 0  , 0  , 0  , 3  , 0  , 0	;m2
	.db  0  , 0  , 100, 100, 0  , 0  , 0  , 0	;m3
	.db  0  , 0  ,-100, 100, 0  , 0  , 0  , 0	;m4
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m5
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m6
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m7
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m8

	;    thr roll pitch yaw offs flags unused
	.db  100,-87 , 50 , 0  , 0  , 3  , 0  , 0	;m1
	.db  100, 87 , 50 ,-1  , 0  , 3  , 0  , 0	;m2
	.db  100, 0  ,-100, 0  , 0  , 3  , 0  , 0	;m3
	.db  0  , 0  , 0  , 100, 50 , 0  , 0  , 0	;m4
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m5
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m6
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m7
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m8

	;    thr roll pitch yaw offs flags unused
	.db  100,-87 , 50 , 0  , 0  , 3  , 0  , 0	;m1
	.db  100, 87 , 50 ,-1  , 0  , 3  , 0  , 0	;m2
	.db  100, 0  ,-100, 0  , 0  , 3  , 0  , 0	;m3
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m4
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m5
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m6
	.db  0  , 0  , 0  , 100, 50 , 0  , 0  , 0	;m7
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m8

	;    thr roll pitch yaw offs flags unused
	.db  100,-87 , 50 , 100, 0  , 3  , 0  , 0	;m1
	.db  100,-87 , 50 ,-100, 0  , 3  , 0  , 0	;m2
	.db  100, 87 , 50 , 100, 0  , 3  , 0  , 0	;m3
	.db  100, 87 , 50 ,-100, 0  , 3  , 0  , 0	;m4
	.db  100, 0  ,-100, 100, 0  , 3  , 0  , 0	;m5
	.db  100, 0  ,-100,-100, 0  , 3  , 0  , 0	;m6
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m7
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m8

	;    thr roll pitch yaw offs flags unused
	.db  100, 0  , 100, 100, 0  , 3  , 0  , 0	;m1
	.db  100, 100, 0  ,-100, 0  , 3  , 0  , 0	;m2
	.db  100, 0  ,-100, 100, 0  , 3  , 0  , 0	;m3
	.db  100,-100, 0  ,-100, 0  , 3  , 0  , 0	;m4
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m5
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m6
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m7
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m8

	;    thr roll pitch yaw offs flags unused
	.db  100,-71 , 71 , 100, 0  , 3  , 0  , 0	;m1
	.db  100, 71 , 71 ,-100, 0  , 3  , 0  , 0	;m2
	.db  100, 71 ,-71 , 100, 0  , 3  , 0  , 0	;m3
	.db  100,-71 ,-71 ,-100, 0  , 3  , 0  , 0	;m4
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m5
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m6
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m7
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m8

	;    thr roll pitch yaw offs flags unused
	.db  100, 0  , 100, 100, 0  , 3  , 0  , 0	;m1
	.db  100, 0  , 100,-100, 0  , 3  , 0  , 0	;m2
	.db  100, 100, 0  , 100, 0  , 3  , 0  , 0	;m3
	.db  100, 100, 0  ,-100, 0  , 3  , 0  , 0	;m4
	.db  100, 0  ,-100, 100, 0  , 3  , 0  , 0	;m5
	.db  100, 0  ,-100,-100, 0  , 3  , 0  , 0	;m6
	.db  100,-100, 0  , 100, 0  , 3  , 0  , 0	;m7
	.db  100,-100, 0  ,-100, 0  , 3  , 0  , 0	;m8

	;    thr roll pitch yaw offs flags unused
	.db  100,-71 , 71 , 100, 0  , 3  , 0  , 0	;m1
	.db  100,-71 , 71 ,-100, 0  , 3  , 0  , 0	;m2
	.db  100, 71 , 71 , 100, 0  , 3  , 0  , 0	;m3
	.db  100, 71 , 71 ,-100, 0  , 3  , 0  , 0	;m4
	.db  100, 71 ,-71 , 100, 0  , 3  , 0  , 0	;m5
	.db  100, 71 ,-71 ,-100, 0  , 3  , 0  , 0	;m6
	.db  100,-71 ,-71 , 100, 0  , 3  , 0  , 0	;m7
	.db  100,-71 ,-71 ,-100, 0  , 3  , 0  , 0	;m8

	;    thr roll pitch yaw offs flags unused
	.db  100, 0  , 100, 100, 0  , 3  , 0  , 0	;m1
	.db  100, 87 , 50 ,-100, 0  , 3  , 0  , 0	;m2
	.db  100, 87 ,-50 , 100, 0  , 3  , 0  , 0	;m3
	.db  100, 0  ,-100,-100, 0  , 3  , 0  , 0	;m4
	.db  100,-87 ,-50 , 100, 0  , 3  , 0  , 0	;m5
	.db  100,-87 , 50 ,-100, 0  , 3  , 0  , 0	;m6
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m7
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m8

	;    thr roll pitch yaw offs flags unused
	.db  100, 50 , 87 , 100, 0  , 3  , 0  , 0	;m1
	.db  100, 100, 0  ,-100, 0  , 3  , 0  , 0	;m2
	.db  100, 50 ,-87 , 100, 0  , 3  , 0  , 0	;m3
	.db  100,-50 ,-87 ,-100, 0  , 3  , 0  , 0	;m4
	.db  100,-100, 0  , 100, 0  , 3  , 0  , 0	;m5
	.db  100,-50 , 87 ,-100, 0  , 3  , 0  , 0	;m6
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m7
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m8

	;    thr roll pitch yaw offs flags unused
	.db  100, 0  , 100, 100, 0  , 3  , 0  , 0	;m1
	.db  100, 71 , 71 ,-100, 0  , 3  , 0  , 0	;m2
	.db  100, 100, 0  , 100, 0  , 3  , 0  , 0	;m3
	.db  100, 71 ,-71 ,-100, 0  , 3  , 0  , 0	;m4
	.db  100, 0  ,-100, 100, 0  , 3  , 0  , 0	;m5
	.db  100,-71 ,-71 ,-100, 0  , 3  , 0  , 0	;m6
	.db  100,-100, 0  , 100, 0  , 3  , 0  , 0	;m7
	.db  100,-71 , 71 ,-100, 0  , 3  , 0  , 0	;m8

	;    thr roll pitch yaw offs flags unused
	.db  100, 38 , 92 , 100, 0  , 3  , 0  , 0	;m1
	.db  100, 92 , 38 ,-100, 0  , 3  , 0  , 0	;m2
	.db  100, 92 ,-38 , 100, 0  , 3  , 0  , 0	;m3
	.db  100, 38 ,-92 ,-100, 0  , 3  , 0  , 0	;m4
	.db  100,-38 ,-92 , 100, 0  , 3  , 0  , 0	;m5
	.db  100,-92 ,-38 ,-100, 0  , 3  , 0  , 0	;m6
	.db  100,-92 , 38 , 100, 0  , 3  , 0  , 0	;m7
	.db  100,-38 , 92 ,-100, 0  , 3  , 0  , 0	;m8

	;    thr roll pitch yaw offs flags unused
	.db  100, 71 , 71 , 100, 0  , 3  , 0  , 0	;m1
	.db  100, 71 , 0  ,-100, 0  , 3  , 0  , 0	;m2
	.db  100, 71 ,-71 , 100, 0  , 3  , 0  , 0	;m3
	.db  100,-71 ,-71 ,-100, 0  , 3  , 0  , 0	;m4
	.db  100,-71 , 0  , 100, 0  , 3  , 0  , 0	;m5
	.db  100,-71 , 71 ,-100, 0  , 3  , 0  , 0	;m6
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m7
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m8

	;    thr roll pitch yaw offs flags unused
	.db  100, 71 , 71 , 100, 0  , 3  , 0  , 0	;m1
	.db  100, 71 , 24 ,-100, 0  , 3  , 0  , 0	;m2
	.db  100, 71 ,-24 , 100, 0  , 3  , 0  , 0	;m3
	.db  100, 71 ,-71 ,-100, 0  , 3  , 0  , 0	;m4
	.db  100,-71 ,-71 , 100, 0  , 3  , 0  , 0	;m5
	.db  100,-71 ,-24 ,-100, 0  , 3  , 0  , 0	;m6
	.db  100,-71 , 24 , 100, 0  , 3  , 0  , 0	;m7
	.db  100,-71 , 71 ,-100, 0  , 3  , 0  , 0	;m8

	;    thr roll pitch yaw offs flags unused
	.db  100, 100, 71 , 100, 0  , 3  , 0  , 0	;m1
	.db  100, 71 , 0  ,-100, 0  , 3  , 0  , 0	;m2
	.db  100, 42 ,-71 , 100, 0  , 3  , 0  , 0	;m3
	.db  100,-42 ,-71 ,-100, 0  , 3  , 0  , 0	;m4
	.db  100,-71 , 0  , 100, 0  , 3  , 0  , 0	;m5
	.db  100,-100, 71 ,-100, 0  , 3  , 0  , 0	;m6
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m7
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m8

	;    thr roll pitch yaw offs flags unused
	.db  100, 100, 71 , 100, 0  , 3  , 0  , 0	;m1
	.db  100, 81 , 24 ,-100, 0  , 3  , 0  , 0	;m2
	.db  100, 61 ,-24 , 100, 0  , 3  , 0  , 0	;m3
	.db  100, 42 ,-71 ,-100, 0  , 3  , 0  , 0	;m4
	.db  100,-42 ,-71 , 100, 0  , 3  , 0  , 0	;m5
	.db  100,-61 ,-24 ,-100, 0  , 3  , 0  , 0	;m6
	.db  100,-81 , 24 , 100, 0  , 3  , 0  , 0	;m7
	.db  100,-100, 71 ,-100, 0  , 3  , 0  , 0	;m8

/*
	;    thr roll pitch yaw offs flags unused
	.db  100, 0  , 0  , 0  , 0  , 3  , 0  , 0	;m1
	.db  0  , 100, 0  , 0  , 50 , 0  , 0  , 0	;m2
	.db  0  , 0  , 100, 0  , 50 , 0  , 0  , 0	;m3
	.db  0  , 0  , 0  , 100, 50 , 0  , 0  , 0	;m4
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m5
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m6
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m7
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m8

	;    thr roll pitch yaw offs flags unused
	.db  100, 0  , 0  , 0  , 0  , 3  , 0  , 0	;m1
	.db  0  , 100, 0  , 0  , 50 , 0  , 0  , 0	;m2
	.db  0  , 100, 0  , 0  , 50 , 0  , 0  , 0	;m3
	.db  0  , 0  , 100, 0  , 50 , 0  , 0  , 0	;m4
	.db  0  , 0  , 0  , 100, 50 , 0  , 0  , 0	;m5
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m6
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m7
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m8

	;    thr roll pitch yaw offs flags unused
	.db  100, 0  , 0  , 0  , 0  , 3  , 0  , 0	;m1
	.db  0  , 50 , 50 , 0  , 50 , 0  , 0  , 0	;m2
	.db  0  , 50 ,-50 , 0  , 50 , 0  , 0  , 0	;m3
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m4
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m5
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m6
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m7
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m8

*/
	;    thr roll pitch yaw offs flags unused
	.db  100,-71 , 71 , 100, 0  , 3  , 0  , 0	;m1
	.db  100, 71 , 71 ,-100, 0  , 3  , 0  , 0	;m2
	.db  100, 0  ,-100, 100, 0  , 3  , 0  , 0	;m3
	.db  100, 0  ,-100,-100, 0  , 3  , 0  , 0	;m4
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m5
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m6
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m7
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m8

	;    thr roll pitch yaw offs flags unused
	.db  100,-71 , 71 , 0  , 0  , 3  , 0  , 0	;m1
	.db  100, 71 , 71 ,-1  , 0  , 3  , 0  , 0	;m2
	.db  120, 0  ,-90 , 100, 0  , 3  , 0  , 0	;m3
	.db  120, 0  ,-90 ,-100, 0  , 3  , 0  , 0	;m4
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m5
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m6
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m7
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m8

/*
	;    thr roll pitch yaw offs flags unused
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m1
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m2
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m3
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m4
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m5
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m6
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m7
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m8

*/


