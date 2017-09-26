;******************************
;***	4x3 Keypad Handler   ****
;*****************************
;This program is intened for use with the ATMEGA32,
;where PORTC is connected directly to a 4x3 keypad.
;(12 buttons). This program assumes no external pull
;up or pull down resistors have been used. Hence this
;program enables the pull up resistors for PORTC. The
;value of the key pressed will be displated on PORTB via
; LED's.
;The keypad used here is connected as follows:
;
;1 -> 1--2--3
;6 -> 4--5--6
;5 -> 7--8--9
;3 -> *--0--#
;     |--|--|
;     2  0  4
;
;This program will scan each column seperatly. This will be
;done by setting all the rows to be inputs (pulled high), while
;the columns are outputs (normally high). The program will
;continuously scan through the columns (by setting it to 0),
;such that when a key is pressed in that column, the input will
;come back low. Then a key is deteceted. Next the scan code
;has to be converted, for this I simply used a table, and I loop
;through. Where the element is scan code, and the index is the
;converted number. Start is 10 and hash is 11.

;2256 - Introduction into Embedded Systems - 2017
;Callum Jones
;RMIT

.include "C:\2256\VMLAB\include\m32def.inc"

.def  temp  =r16   		;Set up some registers
.def  temp2 =r19
.def delay_reg = r18
.def array_count =r22


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
  	ldi temp, high(RAMEND) ;Initialise the stack pointer to end of ram. This is because the stack pointer
  	out SPH, temp     	  ;decrements when items are pushed onto it. As we are not concerned about memory
  	ldi temp, low(RAMEND)  ;at this stage, this is perfectly fine.
  	out SPL, temp
  	
  	ldi temp, 0xff  		  ;Portb will be used entirely as an output (8 LED's).
  	out ddrb, temp         ;Data direction register - 1 -> set pin as output, 0 -> set pin as input.
  	out portb, temp        ;Turn all LED's on.
  	call delay             ;Delay
  	call delay
	ldi temp, 0x00         ;Turn all LED's off.
	out portb, temp
	
	ldi temp, 0x15         ;Setting up Portc. Read introcution above.
	out ddrc, temp         ;DDRC 1 for output, 0 for input.
	ldi temp, 0xff         ;For every pin that has been set up as an input, this will enable the internal pull
	out portc, temp        ;up resistor. Please see the manual.

;*****************
;forever:
;	Essentially this loops through the stages of pressing a key
;	Read the key (doesn't return until one is pressed), then
;	convert the scan code into an understandable number,
;	(binary/hex). The program then displays it to portb,
;	before delaying and restarting.
;*****************
forever:
   call wait_for_key		;Does what it says. Returns a key into temp
   call convert         ;Converts the scan code into a number from the keypad
   call display         ;Displays number onto portb
   call delay           ;Delays
rjmp forever


;*****************
;wait_for_key:
;	This function continuously loops around, scanning
;	individual rows, looking for a key. When a key is
;	detected, the loop is broken.	
;*****************
wait_for_key:
;Column 1                                                                            ;2
	ldi temp, 0xfb 		;First Column. Recall that pin 2 is the first column -> 1111 1011
	ldi temp2, 0xfb      ;A register to compare to.
	out portc, temp      ;Output required for column 1.
	call delay           ;Let output settle and capture key press.
	in temp, pinc        ;When reading an input, pinc must be used, not portc.
	cp temp, temp2       ;If the input, is the same as what was sent out...
	brne key_pressed     ;Continue, otherwise a key has been pressed, so move to key pressed.
	
;Column 2
	ldi temp, 0xfe
	ldi temp2, 0xfe
	out portc, temp
	call delay
	in temp, pinc
	cp temp, temp2
	brne key_pressed

;Column 3	
	ldi temp, 0xef
	ldi temp2, 0xef
	out portc, temp
	call delay
	in temp, pinc
	cp temp, temp2
	brne key_pressed
	rjmp wait_for_key
key_pressed:				;If a key is pressed, return to main loop and continue.
	ret

;*********************
;convert:
;	This takes the scan stored in temp, from the wait key press sub
;  routine, and converts it into the correct number in binary/hex.
;	eg, '1' should be 0000 0001, not 0111 1001 (scan code).
; 	Basically the table at the end of this file contains all the scan
;	codes in order. This routine iterates through the table in order
;	until it finds the matching scan code. When it does, the array counter,
;	which is incremented every loop, is taken as the output.
;*********************	
Convert:
   ldi	 ZH, high(Tble<<1)    ;Set the Z pointer to the table address. The address is shifted to the right, so
   ldi	 ZL, low(Tble<<1)     ;that we can access each byte from program memory individual, instead of 2 bytes at a time.
   clr array_count     			; start array_counter at zero

convert_loop:
   andi   TEMP, $7F
	LPM temp2, Z  			; Now load a byte from table in memory pointed to by Z (r31:r30)
	INC ZL
   cp temp2 , Temp      ;Compare value from prgram memory (table) to scan code.
   brne continue_loop   ;Not equal, continue going through table.
	MOV Temp, array_count ;Otherwise, move array counter into the temp register, which is the output.
   ret

continue_loop:				
	INC array_count	  	;Increment the array counter
	cpi ZL, low(Tble<<1)+12	;Check to see if its the end of the table (table is 12 bytes long) (0-9 + * + #) = 10+2=12 bytes
	brne convert_loop	;If not the end of the loop, go back and check the next byte in the table.
	ldi Temp, 0xFF    ;If it is the end of the table, then an error has occured, a wrong scan code has been obtained.
	ret

;***********************
;display:
;	displays the result from convert (from the keypad) to portb.
;***********************
display:
	out portb, temp
	ret

;***********************
;delay:
;		delays the processor for a small amount of time.
;		Time is about:
;		256*256*4 cycles*83.3ns = 21mS (roughly).
;***********************	
delay:
	push temp
	push temp2
	push delay_reg
	clr temp
	clr temp2
	clr delay_reg
inner_loop:
	dec temp
	cp temp, delay_reg
	brne inner_loop
outer_loop:
	clr temp
	dec temp2
	cp temp2, delay_reg
	brne inner_loop
	pop delay_reg
	pop temp2
	pop temp
	ret


;Table containing the scan codes. The index of the scan code, represents the number on the
;keypad. Eg, the number 2 is 0x7C -> 0111 1100 (scan code from reading the pins). 	
Tble:
.db $76, $79, $7C, $6D, $3B, $3E, $2F, $5B, $5E, $4F, $73, $67
	




