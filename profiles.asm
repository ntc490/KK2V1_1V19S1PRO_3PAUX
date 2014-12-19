
.def Item		= r17

Profiles:

prof1:
	call	LcdClear

	lrv X1, 0
	lrv Y1, 0
	lrv FontSelector, f6x8
	mPrintString prof30
	ldz eeSwitchSSPI
	call ReadEepromP1
	sts flagSwitchSSPI, t
	rvbrflagtrue flagSwitchSSPI, prof2
	ldz eeProfileP1
	call GetEeVariable8P1
	brflagtrue xl, prof2
	mPrintString prof41
	rjmp prof3
prof2:
	mPrintString prof40

prof3:
	lrv X1, 0
	lrv Y1, 9
	mPrintString prof30a	
	ldz eeSwitchSSPI
	call GetEeVariable8P1
	brflagfalse xl, prof4
	mPrintString prof42
	rjmp prof5
prof4:
	mPrintString prof43
	
prof5:
	lrv X1, 0
	lrv Y1, 18
	mPrintString prof31
	lrv X1, 0
	lrv Y1, 27
	mPrintString prof32
	lrv X1, 0
	lrv Y1, 36
	mPrintString prof33
	lrv X1, 0
	lrv Y1, 45
	mPrintString prof34

	;footer
	lrv X1, 0
	lrv Y1, 57
	mPrintString prof39

	;print selector
	ldzarray prof50*2, 4, Item
	lpm t, z+
	sts X1, t
	lpm t, z+
	sts Y1, t
	lpm t, z+
	sts X2, t
	lpm t, z
	sts Y2, t
	lrv PixelType, 0
	call HilightRectangle

	call LcdUpdate

	call GetButtonsBlocking

	cpi t, 0x08		;BACK?
	brne prof8
	call flightinit
	clr t
	sts Status,t	;reset status
	b16ldi CheckRxDelay, 400 * 10 ;reset receiver check delay
	ret	

prof8:	cpi t, 0x04		;PREV?
	brne prof9	
	dec Item
	brpl prof10
	ldi Item, 5
prof10:	rjmp prof1	

prof9:	cpi t, 0x02		;NEXT?
	brne prof12
	inc Item
	cpi item, 6
	brne prof13
	ldi Item, 0
prof13:	rjmp prof1	

prof12:	cpi t, 0x01		;CHANGE?
	brne prof14

	cpi item, 2
	brge prof15

	ldzarray eeProfileP1, 1, Item	;toggle flag
	call GetEeVariable8P1
	ldi t, 0x80
	eor xl, t
	ldzarray eeProfileP1, 1, Item
	call StoreEeVariable8P1

prof14:	rjmp prof1

prof15:

	call LcdClear		

	lrv PixelType, 1
	lrv FontSelector, f6x8

	lrv X1, 20
	lrv Y1, 25
	mPrintString prof36	;Print "Are you sure?"

	;footer
	lrv X1, 0
	lrv Y1, 57
	mPrintString prof37

	call LcdUpdate

	call GetButtonsBlocking

	cpi t, 0x02		;Yes
	breq prof20
	rjmp prof1		;no

prof20:
	cpi item, 0x03
	brge prof21
	rvsetflagtrue  flagProfileP1	    ;Reset P1
	call P1P2Reset
	call flightinit
	rjmp prof1
prof21:
	cpi item, 0x04
	brge prof22
	rvsetflagfalse  flagProfileP1	    ;Reset P2
	call P1P2Reset
	call flightinit
	rjmp prof1
prof22:
	cpi item, 0x05
	brge prof25

	call LcdClear
	call LcdUpdate
	ldx 0x3ff
	ldy 0x400
	ldz 0
	rjmp prof26

prof25:
	call LcdClear
	call LcdUpdate
	ldx 0x3ff
	ldz 0x400
	ldy 0
prof26:	
	push zh
	push zl
	call ReadEepromP1
	movw z, y
	call WriteEepromP1
	pop zl
	pop zh
	adiw y, 1
	adiw z, 1
	sbiw x, 1
	brpl prof26
	rjmp prof1

prof30: .db "Current Profile : ",0, 0
prof30a:.db "Switch SS & PI  : ",0, 0
prof31: .db "Reset Profile 1 : No",0, 0
prof32: .db "Reset Profile 2 : No",0, 0
prof33: .db "Copy  P1 to P2  : No",0, 0
prof34: .db "Copy  P2 to P1  : No",0, 0

prof36:	.db "Are you sure?", 0
prof37:	.db "CANCEL       YES",0, 0

prof39:	.db "BACK PREV NEXT CHANGE", 0

prof40:	.db "P1",0,0
prof41:	.db "P2",0,0
prof42: .db "Yes",0
prof43: .db "No",0,0

prof50:	.db 107, 0, 127, 9
	    .db 107, 9, 127, 18
		.db 107, 18, 127, 27	
		.db 107, 27, 127, 36
		.db 107, 36, 127, 45  
		.db 107, 45, 127, 54 

.undef Item