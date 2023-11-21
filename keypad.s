#include <xc.inc>

psect	code, abs
low_bits:   ds 1
keyval:     ds 1
    
main:
	org	0x0
	goto	start

	org	0x100		    ; Main code starts here at address 0x100
start:
	movlb 0x0F
	bsf REPU   ;does attaching a=1 at the end same as setting BSR?
	movlb 0x00
	
	movlw 0x0F
	movwf TRISE, A    ;0-3 inputs and 4-7 outputs ;pull-up reg set properly 
	
	clrf LATE,1
	call bbdelay
	
	movff PORTE, low_bits
	
	movlw 0xF0
	movwf TRISE, A
	call bbdelay
	movf PORTE, W, A
	
	iorwf low_bits, W, A
	movwf keyval, A
	

	
	
;loop:
	;movff 	0x06, PORTC
	;incf 	0x06, W, A
	
	

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


