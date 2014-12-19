
.def Item		= r17



SettingsB:

stt11:	call LcdClear
	
	lrv PixelType, 1
	lrv FontSelector, f6x8

	lrv X1,0
	lrv Y1,1
	mPrintString stt1
	ldz eeEscLowLimit
	call GetEeVariable16 
 	call Print16Signed 

	lrv X1,0
	lrv Y1,10
	mPrintString stt3
	call GetEeVariable16 
 	call Print16Signed 

	lrv X1,0
	lrv Y1,19
	mPrintString stt4
	call GetEeVariable16 
 	call Print16Signed 

	lrv X1,0
	lrv Y1,28
	mPrintString stt5
	call GetEeVariable16 
 	call Print16Signed 

	lrv X1,0
	lrv Y1,37
	mPrintString stt16
	call GetEeVariable16 
 	call Print16Signed 

	lrv X1,0
	lrv Y1,46
	mPrintString stt17
	call GetEeVariable16 
 	call Print16Signed 

	;footer
	lrv X1, 0
	lrv Y1, 57
	mPrintString stt6

	;print selector
	ldzarray stt7*2, 4, Item
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
	brne stt8
	ret	

stt8:	cpi t, 0x04		;PREV?
	brne stt9	
	dec Item
	brpl stt10
	ldi Item, 5
stt10:	rjmp stt11	

stt9:	cpi t, 0x02		;NEXT?
	brne stt12
	inc Item
	cpi item, 6
	brne stt13
	ldi Item, 0
stt13:	rjmp stt11	

stt12:	cpi t, 0x01		;CHANGE?
	brne stt14

	ldzarray eeEscLowLimit, 2, Item
	push zl
	push zh
	call GetEeVariable16
	ldzarray stt15*2, 4, Item
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

stt14:	rjmp stt11




stt1:	.db "Minimum throttle:", 0
stt3:	.db "Height Dampening:", 0
stt4:	.db "Height D. Limit :", 0
stt5:	.db "Alarm 1/10 volts:", 0
stt16:	.db "Servo filter    :", 0
stt17:	.db "Acc SW filter   :", 0

stt6:	.db "BACK PREV NEXT CHANGE", 0


stt7:	.db 101, 0, 127, 9	;hilight screen coordinates
	.db 101, 9, 127, 18
	.db 101, 18, 127, 27
	.db 101, 27, 127, 36
	.db 101, 36, 127, 45
	.db 101, 45, 127, 54

stt15:	.dw 0, 20		;edit number lower and upper limits
	.dw 0, 500
	.dw 0, 30
	.dw 0, 32000
	.dw 0, 100
	.dw 4, 64




.undef Item

