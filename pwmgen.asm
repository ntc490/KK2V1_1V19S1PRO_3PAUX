


PwmStart:

;	sbi OutputPin8 ; debug start pulse

	rvbrflagtrue flagSerialRx, pms1	;Serial RX attached and working so jump to code that disables interrupt during timer setup

	;set OCR1A to current time + 0.5ms

	cli
	load xl, tcnt1l	
	load xh, tcnt1h
	sei					

	ldi t, low(1250)
	add xl, t
	ldi t, high(1250)
	adc xh, t

	cli
	store ocr1ah, xh
	store ocr1al, xl
	sei

	;set OCR1B to current time + 1.5ms

	ldi t, low(2498)		;Was 2500 but there are a few instructions that get executed 
	add xl, t				;after this interrupt and before PWM low generated
	ldi t, high(2498)
	adc xh, t

	cli
	store ocr1bh, xh
	store ocr1bl, xl
	sei

	;turn on OC1a and b interrupt

	;       76543210
	ldi t,0b00000110
	store timsk1, t

	clr t
	sts flagPwmGenM7M8,t
	sts flagPwmEnd,t

	ret

pms1:		;if you have a spektrum satellite or SBus, set timer up without any USART interupt (we'll get that at the end if it happened)

	;set OCR1A to current time + 0.5ms

	cli
	load xl, tcnt1l	
	load xh, tcnt1h

	ldi t, low(1250)
	add xl, t
	ldi t, high(1250)
	adc xh, t

	store ocr1ah, xh
	store ocr1al, xl

	;set OCR1B to current time + 1.5ms

	ldi t, low(2498)		;Was 2500 but there are a few instructions that get executed 
	add xl, t				;after this interrupt and before PWM low generated
	ldi t, high(2498)
	adc xh, t

	store ocr1bh, xh
	store ocr1bl, xl
	sei

	;turn on OC1a and b interrupt

	;       76543210
	ldi t,0b00000110
	store timsk1, t

	clr t
	sts flagPwmGenM7M8,t
	sts flagPwmEnd, t
	
	ret


IsrPwmStart:

	;generate the rising edge of servo/esc pulses

	load SregSaver, sreg

	lds tt, flagPwmGenM7M8		;check for PWM generator state
	tst tt
	breq pwm1a

	cbi OutputPin7			;set M7 output low
	rjmp pwm12

pwm1a:	lds tt, flagMutePwm
	tst tt
	brmi pwmexit

	sec
	
	lds tt, OutputRateDividerCounter
	dec tt
	brne pwm1
	
		lds tt, OutputRateDivider
		clc	

pwm1:	sts OutputRateDividerCounter, tt
	
	ldi tt, 0xff			;bit pattern for fast and slow update rate
	brcc pwm2
	lds tt, OutputRateBitmask	;bit pattern for fast update rate

pwm2:	lsr tt				;stagger the pin switching to avoid up to 8 pins switching at the same time
	brcc pwm3
	sbi OutputPin1
pwm3:	lsr tt
	brcc pwm4
	sbi OutputPin2
pwm4:	lsr tt
	brcc pwm5
	sbi OutputPin3
pwm5:	lsr tt
	brcc pwm6
	sbi OutputPin4
pwm6:	lsr tt
	brcc pwm7
	sbi OutputPin5
pwm7:	lsr tt
	brcc pwm8
	sbi OutputPin6
pwm8:	lsr tt
	brcc pwm9
	sbi OutputPin7
pwm9:	lsr tt
	brcc pwm12
	sbi OutputPin8 ;<---OBS DEBUG
pwm12:	 

pwmexit:
	store sreg, SregSaver
	reti





IsrPwmEnd:
	load SregSaver, sreg

	lds tt, flagPwmGenM7M8		;check for PWM generator state
	tst tt
	breq ipe1

	cbi OutputPin8			;set M8 output low
	rjmp ipe2

ipe1:	
	ldi tt, 0xff
	sts flagPwmEnd, tt

ipe2:	
	store sreg, SregSaver
	reti





PwmEnd:	b16ldi Temp, 888		;make sure the EscLowLimit is not too high. (hardcoded limit of 20%)
	b16cmp EscLowLimit, Temp
	brlt pwm58
	b16mov EscLowLimit, Temp
pwm58:

	;loop setup

	lrv Index, 0		
	 
	lds t, OutputTypeBitmask
	sts OutputTypeBitmaskCopy, t

	rvflagnot flagInactive, flagArmed	;flagInactive is set to true if outputs should be in inactive state
	rvflagor flagInactive, flagInactive, flagThrottleZero ;therefore flagInactive = NOT armed OR throttle zero
	
	;loop body

pwm50:	b16load_array PwmOutput, Out1


	lds t, OutputTypeBitmaskCopy		;ESC or SERVO?
	lsr t
	sts OutputTypeBitmaskCopy, t
	brcc pwm51fix
	rjmp pwm51
pwm51fix:

	;---
	
	rvbrflagfalse flagServoOnArm, pwm52fix1		;Servos on Arm not set so run normal code
	rvbrflagtrue flagArmed, pwm52fix			;Make servos, active when Armed?
	rjmp pwm52													
pwm52fix1:
	rvbrflagfalse flagInactive, pwm52fix		;SERVO, active or inactive? (NOT armed OR throttle zero)
	rjmp pwm52

pwm52fix:
	b16load_array Temp, FilteredOut1 			;servo active, apply low pass filter
	b16sub Error, PwmOutput, Temp
	
	b16mul Error, Error, ServoFilter

	b16add PwmOutput, Temp, Error
	b16store_array FilteredOut1, PwmOutput
	
	rjmp pwm55

pwm52:	b16load_array PwmOutput, Offset1	;servo inactive, set to offset value
	rjmp pwm55

	;---

pwm51:	
	rvbrflagfalse flagSpinOnArm, pwm51a		;If not spin on arm, run normal code
	rvbrflagfalse flagArmed, pwm54			;If not armed, clear output
	rvbrflagfalse flagThrottleZero, pwm51b	;If not throttle zero, must be armed so run normal code
	b16mov PwmOutput, EscLowLimit			;Must be armed, with throttle zero and spin on arm
	rjmp pwm55

pwm51a:
	rvbrflagtrue flagInactive, pwm54	;ESC, active or inactive?
pwm51b:
	b16cmp PwmOutput, EscLowLimit		;ESC active, limit to EscLowLimit
	brge pwm56
	b16mov PwmOutput, EscLowLimit
pwm56:
	rjmp pwm55

pwm54:	b16clr PwmOutput			;ESC inactive, set to zero 

	;---

pwm55:	b16store_array Out1, PwmOutput


	;loop looper

	rvinc Index
	rvcpi Index, 8
	breq pwm57
	rjmp pwm50
pwm57:



.def O1L=r0
.def O1H=r1
.def O2L=r2
.def O2H=r3
.def O3L=r4
.def O3H=r5
.def O4L=r6
.def O4H=r7
.def O5L=r8
.def O5H=r17
.def O6L=r18
.def O6H=r19
.def O7L=r20
.def O7H=r21
.def O8L=r22
.def O8H=r23
	
	
	;this part transfers and conditions the OutN values to the 16bit registers ONH:ONL


;call DebugCU		;DEBUG

;	need to do M7 & M8 first as pwmcondfortimer destroys r0, r1 & r2 (which are used for O1L, O1H & O2L)

	lds xh, Out7
    lds xl, Out7+1
    rcall pwmcondfortimer7              
    mov O7L, zl
    mov O7H, zh

    lds xh, Out8
    lds xl, Out8+1
    rcall pwmcondfortimer8  
    mov O8L, zl
    mov O8H, zh

	ldz Out1Low
    lds xh, Out1
    lds xl, Out1+1
    rcall pwmcond
    mov O1L, xl
    mov O1H, xh

    lds xh, Out2
    lds xl, Out2+1
    rcall pwmcond
    mov O2L, xl
    mov O2H, xh

    lds xh, Out3
    lds xl, Out3+1
    rcall pwmcond
    mov O3L, xl
    mov O3H, xh

    lds xh, Out4
    lds xl, Out4+1
    rcall pwmcond
    mov O4L, xl
    mov O4H, xh

    lds xh, Out5
    lds xl, Out5+1
    rcall pwmcond
    mov O5L, xl
    mov O5H, xh

    lds xh, Out6
    lds xl, Out6+1
    rcall pwmcond
    mov O6L, xl
    mov O6H, xh	

;	cbi OutputPin8		;OBS DEBUG


	;generate the end of the PWM signal, this part is blocking.

	rvbrflagfalse flagPwmEnd, pwm29
	ldi t, 0					;if IsrPwmEnd is true here, the start of PWM pulse end generation is missed
;	call LogError				;log error	
;	call beep
	rvbrflagfalse flagArmed, pwm29a

.undef O6H	;keep the assembler happy
.undef O7L
.undef O7H
.undef O8L
.undef O8H

	b16inc	PwmErrorCounter				; only increment if armed
	b16ldi Temp, 32000					;avoid wrap-around
	b16cmp PwmErrorCounter, Temp
	brlt pwm29a
	b16mov PwmErrorCounter, Temp

.def O6H=r19
.def O7L=r20
.def O7H=r21
.def O8L=r22
.def O8H=r23

pwm29a:
	ret					;and return without generating the end of pwm pulse

pwm29:	rvbrflagfalse flagPwmEnd, pwm29		;wait until IsrPwmEnd has run (flagPwmEnd == true)


;prepare timer for jitter-free channels

	ser t
	sts flagPwmGenM7M8, t

	cli
	load xl, tcnt1l
	load xh, tcnt1h
;	sei	(interrupts can wait, as this will reduce jitter)

	movw y, x

	add xl, O7L
	adc xh, O7H
	add yl, O8L
	adc yh, O8H

;	cli
	store ocr1ah, xh
	store ocr1al, xl
	store ocr1bh, yh
	store ocr1bl, yl
	sei



	ldx 1		;generate the last 0 to 1ms part of the pwm signal
		
	ldy 556		;555 Timer - lol :-)
