
.def Item		= r17

MPUSettings:

	call	LcdClear

	lrv PixelType, 1
	lrv FontSelector, f6x8

	lrv X1,6		
	lrv Y1,4
	mPrintString warn1
	
	lrv X1,6	
	lrv Y1,13
	mPrintString warn2
	
	lrv X1,6
	lrv Y1,22
	mPrintString warn3

	;footer
	lrv X1, 0
	lrv Y1, 57
	mPrintString mpus10a

	Call	LcdUpdate

	call GetButtonsBlocking

	cpi t, 0x08		;BACK?
	brne warning1
	ret

warning1:
	cpi t, 0x01		;CONTINUE?
	breq warnover
	jmp MPUSettings

warnover:

	call	MPU_setup

	lds		t,gfs_sel
	andi	t,0b00011000
	lsr		t
	lsr		t
	lsr		t
	sts		gfs_sel,t

	lds		t,afs_sel
	andi	t,0b00011000
	lsr		t
	lsr		t
	lsr		t
	sts		afs_sel,t
	sts		afs_sel_in,t

	lds		t,dlpf
	andi	t,0b00000111
	sts		dlpf,t

	ldi		Item,0

mpus1:	call LcdClear

	lrv PixelType, 1
	lrv FontSelector, f6x8

	lrv X1,0		;gyro (deg/sec)
	lrv Y1,1
	mPrintString mpus7
	lrv X1,100
	lds	t,gfs_sel
	cpi t,0x00
	brne gfs1
	mPrintString gfs_sel0
gfs1:
	cpi t,0x01
	brne gfs2
	mPrintString gfs_sel1
gfs2:
	cpi t,0x02
	brne gfs3
	mPrintString gfs_sel2
gfs3:
	cpi t,0x03
	brne mpus2
	mPrintString gfs_sel3

mpus2:
	lrv X1,0		;Acc (+/- g)
	lrv Y1,10
	mPrintString mpus8
	lrv X1,100
	lds	t,afs_sel
	cpi t,0x00
	brne afs1
	mPrintString afs_sel0
afs1:
	cpi t,0x01
	brne afs2
	mPrintString afs_sel1
afs2:
	cpi t,0x02
	brne afs3
	mPrintString afs_sel2
afs3:
	cpi t,0x03
	brne mpus3
	mPrintString afs_sel3

mpus3:
	lrv X1,0		;DLPF (Hz) 
	lrv Y1,19
	mPrintString mpus9
	lrv X1,100
	lds	t,dlpf
	cpi t,0x00
	brne lpf1
	mPrintString dlpf0
lpf1:
	cpi t,0x01
	brne lpf2
	mPrintString dlpf1
lpf2:
	cpi t,0x02
	brne lpf3
	mPrintString dlpf2
lpf3:
	cpi t,0x03
	brne lpf4
	mPrintString dlpf3
lpf4:
	cpi t,0x04
	brne lpf5
	mPrintString dlpf4
lpf5:
	cpi t,0x05
	brne lpf6
	mPrintString dlpf5
lpf6:
	cpi t,0x06
	brne mpus4
	mPrintString dlpf6

mpus4:
	rvcp	afs_sel,afs_sel_in
	brne	mpus4a
	rjmp	mpus4b
mpus4a:
	lrv PixelType, 1
	lrv X1,15		
	lrv Y1,39
	mPrintString mpus10c
	lrv PixelType, 0
	lrv	X1,0
	lrv Y1,37
	lrv X2,127
	lrv Y2,48
	call HilightRectangle

mpus4b:
	;footer
	lrv PixelType, 1
	lrv X1, 0
	lrv Y1, 56
	mPrintString mpus10

	;print selector
	ldzarray mpus11*2, 4, Item
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
	brne mpus5
	rjmp mpus6		

mpus5:	cpi t, 0x04		;PREV?
	brne mpus5b	
	dec Item
	brpl mpus5a
	ldi Item, 2
mpus5a:	rjmp mpus1	

mpus5b:	cpi t, 0x02		;NEXT?
	brne mpus5d
	inc Item
	cpi item, 3
	brne mpus5c
	ldi Item, 0
mpus5c:	rjmp mpus1	

mpus5d:	cpi t, 0x01		;CHANGE?
	brne mpus5e

	cpi		Item,0
	brne	mpus12
	lds		t,gfs_sel
	inc		t
	andi	t,0b00000011
	sts		gfs_sel,t

mpus12:
	cpi		Item,1
	brne	mpus13
	lds		t,afs_sel
	inc		t
	andi	t,0b00000011
	sts		afs_sel,t

mpus13:
	cpi		Item,2
	brne	mpus5e
	lds		t,dlpf
	inc		t
	andi	t,0b00000111
	cpi		t,7
	brne	mpus14
	ldi		t,0
mpus14:
	sts		dlpf,t

mpus5e:	rjmp mpus1

mpus6:

lds		t,gfs_sel
	lsl		t
	lsl		t
	lsl		t
	sts		gfs_sel,t
	

	lds		t,afs_sel
	sts		afs_sel_out,t	; used to check if acc param changed
	lsl		t
	lsl		t
	lsl		t
	sts		afs_sel,t

	lds		t,dlpf
	sts		dlpf,t

	lds		xl,gfs_sel
	ldz eegfs_sel
	call StoreEeVariable8

	lds		xl,afs_sel
	call StoreEeVariable8

	lds		xl,dlpf
	call StoreEeVariable8

	call	setup_mpu6050
	call	clrmaxmin		

	rvcp	afs_sel_out,afs_sel_in
	brne	mpus15
	ret

mpus15:
	setflagfalse xl
	ldz eeSensorsCalibrated
	call StoreEeVariable8
	call	CalibrateSensors
	ret

mpus7:	.db "Gyro (deg/sec):", 0
mpus8:	.db "Acc    (+/- g):", 0
mpus9:	.db "Filter    (Hz):", 0
mpus10:	.db "BACK PREV NEXT CHANGE", 0
mpus10a:.db "BACK         CONTINUE", 0
mpus10c:.db "Acc Cal on exit!", 0,0
mpus10d:.db "                ", 0,0

gfs_sel0: .db "250", 0
gfs_sel1: .db "500", 0
gfs_sel2: .db "1000", 0, 0
gfs_sel3: .db "2000", 0, 0

afs_sel0: .db "2", 0
afs_sel1: .db "4", 0
afs_sel2: .db "8", 0
afs_sel3: .db "16", 0, 0

dlpf0: .db "256", 0
dlpf1: .db "188", 0
dlpf2: .db "98", 0, 0
dlpf3: .db "42", 0, 0
dlpf4: .db "20", 0, 0
dlpf5: .db "10", 0, 0
dlpf6: .db "5", 0

mpus11:	
	.db 100, 0, 124, 9
	.db 100, 9, 124, 18
	.db 100, 18, 124, 27

warn1: .db " Warning, changing ", 0
warn2: .db "these setting  will", 0
warn3: .db "affect P&I settings", 0
;warn4: .db "and Stick Scaling!!", 0

.undef Item	