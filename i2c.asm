.def	i	=r17
.def	twidata	=r18

// i2c_start command==========================

i2c_start:
	ldi		i,2		// try 2times for test TWI communcation
i2c_start2:
	ldi		t, (1<<TWINT) | (1 << TWEN) | (1 << TWSTA)
	store	TWCR, t

    rcall   i2c_wait

	lds	t, TWSR

	andi   	t,0xF8   //Mask TWSR value
   	cpi   	t,0x08   //check if TW_START
    breq   	i2c_start3
   	cpi   	t,0x10   //check if TW_REP_START
    breq  	i2c_start3	
	clc
	ret				//leave if TWI not free

i2c_start3:
   	ldi 	t,0xD0   //device name with write command
   	store  	TWDR, t
 
   	ldi   	t,(1<<TWINT)|(1<<TWEN)
   	store   TWCR,t 
 
	rcall   i2c_wait

	lds		t,TWSR
	andi   	t,0xF8   //Mask
	cpi		t,0x18		//check if slave ack
	breq   	i2c_start_ok
	dec		i
	cpi		i,0
	breq	i2c_start_err    //leave if slave not ack for 2 times
	cpi		t,0x20     //try again if reply with slave not ack 
	breq	i2c_start2

i2c_start_err:	
	clc		// clear carry if error
	ret

i2c_start_ok:
	sec		// set carry if start ok
 	ret

// End i2c_start ==========================


// i2c_read_command =================
i2c_read:
	ldi		i,2		// try 2times for test TWI communcation
i2c_read2:
	ldi		t, (1<<TWINT) | (1 << TWEN) | (1 << TWSTA)
	store	TWCR, t

    rcall   i2c_wait

	lds		t, TWSR

	andi   	t,0xF8   //Mask TWSR value
    cpi   	t,0x08   //check if TW_START
    breq   	i2c_read3 
    cpi   	t,0x10   //check if TW_REP_START
    breq  	i2c_read3	
	clc
	ret				//leave if TWI not free

i2c_read3:
   	ldi 	t,0xD1   //device name with read command

   	store 	TWDR, t
 
   	ldi   	t,(1<<TWINT)|(1<<TWEN)
   	store    TWCR,t 
 
	rcall   i2c_wait

	lds		t,TWSR
	andi   	t,0xF8   	//Mask
	cpi		t,0x40		//check if read slave ack
	breq   	i2c_read_ok
	dec		i
	cpi		i,0
	breq	i2c_read_err    //leave if read slave not ack for 2 times
	cpi		t,0x48     	//try again if reply with read slave not ack 
	breq	i2c_read2

i2c_read_err:	
	clc		// clear carry if error
	ret

i2c_read_ok:
	sec		// set carry if start ok
	ret
// End i2c_read_command =================


// Send read with start command ================
i2c_read_adr:
	call	i2c_start
	brcs	i2c_read_adr2
	ret
	 
i2c_read_adr2:
	lds		t, TWI_address
	call	i2c_write_address
	brcs	go_read
	ret

go_read:
 	call	i2c_read
	brcs	go_load_data
	ret
    
go_load_data:
	ldi		i,2
	call	i2c_get_data
	brcc	no_data			
	lds		t,TWDR
	sec
	ret

no_data:
	clc
	ret
// End Send read with start command ================


// i2c_get_data_command =================
i2c_get_data:
	ldi   	t,(1<<TWINT)|(1<<TWEN)   // last data for read
   	
i2c_get_data2:	
	store   TWCR,t 
	rcall   i2c_wait

	lds		t,TWSR
	andi   	t,0xF8   //Mask
 	cpi   	t,0x50   // check if start
    breq   	i2c_data_ok
    cpi   	t,0x58   // check if restart
    breq  	i2c_data_ok
 	clc
	cpi		i,0
	brne	i2c_get_data
	ret

i2c_data_ok:
	call	i2c_stop
	sec
	ret
// End i2c_get_data_command =================


// i2c_write_address =================
i2c_write_address:
	store  	TWDR, t

	ldi   	t,(1<<TWINT)|(1<<TWEN)
   	store   TWCR,t 
 
	rcall   i2c_wait

	lds		t, TWSR
	andi   	t,0xF8   //Mask
	cpi		t,0x28	 //check if data ack
	breq   	i2c_write_address_ok
	clc		//false if data not ack
	ret

i2c_write_address_ok:
	sec
	ret
// End i2c_write_address =================


//Send_start ================
;**************************** 
;func: .cs = I2C_Start(void) // .cs if free 
;**************************** 
//I2C_Start: 
i2c_read_adr_d:
	call	i2c_start
	brcs	i2c_read_adr2_d
	ret
	 
i2c_read_adr2_d:
	lds		t, TWI_address
	call	i2c_write_address
	brcs	go_read_d
	ret

go_read_d:
 	call	i2c_read
	brcs	go_load_data_d
	ret
  
go_load_data_d:
	ldi		i,2
	rcall	i2c_get_data_d
	brcc	no_data_d			
	sec
	ret

no_data_d:
	clc
	ret
//Send_start ================


