                                                   ; ******************************************************
; BASIC .ASM template file for AVR
; ******************************************************

.include "C:\2256\VMLAB\include\m32def.inc"

; Define here the variables
;
.def  temp  =r16
.def result =r17
.equ DelayBaud = 205  ;205 - original, 180 worked ok. 200, and 40 works well above 0x40
.equ DelayBaudHalf = 10 ;1 worked ok
.def delay_reg =r18
.def temp2 =r19

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
   reti      ; Addr $0E
   reti      ; Addr $0F
   reti      ; Addr $10

; Program starts here after Reset
;
start:
   nop
   nop

	clr temp
	clr temp2
	clr result
	clr delay_reg

	ldi temp, low(RAMEND)
	out SPL, temp
	ldi temp, high(RAMEND)
	out SPH, temp
	
	ldi temp, 0xFF
	out DDRB, temp
	ldi temp, 0xff
	out PORTB, temp
	
	ldi temp, 0x00
	out DDRC, temp
	ldi temp, 0x00
	out PORTC, temp

forever:
   nop
   nop       ; Infinite loop.
   nop       ; Define your main system
   nop       ; behaviour here
	call rx						
rjmp forever

rx:
 	in temp, PINC         ;Start bit?
 	andi temp, 0x80
 	ldi temp2, 0x80
 	cp temp, temp2
 	brne read_serial
 	ldi temp, 0x00
	ret
	
read_serial:
	call delay_baud_half
		
	ldi temp2, 0x08		
read_bit:			
	call delay_baud
	in temp, PINC
	andi temp, 0x80
	rol temp
	ror result
	dec temp2
	brne read_bit
	
	call delay_baud
	in temp, PINC          ;Stop bit?
 	andi temp, 0x80
 	ldi temp2, 0x80
 	cp temp, temp2
 	brne error_code
 	
 	call Delay_baud_half
 	call Display
 	call Delay_baud_half
	ret
error_code:
	ldi result, 0x55
	ret
	
	
	
Display:
	out portb, result
	ret	
	



delay_baud_half:
	ldi delay_reg, DelayBaudHalf
db_h_l:
	dec delay_reg
	nop
	nop
	nop
	brne db_h_l
	ret

;103uS = (205 * 6) + 5 * 83.33nS, baud rate is about 104uS	
delay_baud:
	ldi delay_reg, DelayBaud
db_l:
	dec delay_reg
	nop
	nop
	nop
	brne db_l
	ret
















