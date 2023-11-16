	#include <xc.inc>

psect	code, abs
	
main:
	org	0x0
	goto	start

	org	0x100		    ; Main code starts here at address 0x100
start:
	movlb 0x0F
	
	bsf REPU   ;does attaching a=1 at the end same as setting BSR?
	clrf LATE, 1
	movlw 0x0F
	movwf TRISE, A    ;0-3 inputs and 4-7 outputs ;pull-up reg set properly 
	
	movlw 	0x0
	movwf	TRISC, A
	
	bra 	test
;loop:
	;movff 	0x06, PORTC
	;incf 	0x06, W, A
	
	
test:
	;movwf	0x06, A	    ; Test for end of loop condition
	;movlw 	0x63
	;cpfsgt 	0x06, A
	;bra 	loop		    ; Not yet finished goto start of loop again
	call bbdelay
	goto 	0x0		    ; Re-run program from start

delay:
	decfsz 0xFF, A
	bra delay 
	return
	
bdelay: 
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay
	return 
	
bbdelay: 
	call bdelay
	call bdelay
	call bdelay
	call bdelay
	call bdelay
	call bdelay
	return 

hugedelay: 
	call bbdelay 
	call bbdelay    ;C:\Program Files\Microchip\xc8\v2.45\pic\include\proc
        call bbdelay 
	return

	end	main

	
