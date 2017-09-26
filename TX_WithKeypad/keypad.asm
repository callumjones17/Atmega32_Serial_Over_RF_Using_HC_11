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
	
	
;Table containing the scan codes. The index of the scan code, represents the number on the
;keypad. Eg, the number 2 is 0x7C -> 0111 1100 (scan code from reading the pins). 	
Tble:
.db $76, $79, $7C, $6D, $3B, $3E, $2F, $5B, $5E, $4F, $73, $67
