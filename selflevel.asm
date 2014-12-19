


.def Item		= r17

SelflevelSettings:


sqz11:	call LcdClear
	
	lrv PixelType, 1
	lrv FontSelector, f6x8

	lrv X1,0
	lrv Y1,1
	mPrintString sqz1
	ldz  eeSelflevelPgain
	call GetEeVariable16 
 	call Print16Signed 

	lrv X1,0
	rvadd Y1, 9
	mPrintString sqz2
	call GetEeVariable16 
 	call Print16Signed 

	lrv X1,0
	rvadd Y1, 12
	mPrintString sqz3
	call GetEeVariable16 
 	call Print16Signed 

	lrv X1,0
	rvadd Y1, 9
	mPrintString sqz4
	call GetEeVariable16 
 	call Print16Signed 


	;footer
	lrv X1, 0
	lrv Y1, 57
	mPrintString sqz6

	;print selector
	ldzarray sqz7*2, 4, Item
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
	brne sqz8
	ret	

sqz8:	cpi t, 0x04		;PREV?
	brne sqz9	
	dec Item
	brpl sqz10
	ldi Item, 3
sqz10:	rjmp sqz11	

sqz9:	cpi t, 0x02		;NEXT?
	brne sqz12
	inc Item
	cpi item, 4
	brne sqz13
	ldi Item, 0
sqz13:	rjmp sqz11	

sqz12:	cpi t, 0x01		;CHANGE?
	brne sqz14

	ldzarray eeSelflevelPgain, 2, Item
	push zl
	push zh
	call GetEeVariable16
	ldzarray sqz15*2, 4, Item
	lpm yl, Z+
	lpm yh, Z+
	lpm r0, Z+
	lpm r1, Z+
	mov zl, r0
	mov zh, r1
	call NumberEdit
	mov xl, r0
	mov xh, r1
	pop zh
	pop zl
	call StoreEeVariable16

sqz14:	rjmp sqz11




sqz1:	.db "P Gain  :", 0
sqz2:	.db "P limit :", 0
sqz3:	.db "ACC Trim Roll  :", 0, 0
sqz4:	.db "ACC Trim Pitch :", 0, 0
sqz6:	.db "BACK PREV NEXT CHANGE", 0


sqz7:	.db 53, 0, 79, 9
	.db 53, 9, 79, 18
	.db 95, 21, 127, 30
	.db 95, 30, 127, 39
	

sqz15:	.dw 0, 32000
	.dw 0, 32000
	.dw -1000, 1000
	.dw -1000, 1000


.undef Item