pwm13:	sub O1L, xl
	sbc O1H, xh
	brcc pwm14
	cbi OutputPin1
pwm14:	sub O2L, xl
	sbc O2H, xh
	brcc pwm15
	cbi OutputPin2
pwm15:	sub O3L, xl
	sbc O3H, xh
	brcc pwm16
	cbi OutputPin3
pwm16:	sub O4L, xl
	sbc O4H, xh
	brcc pwm17
	cbi OutputPin4
pwm17:	sub O5L, xl
	sbc O5H, xh
	brcc pwm18
	cbi OutputPin5
pwm18:	sub O6L, xl
	sbc O6H, xh
	brcc pwm19
	cbi OutputPin6
pwm19:  nop
	nop
	nop
	nop	
pwm20:  nop
	nop
	nop
	nop	

pwm21:	sbiw Y, 1
	brcc pwm13

	cbi OutputPin7	;for safety
	nop
	nop
	nop
	cbi OutputPin8

	ret

.undef O1L
.undef O1H
.undef O2L
.undef O2H
.undef O3L
.undef O3H
.undef O4L
.undef O4H
.undef O5L
.undef O5H
.undef O6L
.undef O6H
.undef O7L
.undef O7H
.undef O8L
.undef O8H





pwmcond:
	
	asr xh		;divide by 8
	ror xl
	asr xh
	ror xl
	asr xh
	ror xl

	ld	yh, Z+	;get the low value
	ld  yl, Z+
	adiw    z,1	;to get the .8 part of the 16.8 value
	cp  xl, yl
	cpc xh, yh
	brge pwm22	;x < low value ?
	mov xl, yl	;yes, set to low value
	mov xh, yh
	ret
