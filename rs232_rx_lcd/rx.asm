;**********************************************************************
;***	RS232 Reciver Code with Attached Parallax Serial LCD Screen  ****
;**********************************************************************
;This program is intened for use with the ATMEGA32,
;where PORTC pin 7 is the RX pin, and PORTB pin 7 will be used as a TX
;pin, to serial out to the parallax LCD screen. This particular screen
;uses ascii characters to both display and control it.

;RS232 Settings RX and TX:
;Baud - 9600
;Stop Bit - 1 or 2 (Won't affect the program)
;Data Bits - 8
;No Parity Bits.

;2256 - Introduction into Embedded Systems - 2017
;Callum Jones
;RMIT

.include "C:\2256\VMLAB\include\m32def.inc"

.def  temp  =r16         ;Define registers 19-21 for use as varibles
.def result =r17
.def delay_reg =r18
.def temp2 =r19
.def ser_out = r20
.def ser_out_temp = r21
.def debug = r22    		;For slow debugging only.

.equ DelayBaud = 205			;Define delay counter values.
.equ DelayBaudHalf = 10

reset:
   rjmp start
   reti      ; Addr $01
   reti      ; Addr $02
   reti      ; Addr $03
   reti      ; Addr $04
   reti      ; Addr $05
   reti      ; Addr $06        Use 'rjmp myVector'
   reti      ; Addr $07        to define a interrupt vector
   reti      ; Addr $08
   reti      ; Addr $09
   reti      ; Addr $0A
   reti      ; Addr $0B        This is just an example
   reti      ; Addr $0C        Not all MCUs have the same
   reti      ; Addr $0D        number of interrupt vectors
   reti      ; Addr $0E
   reti      ; Addr $0F
   reti      ; Addr $10

start:
   nop
   nop

	clr temp 			;Clear the registers with a 0 so they can be safely used.
	clr temp2
	clr result
	clr delay_reg
	clr debug

	ldi temp, low(RAMEND);Setup the stack point to the very bottom of RAM.
	out SPL, temp          ;When an item is pushed on the stack, it moves up the RAM (ie the address is decremented),
	ldi temp, high(RAMEND) ;so RAMEND is the perfect spot - completely out of the way of our code.
	out SPH, temp
	
	ldi temp, 0x80 		;Set up portb pin 7 as an output (TX pin to LCD).
	out DDRB, temp       ;The Data dirction pin needs to be set to 1 (0 for input).
	ldi temp, 0x80       ;For transmitting serial, during the unused state, the link needs to be high.
	out PORTB, temp      ;Set it high.
	
	ldi temp, 0x00       ;Set up portc as inputs.
	out DDRC, temp       ;Send 0's to DDRC, 0 for input, 1 for output.
	ldi temp, 0x00       ;Disable the internal pullup resistors.
	out PORTC, temp      ;This is done by writing 0 (1 for enable) to portc when its an input.
	
	call Delay           ;Use a delay, give the LCD some setup time.
	
	ldi ser_out, 0x11 	 ; Turn back light on. According the data sheet 0x11 turns on the backlight.
	call transmit_serial  ;Use serial to send 0x11 to the LCD.
	call delay_baud       ;Wait for a bit, give the LCD some time to write.



;------------------
;forever:
;	This is the main loop. All it does is call the RX subroutine.
;	There are no delays in this loop, because the RX pin (pin 7 of portc)
;	needs to be sampled as much quicker than the baud rate for 9600. This
; 	is so the start bit is detected instead of a 0 in the data. Start bit is
;	represented by a change from high to low.
;------------------
forever:
   nop
   nop
   nop
   nop
	call rx						;This sub routine checks for a low start bit and returns value if true, 0 otherwise
rjmp forever

;------------------
;rx:
;	This subroutine checks for the start bit (high to low change on the RX pin).
;	When no data is passing, the RX pin will be high. If the change is detected,
;	go to read_serial routine, otherwise go back to the main loop.
;------------------
rx:
 	in temp, PINC         ;Start bit?
 	andi temp, 0x80
 	ldi temp2, 0x80
 	cp temp, temp2
 	brne read_serial
 	ldi temp, 0x00
	ret

	
;------------------
;read_serial:
;	Start bit has already been detected, now the next 8 baud rates must be read.
;	The baud rate for this example is 9600, so the period between the bits sent
;	is 1/9600 = 104.2uS. So after the start bit, after 104uS the first data bit
;	will be sent, and after another 104uS, the 2nd data and so on. Please see
;	github for an image called serial.png for a better view. To read this serial,
;	the processor needs to sample every baud period, however the processor should
;	also delay for half a period, so that it's not sampling on the transition,
;	between data bits.
;------------------	
read_serial:
	call delay_baud_half 	;Shifts our sampler, so the sampler is clear of transitions.
		
	ldi temp2, 0x08			;Number of data bits to detect.		
read_bit:			
	call delay_baud         ;Delay by baud_period
	in temp, PINC           ;Read from portc, into temp
	andi temp, 0x80         ;AND result with 10000000, so only pin 7 remains.
	rol temp                ;Rotate bit 7 from temp into  carry.   (ie -> 1000 0000 -> C = 1, temp = 0000 00000)  Rotating will move all bits to the left
	ror result              ;Rotate bit from carry into bit 7 of result (ie -> 0000 0000 C = 1 -> result = 1000 0000) Rotating will move all bits to the right
	dec temp2               ;Decrement our data bit counter
	brne read_bit           ;If no more bits, then continue on, otherwise go back and read the next bit.
	
	call delay_baud         ;Delay by baud period. After the data bits, we should expect a stop bit (HIGH).
	in temp, PINC           ;Read portc into temp
 	andi temp, 0x80         ;Only interested in pin7, so and with 1000 0000
 	ldi temp2, 0x80         ;Load temp2 with comparison
 	cp temp, temp2          ;Compare temp2 with temp, if they are equal, then RX is high and stop bit has been recived.
 	brne error_code         ;Otherwise there is an error, better handle that.
 	
 	mov ser_out, result		;Move the Resulting ASCII character into ser_out register
	call transmit_serial    ;Transmit contents of ser_out to LCD
 	call Delay_baud    ;Delay, give the LCD some time to write.
	ret
error_code:     				
	ldi result, 0x55        ;I have decided to use 0x55 as the error. On the OUSB board, this turns on all the RED LED's
	ret
		
	
	
;----------------------
;delay_baud:
;	Delays the sampler by the baud period, 104uS.
;  Using the instruction set manual for avr, the following was determined:
;	103uS = (205 * 6) + 5 * 83.33nS, baud rate is about 104uS
;  Where 205 is the number stored in DelayBaud and 6 (2 for brne) is the number of cycles in the loop.
;  The extra 5 are for the return and ldi at the start.
;----------------------	
delay_baud: 							
	ldi delay_reg, DelayBaud      ;Load the counter value from program memory into delay_reg, 1 cycle
db_l:
	dec delay_reg                 ;decrement the counter delay reg - 1 cycle
	nop                           ;nop - 1 cycle
	nop
	nop
	brne db_l                     ; if not equal to zero, redo the loop again, otherwise return (2 cycles).
	ret

;----------------------
;delay_baud half:
;	Delays the sampler by the baud period, 104uS.
;  Using the instruction set manual for avr, the following was determined:
;	5.4uS = (10 * 6) + 5 * 83.33nS, baud rate is about 104uS
;  Where 10 is the number stored in DelayBaudHalf and 6 (2 for brne) is the number of cycles in the loop.
;  The extra 5 are for the return and ldi at the start.
;	It was mentioned earlier this value should be about half the baud_rate, but testing and experimentation,
;	resulted in the highest accuracy at 5.4uS. This is probably due to operations between reading the start bit,
;  and first data bit.
;----------------------		
delay_baud_half: 							
	ldi delay_reg, DelayBaudHalf      ;Load the counter value from program memory into delay_reg, 1 cycle
db_h_l:
	dec delay_reg                 ;decrement the counter delay reg - 1 cycle
	nop                           ;nop - 1 cycle
	nop
	nop
	brne db_l                     ; if not equal to zero, redo the loop again, otherwise return (2 cycles).
	ret


;--------------------
;Delay:
;	Calls a lot of 21mS delay routines
;	80 Delay_more's = 80*21mS = 1.68s
;--------------------
Delay:
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	call Delay_more
	ret




;--------------------
;delay_more:
;	Uses inner and outer loop to delay
; 	processor by 21mS. Each loop decrements counters,
; 	from 255 down to zero.
; 	Based on this:
;	4 cycles times 256 * 256 * 83.3 *10e-9 = about 21mS
;--------------------
Delay_more:
         PUSH R16			; save R16 and 17 as we're going to use them
         PUSH R17       ; as loop counters
         PUSH R0        ; we'll also use R0 as a zero value for compare
         CLR R0
         CLR R16        ; init inner counter
         CLR R17        ; and outer counter
L1:      DEC R16         ; counts down from 0 to FF to 0
			CPSE R16, R0    ; equal to zero?
			RJMP L1			 ; if not, do it again
			CLR R16			 ; reinit inner counter
L2:      DEC R17
         CPSE R17, R0    ; is it zero yet?
         RJMP L1			 ; back to inner counter
;
         POP R0          ; done, clean up and return
         POP R17
         POP R16
         RET
	
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








