.def Item		= r17

EndPointLimits:

	call LcdClear

	lrv PixelType, 1
	lrv FontSelector, f6x8

	lrv X1,0
	lrv Y1,5
	mPrintString epl40

	lrv X1,0
	lrv Y1,14
	mPrintString epl42
	ldz eeOut1Low
	call GetEeVariable16 
 	call Print16Signed

	lrv X1,41
	call GetEeVariable16 
 	call Print16Signed

	lrv X1,0
	lrv Y1,23
	mPrintString epl43
	call GetEeVariable16 
 	call Print16Signed 

	lrv X1,41
	call GetEeVariable16 
 	call Print16Signed

	lrv X1,0
	lrv Y1,32
	mPrintString epl44
	call GetEeVariable16 
 	call Print16Signed 

	lrv X1,41
	call GetEeVariable16 
 	call Print16Signed

	lrv X1,0
	lrv Y1,41
	mPrintString epl45
	call GetEeVariable16 
 	call Print16Signed 

	lrv X1,41
	call GetEeVariable16 
 	call Print16Signed

	lrv X1,66
	lrv Y1,14
	mPrintString epl46
	call GetEeVariable16 
 	call Print16Signed

	lrv X1,107
	call GetEeVariable16 
 	call Print16Signed

	lrv X1,66
	lrv Y1,23
	mPrintString epl47
	call GetEeVariable16 
 	call Print16Signed 

	lrv X1,107
	call GetEeVariable16 
 	call Print16Signed

	lrv X1,66
	lrv Y1,32
	mPrintString epl48
	call GetEeVariable16 
 	call Print16Signed 

	lrv X1,107
	call GetEeVariable16 
 	call Print16Signed

	lrv X1,66
	lrv Y1,41
	mPrintString epl49
	call GetEeVariable16 
 	call Print16Signed 

	lrv X1,107
	call GetEeVariable16 
 	call Print16Signed

	;footer
	lrv X1, 0
	lrv Y1, 57
	mPrintString epl56

	;print selector
	ldzarray epl57*2, 4, Item
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
	brne epl1
	ret	

epl1:
	cpi t, 0x04		;PREV?
	brne epl3	
	dec Item
	brpl epl2
	ldi Item, 15
epl2:	rjmp EndPointLimits	

epl3:	cpi t, 0x02		;NEXT?
	brne epl5
	inc Item
	cpi item, 16
	brne epl4
	ldi Item, 0
epl4:	rjmp EndPointLimits

epl5:	cpi t, 0x01		;CHANGE?
	brne epl6

	ldzarray eeOut1Low, 2, Item
	call GetEeVariable16
	ldy 0			;lower limit
	ldz 100			;upper limit
	call NumberEdit
	mov xl, r0
	mov xh, r1
	ldzarray eeOut1Low, 2, Item
	call StoreEeVariable16

epl6:	rjmp EndPointLimits

ret

;epl40: .db "End Point Limit", 0
epl40: .db "OP Min Max OP Min Max", 0
epl42: .db "1: ", 0
epl43: .db "2: ", 0
epl44: .db "3: ", 0
epl45: .db "4: ", 0
epl46: .db "5: ", 0
epl47: .db "6: ", 0
epl48: .db "7: ", 0
epl49: .db "8: ", 0
epl56: .db "BACK PREV NEXT CHANGE", 0

epl57: .db 17, 13, 37, 22
	   .db 40, 13, 60, 22
	   .db 17, 22, 37, 31
	   .db 40, 22, 60, 31
	   .db 17, 31, 37, 40
	   .db 40, 31, 60, 40
	   .db 17, 40, 37, 49
	   .db 40, 40, 60, 49

	   .db 83, 13, 103, 22
	   .db 106, 13, 126,22
	   .db 83, 22, 103, 31
	   .db 106, 22, 126,31
	   .db 83, 31, 103, 40
	   .db 106, 31, 126,40
	   .db 83, 40, 103, 49
	   .db 106, 40, 126,49

.undef Item