
FactoryReset:
	call LcdClear		

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

	cpi t, 0x01		;YES
	breq fac1

	ret			;CANCEL


fac1:	clr t			;destroy first byte in EEPROM
	ldz 0
	call WriteEepromP1

	jmp reset		;restart





