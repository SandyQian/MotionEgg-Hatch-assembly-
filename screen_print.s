#include <xc.inc>

extrn UART_Setup, UART_Transmit_Message
global set_up_uart, print_I, print_E, print_EC, print_R, print_P, print_C, print_F, clear_screen

psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
myArray:    ds 0x80 ; reserve 128 bytes for message data
EscArray:   ds 0x03
    
psect	data    
counter:    ds 1    ; reserve one byte for a counter variable
    
; ******* myTableEC, data in programme memory, and its length *****
;game instruction
myTableI:                                                                                                          ;ps: ctrl+shift+c = comment multiple lines 
                          ;'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R'	
	db  	0x0A, 0x0D,' ','M','O','T','I','O','N',' ','E','G','G','H','A','T','C','H',' ',' '    ;1
	db  	0x0A, 0x0D,' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '    ;2
	db	0x0A, 0x0D,' ',' ',' ',' ','G','A','M','E',' ','R','U','L','E',' ',' ',' ',' ',' '    ;3
	db	0x0A, 0x0D,' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '    ;4  
	db	0x0A, 0x0D,' ',' ','C','l','e','a','r',' ','3','0',' ','h','i','g','h',' ',' ',' '    ;5
	db	0x0A, 0x0D,' ',' ','k','n','e','e','s',' ','t','o',' ','h','a','t','c','h',' ',' '    ;6
	db	0x0A, 0x0D,' ',' ','a','n',' ','e','g','g','!',' ',' ',' ',' ',' ',' ',' ',' ',' '    ;7
	db	0x0A, 0x0D,' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '    ;8
	db	0x0A, 0x0D,' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '    ;9
	db  	0x0A, 0x0D,' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '    ;10

;egg
myTableE:                                                                                                          ;ps: ctrl+shift+c = comment multiple lines 
                  ;'A','B','C','D','E','F','G','H','I','J','K','L','M','N','#','P','Q','R'	
	db  	0x0A, 0x0D,' ',' ',' ',' ',' ',' ','#','#','#','#','#','#',' ',' ',' ',' ',' ',' '    ;1
	db  	0x0A, 0x0D,' ',' ',' ','#','#','#',' ',' ',' ',' ',' ',' ','#','#','#',' ',' ',' '    ;2
	db	0x0A, 0x0D,' ',' ','#','#',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','#','#',' ',' '    ;3
	db	0x0A, 0x0D,' ','#','#',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','#','#',' '    ;4  
	db	0x0A, 0x0D,' ','#',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','#',' '    ;5
	db	0x0A, 0x0D,'#','#',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','#','#'    ;6
	db	0x0A, 0x0D,' ','#','#',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','#','#',' '    ;7
	db	0x0A, 0x0D,' ',' ',' ','#','#',' ',' ',' ',' ',' ',' ',' ',' ','#','#',' ',' ',' '    ;8
	db	0x0A, 0x0D,' ',' ',' ',' ',' ','#','#','#','#','#','#','#','#',' ',' ',' ',' ',' '    ;9
	db  	0x0A, 0x0D,' ',' ',' ','G','A','M','E',' ',' ','S','T','A','R','T','!',' ',' ',' '    ;10

;cracked egg
myTableEC:                                                                                                           
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
	db 	0x0A, 0x0D,' ',' ','A','L','M','O','S','T',' ','T','H','E','R','E','!',' ',' ',' '    ;10

