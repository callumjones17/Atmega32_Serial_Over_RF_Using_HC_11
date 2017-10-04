; ******************************************************
; BASIC .ASM template file for AVR
; ******************************************************

.include "C:\2256\VMLAB\include\m32def.inc"

; Define here the variables
;
.def  temp  =r16
.def  multi =r20
.def  temp2 = r19
.def result =r17
.def delay_reg =r18
.def counter = r22

.equ DelayBaud = 205			;These are setup for the delay function (see delay function).
.equ DelayBaudHalf = 10

; Define here Reset and interrupt vectors, if any
;
reset:
   rjmp start
   reti      ; Addr $01
   reti      ; Addr $02
   reti      ; Addr $03
   jmp int1_handler      ; Addr $06        Use 'rjmp myVector'
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
   nop       ; Initialize here ports, stack pointer,
   nop       ; cleanup RAM, etc.
   nop       ;
   nop       ;

	clr counter
	
	ldi temp, high(RAMEND)
	out SPH, temp
	ldi temp, low(RAMEND)
	out SPL, temp
	
	ldi temp, 0xFF
	out DDRB, temp
	ldi temp, 0x00
	out PORTB, temp
	
	out ddrd, temp
	out portd, temp
	
	out ddrc, temp
	out portc, temp
	
	
	ldi temp, 1<<INT1;0x40
	out GICR, temp
	
	in temp, MCUCR
	;ori temp, 0x08
	ldi temp, 1<<ISC11 | 0<<ISC10 | 1<<ISC01 | 0<<ISC00
	out MCUCR, temp
	
	sei
	
	clr temp

forever:
   nop
   nop       ; Infinite loop.
   nop       ; Define your main system
   nop       ; behaviour here
   rjmp forever

int1_handler:
	ldi temp, 0<<INT1
	out GICR, temp
	
	;call read_serial
	ori result, 0x01
	call display
	call delay_baud
	ldi result, 0x00
	call display
	call delay_baud
	call delay_baud
	call delay_baud
	call delay_baud
	call delay_baud
	call delay_baud
	call delay_baud
	call delay_baud
	call delay_baud
	call delay_baud
	call delay_baud
	call delay_baud
	call delay_baud
	call delay_baud
	call delay_baud
	call delay_baud
	
	ldi temp, 1<<INT1
	out GICR, temp
	reti
	
Delay:
	push r16
	push r17
	push r18
	clr r16
	clr r17
	clr r18
inner:
   dec r16
   nop
   nop
   nop
   nop
   nop
   nop
   cpse r16, r18
   rjmp inner
   clr r16
outer:
	dec r17
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	cpse r17, r18
	rjmp inner
	pop r18
	pop r17
	pop r16
	ret
	
	
read_serial:
	call delay_baud_half 	;Shifts our sampler, so the sampler is clear of transitions.
		
	ldi temp2, 0x08			;Number of data bits to detect.		
read_bit:			
	call delay_baud         ;Delay by baud_period
	in temp, PINd           ;Read from portc, into temp
	andi temp, 0x08         ;AND result with 10000000, so only pin 7 remains.
	rol temp                ;Rotate bit 7 from temp into  carry.   (ie -> 1000 0000 -> C = 1, temp = 0000 00000)  Rotating will move all bits to the left
	rol temp 	;6
	rol temp 	;5
	rol temp 	;4
	rol temp 	;3
	ror result              ;Rotate bit from carry into bit 7 of result (ie -> 0000 0000 C = 1 -> result = 1000 0000) Rotating will move all bits to the right
	dec temp2               ;Decrement our data bit counter
	brne read_bit           ;If no more bits, then continue on, otherwise go back and read the next bit.
	
	call delay_baud         ;Delay by baud period. After the data bits, we should expect a stop bit (HIGH).
	in temp, PINd           ;Read portc into temp
 	andi temp, 0x08         ;Only interested in pin7, so and with 1000 0000
 	ldi temp2, 0x08         ;Load temp2 with comparison
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
	brne db_h_l                     ; if not equal to zero, redo the loop again, otherwise return (2 cycles).
	ret