pwm22:	
	ld	yh, Z+	;get the high value
	ld  yl, Z+
	adiw    z,1	;to get the .8 part of the 16.8 value
	cp  xl, yl
	cpc xh, yh
	brlt pwm23	;x >= high value ?
	mov xl, yl	;yes, set to high value
	mov xh, yh

pwm23:	ret

pwmcondfortimer7:

;Multiply a 16 bit unsigned integer (xh,xl) by an 8 bit fraction (yl) and store result in the 16 bit register (zh,zl)              
;Uses registers r0, r1, r2, xh, Xl, yl, zh, zl                   

	ldi yl, 0b10010000         ;0.5625 (0.5625 * 4440 = 2498 approx 2500)                  
	clr zh               
	clr t                  
	mul yl, xl                 ;mul #1
	mov r2, r0
	mov zl, r1                    
	mul yl, xh                 ;mul #2
	add zl, r0                     
	adc zh, r1                                 
	lsl r2                     ;round off
	adc zl, t                       
	adc zh, t                  
      
    lds	yh, Out7Low
	lds yl, Out7Low+1
    cp  zl, yl
    cpc zh, yh
    brge pwm22t   		   ;timer value < low limit ?
    mov zl, yl                  ;yes, set to low limit
    mov zh, yh
	ret

pwm22t:           
    lds	yh, Out7High
	lds yl, Out7High+1
    cp  zl, yl
    cpc zh, yh
    brlt pwm23t                ;timer value >= high limit ?
    mov zl, yl          ;yes, set to high limit
    mov zh, yh

pwm23t:           
	ret

pwmcondfortimer8:

;Multiply a 16 bit unsigned integer (xh,xl) by an 8 bit fraction (yl) and store result in the 16 bit register (zh,zl)              
;Uses registers r0, r1, r2, xh, Xl, yl, zh, zl                   

	ldi yl, 0b10010000         ;0.5625 (0.5625 * 4440 = 2498 approx 2500)                  
	clr zh               
	clr t                  
	mul yl, xl                 ;mul #1
	mov r2, r0
	mov zl, r1                    
	mul yl, xh                 ;mul #2
	add zl, r0                     
	adc zh, r1                                 
	lsl r2                     ;round off
	adc zl, t                       
	adc zh, t                  
      
    lds	yh, Out8Low
	lds yl, Out8Low+1
    cp  zl, yl
    cpc zh, yh
    brge pwm22t8   		   ;timer value < low limit ?
    mov zl, yl                  ;yes, set to low limit (can't be less or we miss the interrupt)
    mov zh, yh
	ret

pwm22t8:           
    lds	yh, Out8High
	lds yl, Out8High+1
    cp  zl, yl
    cpc zh, yh
    brlt pwm23t8                ;timer value >= high limit ?
    mov zl, yl          ;yes, set to high limit
    mov zh, yh

pwm23t8:           
	ret


/*
	;       76543210
	ldi t,0b
	store , t
*/
