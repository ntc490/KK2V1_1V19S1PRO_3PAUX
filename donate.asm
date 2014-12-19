;  The Merlin Centre is a centre of excellence in Cornwall, England, providing a range of expert care, 
;  support and therapies to improve the lives of those with Multiple Sclerosis and other neurological conditions, 
;  their families and their carers.

;  The Merlin MS Centre UK Charity Registration No: 1093691




Donate:
	call LcdClear
	
	lrv PixelType, 1
	lrv FontSelector, f6x8

	lrv X1, 0
	lrv Y1, 0
	mPrintString don11

	lrv X1, 0
	lrv Y1, 9
	mPrintString don12

	lrv X1, 0
	lrv Y1, 18
	mPrintString don13

	lrv X1, 0
	lrv Y1, 27
	mPrintString don14

	lrv X1, 0
	lrv Y1, 36
	mPrintString don15

	lrv X1, 0
	lrv Y1, 54
	mPrintString don16

	call LcdUpdate

	ldx 2000
	call WaitXms

	call getbuttonsblocking
	ret


don11: .db "Please support my",0
don12: .db "charity by making a",0
don13: .db "donation to show your",0
don14: .db "appreciation for all",0,0
don15: .db "my hard work.",0
don16: .db "merlinmscentre.org.uk",0
