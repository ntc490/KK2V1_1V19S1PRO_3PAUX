
.def Item		= r17

.def Channel		= r18
.def MixvalueIndex	= r19

MixerEditor:

	lds	t, Status		; clear Status bit 3 used for checking motor layout valid
	andi t, 0x07
	sts	Status, t

	ldi Item, 0
	clr Channel	


med1:	call LcdClear
	
	lrv PixelType, 1
	lrv FontSelector, f6x8

	;channel

	lrv X1,102
	lrv Y1,1

	mPrintString med7

	mov xl, channel
	inc xl
	clr xh
	call Print16Signed 


	;throttle

	lrv X1, 0	
	lrv Y1, 1
	mPrintString med2
	ldi MixvalueIndex,0
	rcall GetMixervalue
	rcall extend
	call Print16Signed 

	;Aileron
	lrv X1, 0	
	rvadd Y1, 9
	mPrintString med3
	ldi MixvalueIndex,1
	rcall GetMixervalue
	rcall extend
	call Print16Signed 

	;Elevator
	lrv X1, 0	
	rvadd Y1, 9
	mPrintString med4
	ldi MixvalueIndex,2
	rcall GetMixervalue
	rcall extend
	call Print16Signed 

	;Rudder
	lrv X1, 0	
	rvadd Y1, 9
	mPrintString med5
	ldi MixvalueIndex,3
	rcall GetMixervalue
	rcall extend
	call Print16Signed 

	;Offset 
	lrv X1, 0	
	rvadd Y1, 9
	mPrintString med6
	ldi MixvalueIndex,4
	rcall GetMixervalue
	rcall extend
	call Print16Signed 

	;Type
	lrv X1, 0	
	rvadd Y1, 9
	mPrintString med13
	ldi MixvalueIndex,5
	rcall GetMixervalue
	push t
	sbrs t, bMixerFlagType
	rjmp med20
	mPrintString med17
	rjmp med21
med20:	mPrintString med16
med21:

	;Rate
	lrv X1, 69	
	mPrintString med14
	pop t
	sbrs t, bMixerFlagRate
	rjmp med22
	mPrintString med18
	rjmp med23
med22:	mPrintString med19
med23:


	;footer
	lrv X1, 0
	lrv Y1, 57
	mPrintString med15


	;print selector
	ldzarray selx*2, 4, Item
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
	brne med30
	ret	

med30:	cpi t, 0x04		;PREV?
	brne med31	
	dec Item
	andi item, 0x07
	rjmp med1	

med31:	cpi t, 0x02		;NEXT?
	brne med32
	inc Item
	andi item, 0x07
	rjmp med1	

med32:	cpi t, 0x01		;CHANGE?
	brne med33

	cpi Item, 0		;change channel
	brne med40
	inc Channel
	andi Channel, 0x07	
	rjmp med1

med40:	cpi Item, 1		;edit mixer value
	brlo med41
	cpi Item, 6
	brsh med41
	mov MixvalueIndex, Item
	dec MixvalueIndex
	rcall GetMixervalue
	rcall extend
	ldy -127		;lower limit
	ldz 127			;upper limit
	call NumberEdit
	mov t, r0
	rcall StoreMixervalue
	rjmp med1

med41:	cpi Item, 6		;toggle Type
	brne med42
	ldi MixvalueIndex,5
	rcall GetMixervalue
	ldi xl, 1 << bMixerFlagType
	eor t, xl
	sbrc t, bMixerFlagType	;Set rate to high if selected type is ESC
	ori t, 1 << bMixerFlagRate
	rcall StoreMixervalue
	rjmp med1

med42:	cpi Item, 7		;toggle Rate
	brne med33
	ldi MixvalueIndex,5
	rcall GetMixervalue
	ldi xl, 1 << bMixerFlagRate
	eor t, xl
	sbrc t, bMixerFlagType	;Set rate to high if selected type is ESC
	ori t, 1 << bMixerFlagRate
	rcall StoreMixervalue
	rjmp med1

med33:	rjmp med1




selx:	.db 120,0,127,10
	.db 58,9*0,86,9*1
	.db 58,9*1,86,9*2
	.db 58,9*2,86,9*3
	.db 58,9*3,86,9*4
	.db 58,9*4,86,9*5
	.db 29,9*5,60,9*6
	.db 99,9*5,124,9*6






med2:	.db "Throttle: ",0,0
med3:	.db "Aileron : ",0,0
med4:	.db "Elevator: ",0,0
med5:	.db "Rudder  : ",0,0
med6:	.db "Offset  : ",0,0
med7:	.db "CH:",0
med13:	.db "Type:",0
med14:	.db "Rate:",0
med15:	.db "BACK PREV NEXT CHANGE",0
med16:	.db "Servo",0
med17:	.db "ESC",0
med18:	.db "High",0,0
med19:	.db "Low",0





GetMixervalue:
	rcall mixc
	jmp ReadEeprom


StoreMixervalue:
	push t
	rcall mixc
	pop t
	jmp WriteEeprom




mixc:	ldz EeMixerTable	;Z = *EeMixerTable + Channel * 8 + MixvalueIndex
	mov t, Channel
	lsl t
	lsl t
	lsl t
	add zl, t
	clr t
	adc zh, t
	add zl, MixvalueIndex
	adc zh, t
	
	ret


extend:	mov xl, t		;extend sign
	clr xh
	tst xl
	brpl med12
	ser xh
med12:	ret
	

.undef Item
.undef Channel
.undef MixvalueIndex

