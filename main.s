#include <xc.inc>

extrn	UART_Setup, UART_Transmit_Message  ; external subroutines
	
psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine
    
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
myArray:    ds 0x80 ; reserve 128 bytes for message data

psect	data    
	; ******* myTable, data in programme memory, and its length *****
myTable:                                                                                                           
                  ;'A','B','C','D','E','F','G','H','I','J','K','L','M','N','#','P','Q','R'
	db  	0x0A, 0x0D,' ',' ',' ',' ',' ',' ','#','#','#','#','#','#',' ',' ',' ',' ',' ',' '    ;1
	db  	0x0A, 0x0D,' ',' ',' ','#','#','#',' ',' ',' ',' ',' ',' ','#','#','#',' ',' ',' '    ;2
	db	0x0A, 0x0D,' ',' ','#','#',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','#','#',' ',' '    ;3
	db	0x0A, 0x0D,' ','#','#',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','#','#',' '    ;4  (crack peak)
	db	0x0A, 0x0D,' ','#',' ','#',' ',' ',' ','#',' ',' ',' ','#',' ',' ',' ','#','#',' '    ;5
	db	0x0A, 0x0D,'#','#',' ',' ','#',' ','#',' ','#',' ','#',' ','#',' ','#',' ','#','#'    ;6  
	db	0x0A, 0x0D,' ','#','#',' ',' ','#',' ',' ',' ','#',' ',' ',' ','#',' ','#','#',' '    ;7  (crack bottom)
	db	0x0A, 0x0D,' ',' ',' ','#','#',' ',' ',' ',' ',' ',' ',' ',' ','#','#',' ',' ',' '    ;8
	db	0x0A, 0x0D,' ',' ',' ',' ',' ','#','#','#','#','#','#','#','#',' ',' ',' ',' ',' '    ;9
	db	0x0A, 0x0D,' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '    ;10
	;db	0x0A, 0x0D,' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '    ;11
	;db	0x0A, 0x0D,' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '    ;12
	;db	0x0A, 0x0D,' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '    ;13
		
		;' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',0x0a,
						

	myTable_l   EQU	200	; length of data
	align	2
    
psect	code, abs	
rst: 	org 0x0
 	goto	setup

	; ******* Programme FLASH read Setup Code ***********************
setup:	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	call	UART_Setup	; setup UART
	goto	start
	
	; ******* Main programme ****************************************
start: 	lfsr	0, myArray	; Load FSR0 with address in RAM	
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
		
	movlw	myTable_l	; output message to UART
	lfsr	2, myArray
	call	UART_Transmit_Message

	goto	$		; goto current line in code

	; a delay subroutine if you need one, times around loop in delay_count
delay:	decfsz	delay_count, A	; decrement until zero
	bra	delay
	return

	end	rst