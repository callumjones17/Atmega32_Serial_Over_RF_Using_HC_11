








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
;DelayBig:
;	Calls a lot of 21mS delay routines
;	13 Delay_more's = 80*21mS = 273mS
;--------------------
DelayBig:
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



Delay:   call delay_more
         RET





