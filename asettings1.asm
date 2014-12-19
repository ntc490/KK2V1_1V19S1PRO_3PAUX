.def Item		= r17

AdvancedSettings1:

asux11:	call LcdClear
	
	lrv PixelType, 1
	lrv FontSelector, f6x8

	lrv X1,0		;board offset
	lrv Y1,1
	mPrintString asux1
	ldz eeBoardOffset
	call GetEeVariable8 
	cpi xl,0
	brne asux18a
	mPrintString asux43
	rjmp asux19
asux18a:	
	cpi xl,1
	brne asux18b
	mPrintString asux25
	rjmp asux19
asux18b:
	cpi xl,2
	brne asux18c
	mPrintString asux26
	rjmp asux19	
asux18c:
	cpi xl,3
	brne asux18d
	mPrintString asux27
	rjmp asux19	
asux18d:
	cpi xl,4
	brne asux18e
	mPrintString asux42
	rjmp asux19	
asux18e:
	mPrintString asux39



asux19:
	lrv X1,0		;Spin on Arm
	lrv Y1,10
	mPrintString asux4
	call GetEeVariable8 
	brflagfalse xl, asux30
	mPrintString asux28
	rjmp asux32
asux30:	mPrintString asux29
asux32:

	lrv X1,0		;SS Gimbal
	lrv Y1,19
	mPrintString asux5
	call GetEeVariable8 
	brflagfalse xl, asux33
	mPrintString asux28
	rjmp asux34
asux33:	mPrintString asux29
asux34:

	lrv X1,0		;TX Gimbal Control
	lrv Y1,28
	mPrintString asux5a
	call GetEeVariable8 
	cpi xl,0
	brne asux35a
	mPrintString asux29
	rjmp asux36
asux35a:	
	cpi xl,1
	brne asux35b
	mPrintString asux40
	rjmp asux36
asux35b:
	mPrintString asux41

asux36:

	lrv X1,0		;Alt Safe Screen
	lrv Y1,37
	mPrintString asux5b
	call GetEeVariable8 
	brflagfalse xl, asux37
	mPrintString asux28
	rjmp asux38
asux37:	mPrintString asux29

asux38:

	lrv X1,0		;BattAccTrim
	lrv Y1,46
	mPrintString asux5c
	call GetEeVariable8 
	call extend
	call Print16Signed 

	;footer
	lrv X1, 0
	lrv Y1, 57
	mPrintString asux6

	;print selector
	ldzarray asux7*2, 4, Item
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
	brne asux8
	ret	

asux8:	cpi t, 0x04		;PREV?
	brne asux9	
	dec Item
	brpl asux10
	ldi Item, 5
asux10:	rjmp asux11	

asux9:	cpi t, 0x02		;NEXT?
	brne asux12
	inc Item
	cpi item, 6
	brne asux13
	ldi Item, 0
asux13:	rjmp asux11	

asux12:	cpi t, 0x01		;CHANGE?
	brne asux14

	cpi Item,0
	brne asux12a
	lds		t,BoardOffset
	inc		t
	cpi		t,6
	brlt    asux12b
	ldi		t,0
asux12b:
	sts		BoardOffset,t
	mov		xl,t
	ldz eeBoardOffset
	call StoreEeVariable8
	rjmp asux11

asux14: rjmp asux11

asux12a:
	cpi Item,3
	brne asux12c
	lds		t,TXGimbal
	inc		t
	andi	t,0b00000011
	cpi		t,0b00000011
	brne    asux12d
	ldi		t,0
asux12d:
	sts		TXGimbal,t
	mov		xl,t
	ldz eeTXGimbal
	call StoreEeVariable8
	rjmp asux11
	
asux12c:
	cpi Item,5
	brne asux12e
	ldz eeBattAdcTrim
	call GetEeVariable16 
	ldy -6		;lower limit
	ldz 6			;upper limit
	call NumberEdit
	mov xl, r0
	mov xh, r1
	ldz eeBattAdcTrim
	call StoreEeVariable16
	rjmp asux11

asux12e:
	ldzarray eeBoardOffset, 1, Item	;toggle flag
	call GetEeVariable8
	ldi t, 0x80
	eor xl, t
	ldzarray eeBoardOffset, 1, Item
	call StoreEeVariable8
	
	rjmp asux11




asux1:	.db "Board Offset   : ", 0
asux4:	.db "Spin on Arm    : ", 0
asux5:	.db "SS Gimbal      : ", 0
asux5a: .db "Gimbal Control : ", 0
asux5b: .db "Alt Safe Screen: ", 0
asux5c: .db "Batt Volt Trim : ", 0
asux6:	.db "BACK PREV NEXT CHANGE", 0
asux28:	.db "Yes",0
asux29:	.db "No",0,0
asux25:	.db "-45",0
asux26:	.db "0",0
asux27:	.db "+45",0
asux39: .db "180",0
asux40: .db "Aux",0
asux41: .db "6&7",0
asux42: .db "+90",0
asux43: .db "-90",0




asux7:	.db 100, 0, 122, 9
	.db 100, 9, 122, 18
	.db 100, 18, 122, 27
	.db 100, 27, 122, 36
	.db 100, 36, 122, 45
	.db 100, 45, 122, 54

.undef Item

