#include <xc.inc>

extrn	UART_Setup, UART_Transmit_Message  ; external subroutines
extrn	spi_setup, spi_transmit_write, spi_transmit_read
extrn   delay, bdelay, bbdelay, hugedelay   
	
;psect	udata_acs   ; reserve data space in access ram
    
psect	udata_acs   ; reserve data space in access ram
data_from_acc1:    ds 1    ; reserve one byte for a counter variable
data_from_acc2:    ds 1   
counter:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine
    
    ;for data write
    control_byte equ 0b01000000   ;write to & 0x40 => 0 1000000
    ;for data read
    control_byte2 equ 0b10000000   ;read from & 0x78 => 1 1000000
    
    step_conf1	equ 0b01111010   ;write to 0x7a
    step_conf2	equ 0b01111011   ;write to 0x7b
    step_conf1_r  equ 0b11111010   ;write to 0x7a
    step_conf2_r  equ 0b11111011   ;write to 0x7b
    step_cnt1	equ 0b11111000	 ;read from 0x78
    step_cnt2	equ 0b11111001	 ;read from 0x79
    
    milestone_step equ 0x02
    goal_step equ 0x05		;number of steps to complet game
 
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
myArray:    ds 0x80 ; reserve 128 bytes for message data


psect	data    
	; ******* myTable, data in programme memory, and its length *****
myTable:
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
	db	0x0A, 0x0D,' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '    ;10
	;db	0x0A, 0x0D,' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '    ;11
	;db	0x0A, 0x0D,' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '    ;12
	;db	0x0A, 0x0D,' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '    ;13
						
	myTable_l   EQU	200	; length of data
	align	2
      
psect	code, abs ;class=CODE   	
main:
    org 0x0
    goto start
    
    org 0x100   
start:
    movlw 0x00
    movwf TRISH, A
    movlw 0x00
    movwf TRISJ, A
    
    bcf	  TRISE, 0, A
    call set_up_uart
    call start_uart1
    call uart_loop1
		
    call spi_setup
    call set_up_acc
   
    call bbdelay   
    call reset_acc
    
    call acc_loop1	;loop to reach milestone step
		;call start_uart2 
    ;call uart_loop2

    call acc_loop2	;loop to reach goal step
		;call start_uart3
    ;call uart_loop3
    
    goto $
 
acc_loop1: 
    call hugedelay
    call readfrom_acc
    movlw milestone_step
    cpfsgt data_from_acc1, A
    bra acc_loop1
    return
    
acc_loop2: 
    call hugedelay
    call readfrom_acc
    movlw goal_step
    cpfsgt data_from_acc1, A
    bra acc_loop2
    return

uart_loop1:   ;initial egg
    tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
    movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
    decfsz	counter, A		; count down to zero
    bra	uart_loop1		; keep going until finished

    movlw	myTable_l	; output message to UART
    lfsr	2, myArray
    call	UART_Transmit_Message
    return
	
set_up_uart:
    bcf	CFGS	; point to Flash program memory  
    bsf	EEPGD 	; access Flash program memory
    call	UART_Setup	; setup UART
    return

start_uart1: 	    ;load the initial egg
    lfsr	0, myArray	; Load FSR0 with address in RAM	
    movlw	low highword(myTable)	; address of data in PM
    movwf	TBLPTRU, A		; load upper bits to TBLPTRU
    movlw	high(myTable)	; address of data in PM
    movwf	TBLPTRH, A		; load high byte to TBLPTRH
    movlw	low(myTable)	; address of data in PM
    movwf	TBLPTRL, A		; load low byte to TBLPTRL
    movlw	myTable_l	; bytes to read
    movwf 	counter, A		; our counter register
    return
		  
set_up_acc:              ;set up step counter to normal mode: 
    bcf PORTE, 0, A      ;enable acce (cs pin connect to RE0)
    
    movlw step_conf1         ; Load accelerometer register address
    call spi_transmit_write      ; Write register address to acc
    
    movlw 0x15       ; Load accelerometer register data
    call spi_transmit_write      ; Write register data to acc
    
    movlw step_conf2         ; Load accelerometer register address
    call spi_transmit_write      ; Write register address to acc
    
    movlw 0x03       ; Load accelerometer register data
    call spi_transmit_write      ; Write register data to acc
    
    bsf PORTE, 0, A
    
    return 
    
reset_acc:
    bcf PORTE, 0, A        ;enable acce (cs pin connect to RE0)
    
    movlw 0x7E         ; Load accelerometer register address
    call spi_transmit_write      ; Write register address to acc
    
    movlw 0xB2     ; Load accelerometer register data
    call spi_transmit_write      ; Write register data to acc
    
    bsf PORTE, 0, A
    return 

;Code that write control byte and read data byte(s) from address 
readfrom_acc:
    
    bcf PORTE, 0, A    ;enable acce (cs/RE0 pulled low by master)
                           
    movlw step_cnt1
    call spi_transmit_write      ; Select accelerometer register address
    call spi_transmit_read      ; Read register data
		
    movwf data_from_acc1, A   
    bsf PORTE, 0, A
    
    bcf PORTE, 0, A
    movlw step_cnt2
    call spi_transmit_write      ; Select accelerometer register address
    call spi_transmit_read      ; Read register data
    movwf data_from_acc2, A 
 
    bsf PORTE, 0, A      ;disable acce (cs/RE0 pulled high by master
    ;call hugedelay
    ;movwf data_from_acc
    
    return 
    
end main