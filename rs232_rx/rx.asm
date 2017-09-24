;******************************
;***	RS232 Reciver Code  ****
;*****************************
;This program is intened for use with the ATMEGA32,
;where PORTC pin 7 is the RX pin, and PORTB will be
;used to disply the incomming ASCII character.

;RS232 Settings:
;Baud - 9600
;Stop Bit - 1 or 2 (Won't affect the program)
;Data Bits - 8
;No Parity Bits.

;2256 - Introduction into Embedded Systems - 2017
;Callum Jones
;RMIT

.include "C:\2256\VMLAB\include\m32def.inc"

.def  temp  =r16 			;Define registers 16-19 for use as varibles
.def result =r17
.def delay_reg =r18
.def temp2 =r19

.equ DelayBaud = 205			;These are setup for the delay function (see delay function).
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

; Program starts here after Reset
;
start:
   nop
   nop

	;Begin by setting all the registers to be used to zero.
	clr temp
	clr temp2
	clr result
	clr delay_reg

	ldi temp, low(RAMEND) ;Setup the stack point to the very bottom of RAM.
	out SPL, temp          ;When an item is pushed on the stack, it moves up the RAM (ie the address is decremented),
	ldi temp, high(RAMEND) ;so RAMEND is the perfect spot - completely out of the way of our code.
	out SPH, temp
	
	ldi temp, 0xFF 		;All of portb will be used as an output
	out DDRB, temp       ;So ddrb is set to 0xFF (0 for input, 1 for output).
	ldi temp, 0xff       ;To begin with, portb is set high (all LED's on for the OUSB board).
	out PORTB, temp
	
	ldi temp, 0x00  		;Portc pin7 will be used as an input, we really don't care the other pins for this example
	out DDRC, temp       ;DDRC set to 0x00 (0 for input, 1 for output).
	ldi temp, 0x00
	out PORTC, temp

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
	call rx			;RX subroutine.						
rjmp forever


;------------------
;rx:
;	This subroutine checks for the start bit (high to low change on the RX pin).
;	When no data is passing, the RX pin will be high. If the change is detected,
;	go to read_serial routine, otherwise go back to the main loop.
;------------------
rx:
 	in temp, PINC 				;PINC is the input location for reading PORTC, load into temp
 	andi temp, 0x80			;RX pin is 7, so remove everything else, by AND'ing it with 10000000
 	ldi temp2, 0x80         ;Load 10000000 into temp2
 	cp temp, temp2          ;If temp = temp2, it means the RX pin is still high, so no start bit.
 	brne read_serial        ;Otherwise, start bit is detected, so go and read serial data.
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
 	
 	call Delay_baud_half    ;Delay to let things settle
 	call Display            ;Display the result on portB
 	call Delay_baud_half
	ret
error_code:     				
	ldi result, 0x55        ;I have decided to use 0x55 as the error. On the OUSB board, this turns on all the RED LED's
	ret
	
	
;-----------------------
;display:
	;Display the result (ascii code) onto portb.
;-----------------------	
Display:            			
	out portb, result      ;Recall the result was rotated into result register, so output to portb.
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

















