;*********************************
;***	RS232 Transmitter Code  ****
;*********************************
;This program is intened for use with the ATMEGA32,
;where pin 8 of portb is used for transmitting serial,
;over a wired or wireless link. Portc is used in this
;program for the keypad (4x3 -> 12 key)

;RS232 Settings:
;Baud - 9600
;Stop Bit - 1 or 2 (Won't affect the program, unless your sending serial really quickly, in which case stop bits is 1)
;Data Bits - 8
;No Parity Bits.

;2256 - Introduction into Embedded Systems - 2017
;Callum Jones
;RMIT


.include "C:\2256\VMLAB\include\m32def.inc"

;The program must start at this file, org 0x00 is used to specify that this code
;will be placed at 0x00 in program memory. Also see bottom of the file for other includes.
;Note, that they are included, after this code is defined.	
.org 0x00

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
   nop       ; Initialize here ports, stack pointer,
   nop       ; cleanup RAM, etc.
   nop       ;
   nop

	ldi temp, low(RAMEND)
	out SPL, temp
	ldi temp, high(RAMEND)
	out SPH, temp
	
	ldi temp, 0x80
	out DDRB, temp
	out PORTB, temp
	
	ldi	TEMP, $15     ;See the keypad project folder on github for more information
   out   DDRC, TEMP    ; set up keypad ports
   ldi	TEMP, $FF     ; Enable Pullup resistors
   out	PORTC, temp


forever:
   nop
   nop
   call Delay 				;Give everything some time to recover
   call wait_for_key    ;Wait for a key, stored in temp
   call Convert         ;Convert scan code in temp, to a binary equivalent of the key pressed.

   push temp2 				;Push onto stack, not really necessary, oh well.
	ldi temp2, 0x0A      ;Ok so I will be using the ascii character set to send serial, therefore the converted number must be converted to ascii before sending.
	cp temp, temp2       ;Check to see if 10 was pressed ('*').
	brne check_2         ;If not check if has was pressed.
	ldi temp, 0x2A       ;If so, move the ascii code for '*' (0x2A) into temp.
	mov ser_out, temp    ;Move temp into the serial out register, so it can be sent over a serial link
	jmp continue_main_loop
check_2:
   ldi temp2, 0x0B
   cp temp, temp2        ;Was '#' pressed (11 (0x0B))?
   brne is_number        ;If not, it must be a number.
   ldi temp, 0x23        ;If so, this is the ascii for '#'.
   mov ser_out, temp     ;Move ascii code into serial out register and continue main loop.
   jmp continue_main_loop
is_number:
	ldi temp2, 0x30        ;Ok if the key pressed is a number, then simply just add 0x30 to the number, which gives the ascii code.
	add temp, temp2        ;This is because in ascii the numbers 0-9 map to 0x30 -0x39
	mov ser_out, temp      ;Move it into serial out, so it can be sent over serial link.
continue_main_loop:
	pop temp2              ;Pop off the stack.
   call transmit_serial   ;Transmit contents of ser out register over the link.
   call DelayBig          ;Delay for quite some time, so that Reciver has time to write to the LCD.
   nop       ; behaviour here
rjmp forever

;These are the other files, which contain key sub routines, just helps clean up the code.
.include "defs.asm"
.include "TX.asm"
.include "keypad.asm"
.include "delays.asm"





