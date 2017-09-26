;--------------------
;transmit serial:
;	Assumes a value for sending has been placed into ser_reg.
;	This functions transmits a serial over portb pin 7 use rotation functions.
;	The order of sending is LSB (least significant bit) first, so ser_reg is
;  rotated right, and the bit to send is moved into carry. rotating ser reg temp
;	right as well, will move the contents of carry into bit 7 of the 2nd register.
;	this bit is then written to portb. This happens every baud period 104uS after the start bit.
;	The start bit needs to be a high changing to a low, and then a stop bit is just set high.
;	See serial.png on github.
;-------------------	
transmit_serial:
   clr ser_out_temp		;Clear a temporary varible for use.

	ldi temp, 0xff			;Make sure serial port is already high.
	out portb, temp
	call delay_baud
	
	call delay_baud 			;Start bit requires a high to low change.
	ldi temp, 0x00          ;Load 0 into temp.
	out portb, temp         ;Will set pin 7 low.
	
	push temp2          		;just incase its used elsewhere, push the contents onto the stack.
	ldi temp2, 0x08         ;Load the number of data bits into the register.
	
write_bit:
	call delay_baud 			;Delay by baud period.
   ror ser_out             ;rotate right, so that bit 0 (sent first) is moved into carry register.
   ror ser_out_temp        ;rotate right, so the carry contents, is moved into bit 7 of ser_out temp.
	out portb, ser_out_temp ;output to portb.
	dec temp2               ;decrement the data bit counter
	brne write_bit          ;If data bit counter is zero, then continue, otherwise go back and write another bit.
	
	pop temp2               ;Pull the value of temp2 from the stack and back into temp2.
	
	call delay_baud			;Delay baud before send stop bit.
	ldi temp, 0xff          ;Stop bit requires a high
	out portb, temp         ;Output high on pin 7.
	call delay_baud
	call delay_baud			;Technically, this is an extra stop bit. But a single stop bit reciever will also work.
	ret
