UsartInit:

	rvbrflagtrue flagSatRx, UsartInitSat
	rjmp UsartInitSBus

	// Spektrum 8N1 (8 data bits / No parity / 1 stop bit / 115.2Kbps)
	
UsartInitSat:
	; Set baud rate
	clr	t
	sts UCSR0A, t		; Clear the 2x flag
	sts UBRR0H, t		; Baud High Byte = 0
	ldi t, 0x0A
	sts UBRR0L, t		; Baud Low Byte = 10

	; Enable receiver and Enable Receive Data Complete Interupt, 8 data
	;       76543210
	ldi t,0b10010000
	sts UCSR0B,t

	; Set frame format: Async, No Parity, 1 stop bit, 8 data
	;       76543210
	ldi t,0b00000110
	sts UCSR0C,t
	
	ret

	// SBus 8N2 (8 data bits / Even parity / 2 stop bit / 100Kbps)
	
UsartInitSBus:
	; Set baud rate
	ldi t, 0X02
	sts UCSR0A, t		; Set the 2x flag
	clr t
	sts UBRR0H, t		; Baud High Byte = 0
	ldi t, 0x18
	sts UBRR0L, t		; Baud Low Byte = 18

	; Enable receiver and Enable Receive Data Complete Interupt, 8 data
	;       76543210
	ldi t,0b10010000
	sts UCSR0B,t
	
	; Set frame format: Async, Even Parity, 2 stop bits, 8 data
	;       76543210
	ldi t,0b00101110
	sts UCSR0C,t

	ret