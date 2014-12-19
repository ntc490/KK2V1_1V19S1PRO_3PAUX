
.def Item		= r17



SettingsA:

set11:	call LcdClear
	
	lrv PixelType, 1
	lrv FontSelector, f6x8

	lrv X1,0
	lrv Y1,1
	mPrintString set1


	lrv X1,0
	lrv Y1,14
	mPrintString set2
	ldz eeStickScaleRoll
	call GetEeVariable16 
 	call Print16Signed 

	lrv X1,0
	lrv Y1,23
	mPrintString set3
	call GetEeVariable16 
 	call Print16Signed 

	lrv X1,0
	lrv Y1,32
	mPrintString set4
	call GetEeVariable16 
 	call Print16Signed 

	lrv X1,0
	lrv Y1,41
	mPrintString set5
	call GetEeVariable16 
 	call Print16Signed 




	;footer
	lrv X1, 0
	lrv Y1, 57
	mPrintString set6

	;print selector
	ldzarray set7*2, 4, Item
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
	brne set8
	call flightinit
	ret	

set8:	cpi t, 0x04		;PREV?
	brne set9	
	dec Item
	brpl set10
	ldi Item, 3
set10:	rjmp set11	

set9:	cpi t, 0x02		;NEXT?
	brne set12
	inc Item
	cpi item, 4
	brne set13
	ldi Item, 0
set13:	rjmp set11	

set12:	cpi t, 0x01		;CHANGE?
	brne set14

	ldzarray eeStickScaleRoll, 2, Item
	call GetEeVariable16
	ldy -32000			;lower limit
	ldz 32000		;upper limit
	call NumberEdit
	mov xl, r0
	mov xh, r1
	ldzarray eeStickScaleRoll, 2, Item
	call StoreEeVariable16

set14:	rjmp set11




set1:	.db "Stick Scaling", 0
set2:	.db "Roll (Ail)  :", 0
set3:	.db "Pitch (Ele) :", 0
set4:	.db "Yaw (Rud)   :", 0
set5:	.db "Throttle    :", 0
set6:	.db "BACK PREV NEXT CHANGE", 0


set7:	.db 77, 13, 110, 22
	.db 77, 22, 110, 31
	.db 77, 31, 110, 40
	.db 77, 40, 110, 49


.undef Item