//i2c_get_data_command =================
i2c_get_data_d:
	dec		twidata
	cpi		twidata,0
	breq	last_data_d

	ldi   	t,(1<<TWINT)|(1<<TWEN)|(1<<TWEA)
	rjmp	i2c_get_data2_d

last_data_d:
	ldi   	t,(1<<TWINT)|(1<<TWEN)

   	
i2c_get_data2_d:	
	store   TWCR,t 
	call   i2c_wait

	lds		t,TWSR
	andi   	t,0xF8   //Mask
 	cpi   	t,0x50   // check if start
    breq   	I2C_data_ok_d
    cpi   	t,0x58   // check if restart
    breq  	I2C_data_ok_d
 	clc
	ret

I2C_data_ok_d:	

	clr		yh					; cleared for 16.8 register stores below

	cpi		twidata,13			; ACCY_H
	brne	data2
	load	xh,twdr				; data1 save
	rjmp	check_last

data2:
	cpi		twidata,12			; ACCY_L
	brne	data3a
	rjmp	data2_1
data3a:
	jmp		data3
data2_1:
	load	xl,twdr				; data2 save
	b16store AccY
	b16fdiv AccY,6				; shift 6 bits
	ldx		512
	b16store	Temp2			; Used to offset values (this is half way between 0 and 1023)
	b16add	AccY,AccY,Temp2		; Offset by 512 (0g when steady)
	rjmp	check_last

data3:
	cpi		twidata,11			; ACCX_H
	brne	data4
	load	xh,twdr				; data3 save
	rjmp	check_last

data4:
	cpi		twidata,10			; ACCX_L
	brne	data5a
	rjmp	data4_1
data5a:
	jmp		data5
data4_1:
	load	xl,twdr				; data4 save
	b16store AccX
	b16neg	AccX		
	b16fdiv AccX,6				; shift 6 bits
	b16add	AccX,AccX,Temp2		; Offset by 512 (0g when steady)
	rjmp	check_last

data5:
	cpi		twidata,9			; ACCZ_H
	brne	data6
	load	xh,twdr				; data5 save
	rjmp	check_last

data6:
	cpi		twidata,8			; ACCZ_L
	brne	data7
	load	xl,twdr				; data6 save
	b16store AccZ
	b16fdiv AccZ,6				; shift 6 bits
	b16add	AccZ,AccZ,Temp2		; Offset by 512 (1g when steady)
	rjmp	check_last

data7:
	cpi		twidata,7			; Temp_H
	brne	data8
	load	xh,twdr				; data7 save
	rjmp	check_last

data8:
	cpi		twidata,6			; Temp_L
	brne	data9	
	load	xl,twdr				; data8 save
	b16store MPU6050Temperature
	rjmp	check_last

data9:
	cpi		twidata,5			; GyroPitch_H
	brne	data10
	load	xh,twdr				; data9 save
	rjmp	check_last

data10:
	cpi		twidata,4			; GyroPitch_L
	brne	data11
	load	xl,twdr				; data10 save
	b16store GyroPitch
	b16fdiv GyroPitch,6			; shift 6 bits
	b16add	GyroPitch,GyroPitch,Temp2 ; Offset by 512
	rjmp	check_last

data11:
	cpi		twidata,3			; GyroRoll_H
	brne	data12
	load	xh,twdr				; data11 save
	rjmp	check_last

data12:
	cpi		twidata,2			; GyroRoll_L
	brne	data13
	load	xl,twdr				; data12 save
	b16store GyroRoll
	b16fdiv GyroRoll,6			; shift 6 bits
	b16add	GyroRoll,GyroRoll,Temp2 ; Offset by 512
	rjmp	check_last

data13:
	cpi		twidata,1			; GyroYaw_H
	brne	data14
	load	xh,twdr				; data13 save
	rjmp	check_last

data14:							; Must be ; GyroYaw_L
	load	xl,twdr				; data14 save
	b16store GyroYaw
	b16fdiv GyroYaw,6			; shift 6 bits
	b16add	GyroYaw,GyroYaw,Temp2 ; Offset by 512

check_last:
	cpi		twidata,0
	breq	i2c_get_data_d_ok
	rjmp	i2c_get_data_d
	
i2c_get_data_d_ok:
	call	i2c_stop
	sec
	ret
//i2c_get_data_command =================


// Send data =====================
i2c_send_adr:
	rcall	i2c_start
	brcs	i2c_send_adr2
	ret
	 
i2c_send_adr2:
	lds		t,TWI_address		// write Address
	rcall	i2c_write_address
	brcs	go_write
	ret

go_write:
	mov 	t,twidata		// write data
   	rcall	i2c_write_address
	brcc	fail_write
	call	i2c_stop
	sec
	ret

fail_write:
	clc
	ret

// Send data =====================



// Wait_TWI_int ==============

i2c_wait: 
   lds   	t,TWCR   
   sbrs   	t,TWINT 
   rjmp   	i2c_wait 
   ret 

// Wait_TWI_int ==============

// Send_stop =================

i2c_stop:  
   ldi   	t,(1<<TWINT)|(1<<TWEN)|(1<<TWSTO) 
   store   	TWCR,t 
   ret 

// End Send_stop =================


.undef	i	
.undef	twidata	


