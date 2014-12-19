
ShowVersion:
	call LcdClear
	
	lrv PixelType, 1
	lrv FontSelector, f6x8

	lrv X1, 0
	lrv Y1, 9
	mPrintString sho1

	lrv X1, 0
	lrv Y1, 19
	mPrintString sho2

	lrv X1, 0
	lrv Y1, 29
	mPrintString sho3

	call LcdUpdate

	ldx 1000
	call WaitXms

	ret

; new routine to display the version information from the main menu.

Version: 
	call ShowVersion

	lrv X1, 0
	lrv Y1, 57
	mPrintString rxt18			;BACK button label

	call LcdUpdate

Ver1: call GetButtons
	cpi t, 0x08		;BACK?
	brne Ver1

	ret		

sho1:   .db "HW Ver 2.1.X",0,0
sho2:	.db "FW Ver 1.19S1 Pro +",0
sho3:	.db "Steveis",0