;rabbit
myTableR:                                                                                                           
	           ;'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R'   
	db  	0x0A, 0x0D,' ',' ',' ','#','#','#',' ',' ',' ',' ','#','#','#',' ',' ',' ',' ',' '    ;1
	db  	0x0A, 0x0D,' ',' ',' ','#',' ','#',' ',' ',' ',' ','#',' ','#',' ',' ',' ',' ',' '    ;2
	db	0x0A, 0x0D,' ',' ','#','#',' ','#','#','#','#','#','#',' ','#','#',' ',' ',' ',' '    ;3
	db	0x0A, 0x0D,' ',' ','#',' ','#',' ',' ',' ',' ',' ',' ','#',' ','#',' ',' ',' ',' '    ;4  
	db	0x0A, 0x0D,' ',' ','#',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','#',' ',' ',' ',' '    ;5
	db	0x0A, 0x0D,' ',' ','#','#','#','#','#','#','#','#','#','#','#','#',' ',' ',' ',' '    ;6
	db	0x0A, 0x0D,' ',' ',' ','#','#',' ',' ',' ',' ',' ',' ','#','#',' ',' ',' ',' ',' '    ;7
	db	0x0A, 0x0D,' ',' ',' ',' ','#','#','#','#','#','#','#','#',' ',' ',' ',' ',' ',' '    ;8
	db	0x0A, 0x0D,' ',' ',' ',' ',' ',' ','#',' ',' ','#',' ',' ',' ',' ',' ',' ',' ',' '    ;9
	db  	0x0A, 0x0D,' ',' ','G','A','M','E',' ','F','I','N','I','S','H','!',' ',' ',' ',' '   ;10

;penguin like
myTableP:                                                                                                           
	           ;'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R'   
	db	0x0A, 0x0D,' ',' ',' ',' ',' ','#','#','#','#','#','#','#',' ',' ',' ',' ',' ',' '    ;1
	db	0x0A, 0x0D,' ',' ',' ','#','#',' ',' ',' ',' ',' ',' ',' ','#','#',' ',' ',' ',' '    ;2
	db	0x0A, 0x0D,' ',' ','#',' ',' ','.',' ',' ',' ',' ',' ','.',' ',' ','#',' ',' ',' '    ;3
	db	0x0A, 0x0D,'#','#','#',' ',' ',' ',' ',' ','-',' ',' ',' ',' ',' ','#','#','#',' '    ;4  
	db	0x0A, 0x0D,' ',' ','#',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','#',' ',' ',' '    ;5
	db	0x0A, 0x0D,' ',' ',' ','#','#','#','#','#','#','#','#','#','#','#',' ',' ',' ',' '    ;6
	db	0x0A, 0x0D,' ',' ',' ',' ',' ','#',' ',' ',' ',' ',' ','#',' ',' ',' ',' ',' ',' '    ;7
	db	0x0A, 0x0D,' ',' ',' ',' ','#','#',' ',' ',' ',' ',' ','#','#',' ',' ',' ',' ',' '    ;8
	db	0x0A, 0x0D,' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '    ;9
	db  	0x0A, 0x0D,' ',' ','G','A','M','E',' ','F','I','N','I','S','H','!',' ',' ',' ',' '   ;10

;the third animal
myTableC:                                                                                                           
	           ;'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R'   
	db  	0x0A, 0x0D,' ',' ',' ',' ','#',' ',' ',' ',' ',' ',' ','#',' ',' ',' ',' ',' ',' '    ;1
	db  	0x0A, 0x0D,' ',' ',' ','#',' ','#',' ',' ',' ',' ','#',' ','#',' ',' ',' ',' ',' '    ;2
	db	0x0A, 0x0D,' ',' ','#','#',' ','#','#','#','#','#','#',' ','#','#',' ',' ',' ',' '    ;3
	db	0x0A, 0x0D,' ',' ','#',' ','>',' ',' ',' ',' ',' ',' ','<',' ','#',' ',' ',' ',' '    ;4  
	db	0x0A, 0x0D,' ',' ','#',' ',' ',' ',' ','-','-',' ',' ',' ',' ','#',' ',' ',' ',' '    ;5
	db	0x0A, 0x0D,' ',' ','#','#','#','#','#','#','#','#','#','#','#','#',' ',' ',' ',' '    ;6
	db	0x0A, 0x0D,' ',' ',' ',' ',' ',' ','#',' ',' ','#',' ',' ',' ',' ',' ',' ',' ',' '    ;7
	db	0x0A, 0x0D,' ',' ',' ',' ',' ','#',' ',' ',' ',' ','#',' ','#',' ',' ',' ',' ',' '    ;8
	db	0x0A, 0x0D,' ',' ',' ',' ',' ','#','#','#','#','#','#','#',' ',' ',' ',' ',' ',' '    ;9
	db  	0x0A, 0x0D,' ',' ','G','A','M','E',' ','F','I','N','I','S','H','!',' ',' ',' ',' '   ;10

