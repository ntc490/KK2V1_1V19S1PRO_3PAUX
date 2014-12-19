






.def Item		= r17
.def Axis		= r18
.def ParameterIndex	= r19

PiEditor:


	clr Item
	clr Axis


pie1:	call LcdClear
	
	lrv PixelType, 1
	lrv FontSelector, f6x8

	;Axis

	lrv X1,0
	lrv Y1,1
	mPrintString pie2

pie62:	mov xl, Axis
	dec xl
	brpl pie11
	mPrintString pie7
	rjmp pie13
		
pie11:	dec xl
	brpl pie12
	mPrintString pie8
	rjmp pie13
		
pie12:	mPrintString pie9

pie13:
	;P Gain
	lrv X1, 0	
	lrv Y1, 14
	mPrintString pie3
	ldi ParameterIndex,0
	rcall GetParameter
	call Print16Signed 

	;P Limit
	lrv X1, 0	
	rvadd Y1, 9 
	mPrintString pie4
	ldi ParameterIndex,1
	rcall GetParameter
	call Print16Signed 

	;I Gain
	lrv X1, 0	
	rvadd Y1, 11 
	mPrintString pie5
	ldi ParameterIndex,2
	rcall GetParameter
	call Print16Signed 

	;I Limit
	lrv X1, 0	
	rvadd Y1, 9 
	mPrintString pie6
	ldi ParameterIndex,3
	rcall GetParameter
	call Print16Signed 

	;footer
	lrv X1, 0
	lrv Y1, 57
	mPrintString pie10

	;print selector
	ldzarray pie50*2, 4, Item
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
	brne Pie30
	ret	

pie30:	cpi t, 0x04		;PREV?
	brne pie31	
	dec Item
	brpl pie34
	ldi Item, 4
pie34:	rjmp pie1	

pie31:	cpi t, 0x02		;NEXT?
	brne pie32
	inc Item
	cpi item, 5
	brne pie35
	ldi Item, 0
pie35:	rjmp pie1	

pie32:	cpi t, 0x01		;CHANGE?
	brne pie63

	cpi Item, 0		;change Axis
	brne pie40
	inc Axis
	cpi Axis, 3
	brne pie33
	clr Axis	
pie33:	rjmp pie1

pie40:	mov ParameterIndex, Item;Edit parameter
	dec ParameterIndex
	rcall GetParameter
	ldy 0			;lower limit
	ldz 32000		;upper limit
	call NumberEdit
	mov xl, r0
	mov xh, r1
	rcall StoreParameter
	cpi Axis, 2
	breq pie63
	rvbrflagfalse flagRollPitchLink, pie63
	push Axis
	ldi t, 1		;store both roll and pitch if flagRollPitchLink == true
	eor Axis, t
	rcall StoreParameter
	pop Axis
pie63:	rjmp pie1

pie50:	.db 29,0,127,10
	.db 52,13+9*0,86,13+9*1
	.db 52,13+9*1,86,13+9*2
	.db 52,15+9*2,86,15+9*3
	.db 52,15+9*3,86,15+9*4

pie2:	.db "Axis:",0
pie3:	.db "P Gain : ",0
pie4:	.db "P Limit: ",0
pie5:	.db "I Gain : ",0
pie6:	.db "I Limit: ",0
pie7:	.db "Roll (Aileron)",0,0
pie8:	.db "Pitch (Elevator)",0,0
pie9:	.db "Yaw (Rudder)",0,0
pie10:	.db "BACK PREV NEXT CHANGE",0

GetParameter:
	rcall paradd
	call ReadEeprom
	mov xl, t
	adiw z, 1
	call ReadEeprom
	mov xh, t
	ret

StoreParameter:
	rcall paradd
	mov t, xl
	call WriteEeprom
	adiw z, 1
	mov t, xh
	call WriteEeprom
	ret

paradd:	ldz EeParameterTable	;Z = *EeParameterTable + Axis * 8 + ParameterIndex * 2
	mov t, Axis
	lsl t
	lsl t
	lsl t
	add zl, t
	clr t
	adc zh, t
	mov t, ParameterIndex
	lsl t
	add zl, t
	clr t
	adc zh, t
	
	ret
	


.undef Item
.undef Axis
.undef ParameterIndex
