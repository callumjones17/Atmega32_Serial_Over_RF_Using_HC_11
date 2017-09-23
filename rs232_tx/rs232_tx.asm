; ******************************************************
; BASIC .ASM template file for AVR
; ******************************************************

.include "C:\2256\VMLAB\include\m32def.inc"

; Define here the variables
;

.org 0x00
.def  temp  = r16
.def SER_OUT = r17
.def SER_OUT_TEMP = r18
.equ delayBaud = 205
.def delay_reg = r20
.def temp2 = r19

; Define here Reset and interrupt vectors, if any
;
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
   ldi temp, low(RAMEND)  ;Init the stack pointer Low
   out SPL, temp
   ldi temp, high(RAMEND) ;Init the stack pointer high
   out SPH, temp
	ldi temp, 0x80         ; Init pin 0 of port B, which will be the serial port.
	out DDRB, temp
	call delay_baud
	ldi temp, 0x80
	out PORTB, temp		  ; Set the pin high, as a change from low to high initiates the serial protocol.
	
	ldi SER_OUT, 0x43      ;This is a test variable. In ascii it 0x43 is 'C'
	



forever:
   nop
   nop       ; Infinite loop.
   nop       ; Define your main system
   nop       ; behaviour here
   call Delay   ;Delay for a while before sending over the port again.
   call Delay
   call Delay
   call transmit_serial    ;Transmit using the serial interface.
   call delay_baud         ;Delay a bit more
   ldi SER_OUT, 0x43       ;Reset the output
   call Delay              ;Delay a bit more.

rjmp forever



transmit_serial:
   clr ser_out_temp		;Clear a temporary varible for use.

	ldi temp, 0xff			;Make serial port is already high.
	out portb, temp
	call delay_baud
	
	call delay_baud 			;Start bit requires a high to low change.
	ldi temp, 0x00
	out portb, temp
	
	push temp2
	ldi temp2, 0x08
	
write_bit:
	call delay_baud 			;Send First Bit
   ror ser_out
   ror ser_out_temp
	out portb, ser_out_temp
	dec temp2
	brne write_bit
	
	pop temp2
	
	call delay_baud			;Stop bit requires a high
	ldi temp, 0xff
	out portb, temp
	call delay_baud
	call delay_baud			;Technically, this is an extra stop bit. But a single stop bit reciever will also work.
	ret


;102uS = (205 * 6) + 5 * 83.33nS, baud rate is about 104uS	
delay_baud:
	ldi delay_reg, DelayBaud
db_l:
	dec delay_reg
	nop
	nop
	nop
	brne db_l
	ret


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





Delay_more:
         PUSH R16						
         PUSH R17
         PUSH R0
         CLR R0
         CLR R16
         CLR R17
L1:      DEC R16
			CPSE R16, R0
			RJMP L1	     ;4 cycles times 256 * 256 * 83.3 *10e-9 = about 21mS
			CLR R16		
L2:      DEC R17
         CPSE R17, R0
         RJMP L1			
;
         POP R0
         POP R17
         POP R16
         RET