;the fourth animal
myTableF:                                                                                                           
	           ;'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R'   
	db	0x0A, 0x0D,' ',' ',' ',' ',' ','#','#','#','#','#','#','#',' ',' ',' ',' ',' ',' '    ;1
	db	0x0A, 0x0D,'h','a',' ','#','#',' ',' ',' ',' ',' ',' ',' ','#','#',' ',' ',' ',' '    ;2
	db	0x0A, 0x0D,' ',' ','#',' ',' ','.',' ',' ',' ',' ',' ','.',' ',' ','#',' ',' ',' '    ;3
	db	0x0A, 0x0D,'#','#','#',' ',' ',' ',' ',' ','-',' ',' ',' ',' ',' ','#','#','#',' '    ;4  
	db	0x0A, 0x0D,' ',' ','#',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','#',' ',' ',' '    ;5
	db	0x0A, 0x0D,' ',' ',' ','#','#','#','#','#','#','#','#','#','#','#',' ',' ',' ',' '    ;6
	db	0x0A, 0x0D,' ',' ',' ',' ',' ','#',' ',' ',' ',' ',' ','#',' ',' ',' ',' ',' ',' '    ;7
	db	0x0A, 0x0D,' ',' ',' ',' ','#','#',' ',' ',' ',' ',' ','#','#',' ',' ',' ',' ',' '    ;8
	db	0x0A, 0x0D,' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '    ;9
	db  	0x0A, 0x0D,' ',' ','G','A','M','E',' ','F','I','N','I','S','H','!',' ',' ',' ',' '   ;10
	
	


	myTable_l   EQU	200	; length of data
	align	2

;Clear screen (VT100 escape code) 
EscTbl: 
	db	0x0A, 0x0D, 0x1b,'[','2','J' 
	EscTbl_l    EQU  6
	align	2

set_up_uart:
    bcf	CFGS	; point to Flash program memory  
    bsf	EEPGD 	; access Flash program memory
    call	UART_Setup	; setup UART
    return

print_I:        ;print out instruction table 
    call start_uart0
    call uart_loop
    return 

print_E:	;print egg table 
    call start_uart1
    call uart_loop
    return

print_EC:	;print egg-with-cracks table 
    call start_uart2
    call uart_loop
    return

print_R:	;print rabbit table 
    call start_uart3
    call uart_loop
    return

print_P:
    call start_uart4
    call uart_loop
    return
    
print_C:
    call start_uart5
    call uart_loop
    return
    
print_F:
    call start_uart6
    call uart_loop
    return
    
    

clear_screen:   ;clear screen using VT100 escape code 
    call uart_Esc
    call Escloop
   
start_uart0: 	    ;load the initial egg
    lfsr	0, myArray	; Load FSR0 with address in RAM	
    movlw	low highword(myTableI)	; address of data in PM
    movwf	TBLPTRU, A		; load upper bits to TBLPTRU
    movlw	high(myTableI)	; address of data in PM
    movwf	TBLPTRH, A		; load high byte to TBLPTRH
    movlw	low(myTableI)	; address of data in PM
    movwf	TBLPTRL, A		; load low byte to TBLPTRL
    movlw	myTable_l	; bytes to read
    movwf 	counter, A		; our counter register
    return 
    
start_uart1: 	    ;load the initial egg
    lfsr	0, myArray	; Load FSR0 with address in RAM	
    movlw	low highword(myTableE)	; address of data in PM
    movwf	TBLPTRU, A		; load upper bits to TBLPTRU
    movlw	high(myTableE)	; address of data in PM
    movwf	TBLPTRH, A		; load high byte to TBLPTRH
    movlw	low(myTableE)	; address of data in PM
    movwf	TBLPTRL, A		; load low byte to TBLPTRL
    movlw	myTable_l	; bytes to read
    movwf 	counter, A		; our counter register
    return
    
