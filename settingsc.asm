
.def Item		= r17



SettingsC:

sux11:	call LcdClear

	ldz eeAutoDisarm
	call GetEeVariable8 
	brflagtrue xl, sux11a		;Auto Disarm is On
	
	ldz eeflagLMA
	call GetEeVariable8 
	brflagfalse xl, sux11a		;LMA is Off

	setflagtrue xl				;LMA is On so set Auto Disarm On
	ldz eeAutoDisarm
	call StoreEeVariable8

sux11a:
	lrv PixelType, 1
	lrv FontSelector, f6x8

	lrv X1,0		;self level
	lrv Y1,1
	mPrintString sux1
	ldz eeSelfLevelType
	call GetEeVariable8 
	sts SelfLevelType, xl

	cpi xl, 0
	brne sux11a1
	mPrintString sux17
	rjmp sux19
sux11a1:
	cpi xl, 1
	brne sux11a2
	mPrintString sux16
	rjmp sux19

sux11a2:	
	cpi xl, 2
	brne sux11a3
	mPrintString sux56
	rjmp sux19

sux11a3:	
	mPrintString sux57

sux19:
	lrv X1,0		;Link Roll Pitch
	lrv Y1,10
	mPrintString sux4
	call GetEeVariable8 
	brflagfalse xl, sux30
	mPrintString sux28
	rjmp sux32
sux30:	mPrintString sux29
sux32:

	lrv X1,0		;Auto disarm
	lrv Y1,19
	mPrintString sux5
	call GetEeVariable8 
	brflagfalse xl, sux33
	mPrintString sux28
	rjmp sux34
sux33:	mPrintString sux29
sux34:

	lrv X1,0		;Receiver Type
	lrv Y1,28
	mPrintString sux35
	call GetEeVariable8 
;	andi xl, 0x03
	sts RxType, xl
	cpi xl, 0
	brne sux34a
	mPrintString sux50
	rjmp sux37
sux34a:
	cpi xl, 1
	brne sux34b
	mPrintString sux51
	rjmp sux36e
sux34b:
	cpi xl, 2
	brne sux34c
	mPrintString sux52
	rjmp sux36e
sux34c:
	cpi xl, 3
	brne sux34d
	mPrintString sux53
	rjmp sux36e
sux34d:
	mPrintString sux54
sux36e:
	lrv X1,0		;if RxType >0 set Channel Map = Yes on display
	lrv Y1,37
	mPrintString sux35b
	mPrintString sux28
	rjmp sux39

sux37:
	lrv X1,0		;Channel Map
	lrv Y1,37
	mPrintString sux35b
	ldz eeChannelMap
	call GetEeVariable8 
	brflagfalse xl, sux38
	mPrintString sux28
	rjmp sux39
sux38:	mPrintString sux29

sux39:
	lrv X1,0		;Lost Model Alarm
	lrv Y1,46
	mPrintString sux35a
	ldz eeflagLMA
	call GetEeVariable8 
	brflagfalse xl, sux40
	mPrintString sux28
	rjmp sux41
sux40:	mPrintString sux29

sux41:

	;footer
	lrv X1, 0
	lrv Y1, 57
	mPrintString sux6

	;print selector
	ldzarray sux7*2, 4, Item
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
	brne sux8

	ldz eeLinkRollPitch			; RC911 bug fix
	call ReadEeprom
	sts flagRollPitchLink, t

	ldz eeRxType
	call GetEeVariable8 
	cpi xl, 0 
	breq sux11b					;Std receiver selected

	ldz eeChannelMap
	call GetEeVariable8 
	brflagfalse xl, sux11b		;Channel Map is off (looks odd but is correct as this channel map is for swapping rx inputs)

	setflagfalse xl				;Sat DSM2/X, SBus or CPPM is On so set Channel Map Off (this is Std channel map or we end up applying it twice to a serial / CPPM rx)
	ldz eeChannelMap
	call StoreEeVariable8

sux11b:
	ldz eeChannelMap			
	call ReadEeprom
	sts flagChannelMap, t	

	ret	

sux8:	cpi t, 0x04		;PREV?
	brne sux9	
	dec Item
	brpl sux10
	ldi Item, 5
sux10:	rjmp sux11	

sux9:	cpi t, 0x02		;NEXT?
	brne sux12
	inc Item
	cpi item, 6
	brne sux13
	ldi Item, 0
sux13:	rjmp sux11	

sux12:	cpi t, 0x01		;CHANGE?
	brne sux14

sux12a:
	cpi Item,3
	brne sux12b
	lds		t,RXType
	inc		t
	cpi		t,5
	brlt    sux12d
	ldi		t,0
sux12d:
	sts		RXType,t
	mov		xl,t
	ldz eeRxType
	call StoreEeVariable8
	rjmp sux11

sux12b:

	cpi Item,0
	brne sux12e
	lds		t,SelfLevelType
	inc		t
	cpi		t,4
	brlt    sux12c
	ldi		t,0
sux12c:
	sts		SelfLevelType,t
	mov		xl,t
	ldz eeSelfLevelType
	call StoreEeVariable8
	rjmp sux11

sux12e:
	ldzarray eeSelfLevelType, 1, Item	;toggle flag
	call GetEeVariable8
	ldi t, 0x80
	eor xl, t
	ldzarray eeSelfLevelType, 1, Item
	call StoreEeVariable8

sux14:	rjmp sux11




sux1:	.db "Self-Level  : ", 0, 0
sux4:	.db "Link Roll Pitch: ", 0
sux5:	.db "Auto Disarm : ", 0, 0
sux35:	.db "Receiver    : ", 0, 0
sux35b: .db "Channel Map : ", 0, 0
sux35a: .db "Lost Model Alarm: ",0,0
sux6:	.db "BACK PREV NEXT CHANGE", 0
sux15:	.db "On",0, 0
sux16:	.db "Stick",0
sux17:	.db "AUX",0
sux56:  .db "Always",0,0
sux57:  .db "None",0,0
sux28:	.db "Yes",0
sux29:	.db "No",0,0

sux50:  .db "Std",0
sux51:  .db "CPPM",0,0
sux52:  .db "DSM2",0,0
sux53:  .db "DSMX",0,0
sux54:  .db "SBus",0,0


sux7:	.db 83, 0, 121, 9
	.db 100, 9, 122, 18
	.db 83, 18, 104, 27
	.db 83, 27, 109, 36
	.db 83, 36, 104, 45
	.db 106, 45, 127, 54


.undef Item

