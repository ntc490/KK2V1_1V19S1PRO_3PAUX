
WaitXms:ldi yl, 10
	rcall wms
	sbiw x, 1
	brne WaitXms
	ret
		

wms:	ldi t,250		;wait yl *0.1 ms at 20MHz
wm1:	dec t
	nop
	nop
	nop
	nop
	nop
	brne wm1
	dec yl
	brne wms
	ret


CmpXy:	cp xl, yl
	cpc xh, yh
	ret


GetButtons:
	push xl
	push yl

	load t, pinb	;read buttons
	com t
	swap t
	andi t, 0x0f
	breq get1	;any buttons pressed?
	
	ldi yl, 100	;yes, wait 10ms
	call wms

	load t, pinb	;read buttons again
	com t
	swap t
	andi t, 0x0f

get1:	pop yl		;no, exit
	pop xl
	ret


GetButtonsBlocking:
med34:	call GetButtons		;wait until button released
	cpi t, 0x00
	brne med34

med9:	call GetButtons		;wait until button pressed
	cpi t, 0x00
	breq med9
	
	call Beep

	ret





GetEeVariable16:
	rcall ReadEeprom
	adiw z,1
	mov xl, t
	rcall ReadEeprom
	adiw z,1
	mov xh, t
	ret

StoreEeVariable16:
	mov t, xl
	rcall WriteEeprom
	adiw z, 1
	mov t, xh
	rcall WriteEeprom
	adiw z,1
	ret


GetEeVariable8:
	rcall ReadEeprom
	adiw z,1
	mov xl, t
	ret

GetEeVariable8P1:		;Used to read eeProfileP1
	rcall ReadEepromP1
	adiw z,1
	mov xl, t
	ret

GetEeVariable8P2:		;Used to read eeProfileP2 for SS & PI values
	rcall ReadEepromP2
	adiw z,1
	mov xl, t
	ret

StoreEeVariable8:
	mov t, xl
	rcall WriteEeprom
	adiw z, 1
	ret

StoreEeVariable8P1:		;Used to store eeProfileP1
	mov t, xl
	rcall WriteEepromP1
	adiw z, 1
	ret

GetEeVariable168:
	rcall ReadEeprom
	adiw z,1
	mov yh, t
	rcall ReadEeprom
	adiw z,1
	mov xl, t
	rcall ReadEeprom
	adiw z,1
	mov xh, t
	ret

StoreEeVariable168:
	mov t, yh
	rcall WriteEeprom
	adiw z, 1
	mov t, xl
	rcall WriteEeprom
	adiw z, 1
	mov t, xh
	rcall WriteEeprom
	adiw z,1
	ret

; below modified to Read and Write to P1 area or P2 area

ReadEeprom:
re1:	skbc eecr,1, r0
	rjmp re1
	push yl							
	push yh
	push zl
	push zh
	rvbrflagtrue flagProfileP1, re2	;P1 uses Z
	ldy EeProfileP2			;add P2 offset to Z
	add zl, yl
	adc zh, yh
re2:
	store eearl,zl	;(Z) -> t
	store eearh,zh

	ldi t,0x01
	store eecr,t

	load t, eedr
	pop zh
	pop zl
	pop yh
	pop yl
	ret


WriteEeprom:
	cli		;t -> (Z)

wr1:	skbc eecr,1, r0
	rjmp wr1
	push yl							
	push yh
	push zl
	push zh
	push t
	rvbrflagtrue flagProfileP1, wr2	;P1 uses Z
	ldy EeProfileP2		;add P2 offset to Z
	add zl, yl
	adc zh, yh
wr2:
	store eearl,zl
	store eearh,zh
	pop t
	store eedr,t

	;       76543210
	ldi t,0b00000100
	store eecr,t

	;       76543210
	ldi t,0b00000010
	store eecr,t
	pop zh
	pop zl
	pop yh
	pop yl
	sei
	ret

;ReadEepromP1 & WriteEepromP1 are used for the Signature and flagProfileP1

ReadEepromP1:
re1P1:	skbc eecr,1, r0
	rjmp re1P1

	store eearl,zl	;(Z) -> t
	store eearh,zh

	ldi t,0x01
	store eecr,t

	load t, eedr
	ret


WriteEepromP1:
	cli		;t -> (Z)

wr1P1:	skbc eecr,1, r0
	rjmp wr1P1

	store eearl,zl
	store eearh,zh

	store eedr,t

	;       76543210
	ldi t,0b00000100
	store eecr,t

	;       76543210
	ldi t,0b00000010
	store eecr,t

	sei
	ret

;used to read P2 SS & PI values

ReadEepromP2:
re1P2:	skbc eecr,1, r0
	rjmp re1P2
	push yl							
	push yh
	push zl
	push zh
	ldy EeProfileP2			;add P2 offset to Z
	add zl, yl
	adc zh, yh
	store eearl,zl	;(Z) -> t
	store eearh,zh

	ldi t,0x01
	store eecr,t

	load t, eedr
	pop zh
	pop zl
	pop yh
	pop yl
	ret

/*
;CriticalError:
	
		
	call LcdClear

	lrv PixelType, 1
	lrv FontSelector, f6x8
	lrv X1, 0
	lrv Y1, 0
	mPrintString cri1
	

	lrv X1, 0
	lrv Y1, 10
	call PrintString

	call LcdUpdate

cri2:	rjmp cri2




cri1:	.db "CRITICAL ERROR:",0

*/