start_uart2: 	    ;load the cracked egg
    lfsr	0, myArray	; Load FSR0 with address in RAM	
    movlw	low highword(myTableEC)	; address of data in PM
    movwf	TBLPTRU, A		; load upper bits to TBLPTRU
    movlw	high(myTableEC)	; address of data in PM
    movwf	TBLPTRH, A		; load high byte to TBLPTRH
    movlw	low(myTableEC)	; address of data in PM
    movwf	TBLPTRL, A		; load low byte to TBLPTRL
    movlw	myTable_l	; bytes to read
    movwf 	counter, A		; our counter register
    return   
    
start_uart3: 	    ;load the rabbit
    lfsr	0, myArray	; Load FSR0 with address in RAM	
    movlw	low highword(myTableR)	; address of data in PM
    movwf	TBLPTRU, A		; load upper bits to TBLPTRU
    movlw	high(myTableR)	; address of data in PM
    movwf	TBLPTRH, A		; load high byte to TBLPTRH
    movlw	low(myTableR)	; address of data in PM
    movwf	TBLPTRL, A		; load low byte to TBLPTRL
    movlw	myTable_l	; bytes to read
    movwf 	counter, A		; our counter register
    return

start_uart4:	;load the penguin
    lfsr	0, myArray	; Load FSR0 with address in RAM	
    movlw	low highword(myTableP)	; address of data in PM
    movwf	TBLPTRU, A		; load upper bits to TBLPTRU
    movlw	high(myTableP)	; address of data in PM
    movwf	TBLPTRH, A		; load high byte to TBLPTRH
    movlw	low(myTableP)	; address of data in PM
    movwf	TBLPTRL, A		; load low byte to TBLPTRL
    movlw	myTable_l	; bytes to read
    movwf 	counter, A		; our counter register
    return
    
start_uart5:	;load the penguin
    lfsr	0, myArray	; Load FSR0 with address in RAM	
    movlw	low highword(myTableC)	; address of data in PM
    movwf	TBLPTRU, A		; load upper bits to TBLPTRU
    movlw	high(myTableC)	; address of data in PM
    movwf	TBLPTRH, A		; load high byte to TBLPTRH
    movlw	low(myTableC)	; address of data in PM
    movwf	TBLPTRL, A		; load low byte to TBLPTRL
    movlw	myTable_l	; bytes to read
    movwf 	counter, A		; our counter register
    return
    
    
start_uart6:	;load the penguin
    lfsr	0, myArray	; Load FSR0 with address in RAM	
    movlw	low highword(myTableF)	; address of data in PM
    movwf	TBLPTRU, A		; load upper bits to TBLPTRU
    movlw	high(myTableF)	; address of data in PM
    movwf	TBLPTRH, A		; load high byte to TBLPTRH
    movlw	low(myTableF)	; address of data in PM
    movwf	TBLPTRL, A		; load low byte to TBLPTRL
    movlw	myTable_l	; bytes to read
    movwf 	counter, A		; our counter register
    return
    
uart_loop:   ;initial egg
    tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
    movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
    decfsz	counter, A		; count down to zero
    bra	uart_loop		; keep going until finished

    movlw	myTable_l	; output message to UART
    lfsr	2, myArray
    call	UART_Transmit_Message
    return

uart_Esc:
    lfsr	0,  EscArray	; Load FSR0 with address in RAM	
    movlw	high(EscTbl)	; address of data in PM
    movwf	TBLPTRH, A		; load high byte to TBLPTRH
    movlw	low(EscTbl)	; address of data in PM
    movwf	TBLPTRL, A		; load low byte to TBLPTRL
    movlw	EscTbl_l	; bytes to read
    movwf 	counter, A		; our counter register
    return
Escloop: 	
    tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
    movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
    decfsz	counter, A		; count down to zero
    bra	Escloop		; keep going until finished

    movlw	EscTbl_l	; output message to UART
    lfsr	2, EscArray
    call	UART_Transmit_Message
    return 
		


