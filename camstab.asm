
CameraStabSetup:

.def Item		= r17

cam11:	call LcdClear
	
	lrv PixelType, 1
	lrv FontSelector, f6x8

	lrv X1,0
	lrv Y1,1
	mPrintString cam1


	lrv X1,0
	lrv Y1,14
	mPrintString cam2
	ldz eeCamRollGain
	call GetEeVariable16 
 	call Print16Signed 

	lrv X1,0
	lrv Y1,23
	mPrintString cam3
	call GetEeVariable16 
 	call Print16Signed 

	lrv X1,0
	lrv Y1,32
	mPrintString cam4
	call GetEeVariable16 
 	call Print16Signed 

	lrv X1,0
	lrv Y1,41
	mPrintString cam5
	call GetEeVariable16 
 	call Print16Signed 




	;footer
	lrv X1, 0
	lrv Y1, 57
	mPrintString cam6

	;print selector
	ldzarray cam7*2, 4, Item
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
	brne cam8
	ret	

cam8:	cpi t, 0x04		;PREV?
	brne cam9	
	dec Item
	brpl cam10
	ldi Item, 3
cam10:	rjmp cam11	

cam9:	cpi t, 0x02		;NEXT?
	brne cam12
	inc Item
	cpi item, 4
	brne cam13
	ldi Item, 0
cam13:	rjmp cam11	

cam12:	cpi t, 0x01		;CHANGE?
	brne cam14

	ldzarray eeCamRollGain, 2, Item
	push zl
	push zh
	call GetEeVariable16
	ldzarray cam15*2, 4, Item
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
	ldzarray eeCamRollGain, 2, Item
	call StoreEeVariable16

cam14:	rjmp cam11




cam1:	.db "Camera Stab Setup", 0
cam2:	.db "Roll gain    :", 0,0
cam3:	.db "Roll offset  :", 0,0
cam4:	.db "Pitch gain   :", 0,0
cam5:	.db "Pitch offset :", 0,0
cam6:	.db "BACK PREV NEXT CHANGE", 0


cam7:	
	.db 83, 13, 110, 22
	.db 83, 22, 110, 31
	.db 83, 31, 110, 40
	.db 83, 40, 110, 49

cam15:	
	.dw -32000, 32000
	.dw 0, 100
	.dw -32000, 32000
	.dw 0, 100

.undef Item






CameraStab:

	lds t,TXGimbal
	cpi t,1
	brge cam28
	rjmp cam26				;no adjustment enabled

cam28:
	lds t,TXGimbal
	cpi t,2					;adjust Gimbal offset with TX Ch6&7
	brge cam27a
	rjmp cam27b
cam27a:
	rjmp cam27

cam27b:				;must be Aux adjustment on Pitch Servo
	b16load RxAux
	call xabs
	b16store RxAux
	b16ldi Temp, 4.44
	b16mul CamPitchOffset, RxAux, Temp
	rjmp cam26			

cam27:
	b16ldi Temp, 1000
	b16add RxAux2, RxAux2, Temp
	b16add RxAux3, RxAux3, Temp
	b16ldi Temp, 2.22
	b16mul CamRollOffset, RxAux2, Temp
	b16mul CamPitchOffset, RxAux3, Temp

cam26:
	b16mov CamRoll, CamRollOffset			;calculate camera angles for normal gimbal
	b16mul Temp, EulerAngleRoll, CamRollGain
	b16add CamRoll, CamRoll, Temp

	b16mov CamPitch, CamPitchOffset
	b16mul Temp, EulerAnglePitch, CamPitchGain
	b16add CamPitch, CamPitch, Temp

	b16clr Temp				;only update Out7, Out8 if CamRollGain and CamPitchGain is non-zero.
	b16cmp CamRollGain, Temp
	brne cam22
	rjmp cam20
cam22:	b16cmp CamPitchGain, Temp
	brne cam23
	rjmp cam20
cam23:
	
	rvbrflagtrue flagSSGimbal, cam24

	b16mov Out7, CamRoll			;for standard Gimbal
	b16mov Out8, CamPitch
	rjmp cam25

cam24:
	b16sub Out7, CamRoll, CamPitch		;for Super Simple Gimbal
	b16add Out8, CamRoll, CamPitch
	b16ldi Temp, 2220					;thanks to RC911
	b16add Out7, Out7, Temp
	b16sub Out8, Out8, Temp

cam25:
	b16mov Offset7, CamRollOffset
	b16mov Offset8, CamPitchOffset

cam20:	ret
