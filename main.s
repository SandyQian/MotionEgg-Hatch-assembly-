#include <xc.inc>
	
global	keyval, low_bits
extrn	UART_Setup, UART_Transmit_Message  ; external subroutines
extrn	LCD_Setup, LCD_Write_Message
;extrn   delay, bdelay, bbdelay, huge   ;import does not work...
	
psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine
low_bits:   ds 1
keyval:     ds 1
    
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
myArray:    ds 0x80 ; reserve 128 bytes for message data

psect	data    
	; ******* myTable, data in programme memory, and its length *****
myTable:
	db	'H','e','l','l','o',' ','W','o','r','l','d','!',0x0a
					; message, plus carriage return
	myTable_l   EQU	13	; length of data
	align	2

psect	code, abs
	
main:
	org	0x0
	goto	start

	org	0x100		    ; Main code starts here at address 0x100
start:
    
	
	movlb 0x0F  ;BSR --> Bank 15
	bsf REPU   ;Enable pull-up resistors (Q:does attaching a=1 at the end same as setting BSR?)
	movlb 0x0F  ;BSR --> Bank 15
	
	movlw 0x0F
	movwf TRISE, A    ;0-3 inputs and 4-7 outputs ;pull-up reg set properly 
	clrf LATE, A
	movlw 	0x0
	movwf	TRISD, A
	
	call hugedelay
	movff PORTE, low_bits, A
	
	movlw 0xF0
	movwf TRISE, A
	
	call hugedelay
	
	movf PORTE, W, A
	
	iorwf low_bits, W, A
	movwf keyval, A
	
	call hugedelay
	nop
	movf keyval, W, A
	movwf PORTD, A
	
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

	
