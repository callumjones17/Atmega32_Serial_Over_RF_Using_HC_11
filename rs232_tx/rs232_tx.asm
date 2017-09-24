;*********************************
;***	RS232 Transmitter Code  ****
;*********************************
;This program is intened for use with the ATMEGA32,
;where pin 8 of portb is set up as the TX. This program,
;continuously sends the ascii code for 'C' -> 0x43 over
;the serial pin.

;RS232 Settings:
;Baud - 9600
;Stop Bit - 1 or 2 (Won't affect the program, unless your sending serial really quickly, in which case stop bits is 1)
;Data Bits - 8
;No Parity Bits.

;2256 - Introduction into Embedded Systems - 2017
;Callum Jones
;RMIT


.include "C:\2256\VMLAB\include\m32def.inc"

.def  temp  = r16		;Define registers 16-19 for use as varibles
.def delay_reg = r18
.def temp2 = r19
.def SER_OUT_TEMP = r21
.def SER_OUT = r20

.equ delayBaud = 205 	;Define a counter value for the delay function (see delay_baud).

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
   reti      ; Addr $0F
   reti      ; Addr $10

; Program starts here after Reset

;
start:
   ldi temp, low(RAMEND) 	;Setup the stack pointer to the bottom or RAM, so its out of the way. Stack pointer decrements, when items are pushed onto it.
   out SPL, temp
   ldi temp, high(RAMEND)
   out SPH, temp
	ldi temp, 0x80         ; Init pin 7 of port B, which will be the serial port.
	out DDRB, temp         ; Setup data direction register ddrb to configure pin 7 as output (1, 0 for input).
	call delay_baud        ; let things settle in the ddrb register.
	ldi temp, 0x80
	out PORTB, temp		  ; Set the pin high, as a change from low to high initiates the serial protocol.
	
	ldi SER_OUT, 0x43      ;This is a test variable. In ascii 0x43 is 'C'
	



forever:
   nop
   nop
   nop
   nop
   call Delay   ;Delay for a while before sending over the port again (1.68s)
   call Delay   ;1.68s
   call Delay   ;1.68s
   call transmit_serial    ;Transmit using the serial interface.
   call delay_baud         ;Delay a bit more
   ldi SER_OUT, 0x43       ;Reset the register holding the value to be sent, rotating (see transmit serial) corrupts the data, for the next loop.
   call Delay              ;Delay a bit more.

rjmp forever



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
         PUSH R16						
         PUSH R17
         PUSH R0
         CLR R0
         CLR R16
         CLR R17
L1:      DEC R16
			CPSE R16, R0
			RJMP L1	
			CLR R16		
L2:      DEC R17
         CPSE R17, R0
         RJMP L1			
;
         POP R0
         POP R17
         POP R16
         RET










