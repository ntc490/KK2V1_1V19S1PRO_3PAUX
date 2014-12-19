.def	i	=r17
.def	twidata	=r18

setup_mpu6050:	

	ldi		t,0x6B				
	sts		TWI_address,t		// PWR_MGMT_1    -- DEVICE_RESET 1
	ldi		twidata, 0x80
	call 	i2c_send_adr
	ldx		50
	call	WaitXms

	ldi		t,0x6B				
	sts		TWI_address,t		// PWR_MGMT_1    -- SLEEP 0; CYCLE 0; TEMP_DIS 0; CLKSEL 1 (PLL with X Gyro reference)
	ldi		twidata, 0x01
	call 	i2c_send_adr

	ldi		t,0x1A				
	sts		TWI_address,t		// CONFIG        -- EXT_SYNC_SET 0 (disable input pin for data sync) ; default DLPF_CFG = 0 => ACC bandwidth = 260Hz
	ldz		eedlpf
	call	ReadEeprom
	sts		dlpf, t			// save to SRAM for later
	mov		twidata, t
	call 	i2c_send_adr

	ldi		t,0x1B
	sts		TWI_address,t		// GYRO_CONFIG   -- Default FS_SEL = 3: Full scale set to 2000 deg/sec
	ldz		eegfs_sel
	call	ReadEeprom
	sts		gfs_sel, t			// save to SRAM for later
	mov		twidata, t
	call 	i2c_send_adr

	ldi		t,0x1C
	sts		TWI_address,t		// write reg address ro sensor  ACCEL_CONFIG
	ldz		eeafs_sel
	call	ReadEeprom
	sts		afs_sel, t			// save to SRAM for later
	mov		twidata, t
	call 	i2c_send_adr

	ldx		50
	call	WaitXms

	ret



//	read setup direct from MPU6050
MPU_setup:	

	ldi		t,0x1A
	sts		TWI_address,t
	call	i2c_read_adr
	sts		dlpf, t

	ldi		t,0x1B
	sts		TWI_address,t
	call	i2c_read_adr
	sts		gfs_sel, t

	ldi		t,0x1C
	sts		TWI_address,t
	call	i2c_read_adr
	sts		afs_sel, t

	ret


.undef	i	
.undef	twidata	