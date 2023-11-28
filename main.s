#include <xc.inc>
	
global	keyval, low_bits
extrn	UART_Setup, UART_Transmit_Message  ; external subroutines
extrn	LCD_Setup, LCD_Write_Message, LCD_Clear_Display
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
    org 0x0
    goto start
    
    org 0x100
start:		    ; Main code starts here at address 0x100
	
	; ******* Main program (the Keypad part) *****
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
	
b_1:
	movlw 0x77
	CPFSEQ PORTD, A
	bra b_c
	call LCDs
	call outLCD
	call hugedelay 
	goto 0x0
	
b_c:
	movlw 0xEE
	CPFSEQ PORTD, A
	goto 0x0
	call LCDs
	call clearLCD
	call hugedelay 
	goto 	0x0
	
	
	
			    ; Re-run program from start
	
	; ******* Main program (the LCD part) *****
	; moving table from program memory to RAM
		; ******* Programme FLASH read Setup Code ***********************
LCDs:	
	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	call	UART_Setup	; setup UART
	call	LCD_Setup	; setup UART
	goto	LCDtable_read

LCDtable_read:
	lfsr	0, myArray	; Load FSR0 with address in RAM	
	movlw	low highword(myTable)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(myTable)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(myTable)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	myTable_l	; bytes to read
	movwf 	counter, A		; our counter register
	
	
loop: 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter, A		; count down to zero
	bra	loop		; keep going until finished
	return
	
	 
outUART:			; output message to UART
	movlw	0x00	
	lfsr	2, myArray      ; Load file select register with content of myArray. '2' is the labelling number of FS reg being used 
	call	UART_Transmit_Message
	return 

	
outLCD:				; output message to LCD
	movlw	myTable_l	
	addlw	0xff		; adjust length value of the message sent (don't send the final carriage return to LCD)
	lfsr	2, myArray
	call	LCD_Write_Message
	return

clearLCD:			    ; Clear the LCD display
	call LCD_Clear_Display
	return
	
	;goto	$		; goto current line in code

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

	