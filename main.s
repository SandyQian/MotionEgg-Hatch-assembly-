#include <xc.inc>

extrn	UART_Setup, UART_Transmit_Message  ; external subroutines
extrn	spi_setup, spi_transmit_write, spi_transmit_read
extrn   delay, bdelay, bbdelay, hugedelay   
	
;psect	udata_acs   ; reserve data space in access ram
    
psect	udata_acs   ; reserve data space in access ram
data_from_acc_z0:    ds 1   
data_from_acc_z1:    ds 1   
counter:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine
    
    ;for data write
    control_byte equ 0b01000000   ;write to & 0x40 => 0 1000000
    ;for data read
    control_byte2 equ 0b10000000   ;read from & 0x78 => 1 1000000
 
    cmd		equ 0x7E	 ;address for cmd (cmd, write)
    chip_id	equ 0b10000000   ;address for chip_id (chip_id, read)
    acc_x_0	equ 0b10010010   ;address for acc_x (0x12, read, LSB)
    acc_x_1	equ 0b10010011   ;address for acc_x (0x13, read, MSB)
    acc_y_0	equ 0b10010100   ;address for acc_y (0x14, read, MSB)
    acc_y_1	equ 0b10010101   ;address for acc_y (0x15, read, MSB)
    acc_z_0	equ 0b10010110   ;address for acc_z (0x16, read, LSB)
    acc_z_1	equ 0b10010111   ;address for acc_z (0x17, read, MSB)
  
    
    step_conf0	equ 0b01111010   ;write to 0x7a
    step_conf1	equ 0b01111011   ;write to 0x7b
    step_conf0_r	equ 0b11111010   ;write to 0x7a
    step_conf1_r	equ 0b11111011   ;write to 0x7b
    step_cnt1	equ 0b11111000	 ;read from 0x78
    step_cnt0	equ 0b11111001	 ;read from 0x79
    int_en2	equ 0x52	;write to 0x52
    int_out_ctrl  equ 0x53	;write to 0x53
    int_map2  equ  0x57
  
    milestone_step equ 0b00001000
    goal_step equ 0x10		;number of steps to complet game
 
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
myArray:    ds 0x80 ; reserve 128 bytes for message data
EscArray:   ds 0x03

psect	data    
	; ******* myTableEC, data in programme memory, and its length *****
	
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
	

	myTable_l   EQU	200	; length of data
	align	2
	
EscTbl: 
	db	0x0A, 0x0D, 0x1b,'[','2','J' 
	EscTbl_l    EQU  6
	align	2
      
psect	code, abs ;class=CODE   	

main:
    org 0x0
    goto start
    
    org 0x100   
start:
    movlw 0x00
    movwf TRISH, A
    movlw 0x02
    movwf PORTH, A
    movlw 0x00
    movwf TRISJ, A
    movlw 0x02
    movwf PORTJ, A
    
    bcf	  TRISE, 0, A
	
    call spi_setup	;set up SPI tranmission
    call set_up_uart
    
    call uart_Esc       ;clear screen
    call start_uart0	;1st UART image 
    call uart_loop	
    
    call set_up_acc	;manage configuration of accelerometer
    ;call step_enable
    call reset_step	;reset step  
   
    call loop1	;loop to reach milestone step
    
    call uart_Esc       ;clear screen
    call start_uart1	;2nd UART image
    call uart_loop	
    
    call loop2	;loop to reach goal step
    
    call uart_Esc	 ;clear screen
    call start_uart2	 ;3rd UART image
    call uart_loop
    ;movlw 0b10000000
    ;call readfrom_acc
    ;call loop2
    goto $
 
loop1: 
    call readfrom_acc
    movlw milestone_step
    cpfsgt LATH, A
    bra loop1
    return
    
loop2:    
    call readfrom_acc
    movlw goal_step
    cpfsgt LATH, A
    bra loop2
    return
    
 ;set up step counter to normal mode:     
set_up_acc:             
    ;Choose step config (step confi register 1)
    bcf PORTE, 0, A	 ;enable acce (cs pin connect to RE0)
    
    movlw step_conf0         ; Load accelerometer register address
    call spi_transmit_write      ; Write register address to acc
    
    movlw 0x2D       ; Load accelerometer register data
    call spi_transmit_write      ; Write register data to acc
    bsf PORTE, 0, A	; disable acc (cs pin connect to RE0)	    
    
   ;Choose step config (step confi register 2)
    bcf PORTE, 0, A  
    movlw step_conf1         
    call spi_transmit_write     
    
    movlw 0b00001000
    call spi_transmit_write     
    bsf PORTE, 0, A

    ;Power mode : Suspend -> Normal mode (acceleration)  
    bcf PORTE, 0, A  
    movlw cmd      ;Address fo command reg (cmd) 
    call spi_transmit_write     
    
    movlw 0b00010001      ;Sets the PMU mode for the accelerometer to normal (01 end)    
    call spi_transmit_write     
    bsf PORTE, 0, A
    
    ;Power mode : Suspend -> Normal mode (gyro)  
    bcf PORTE, 0, A  
    movlw cmd      ;Address fo command reg (cmd) 
    call spi_transmit_write     
    
    movlw 0b00010101      ;Sets the PMU mode for the accelerometer to normal (01 end)    
    call spi_transmit_write     
    bsf PORTE, 0, A
    
    ;Power mode : Suspend -> Normal mode (mag)  
    bcf PORTE, 0, A  
    movlw cmd      ;Address fo command reg (cmd) 
    call spi_transmit_write     
    
    movlw 0b000011001      ;Sets the PMU mode for the accelerometer to normal (01 end)    
    call spi_transmit_write     
    bsf PORTE, 0, A
    
    ;reset inerrupt pin
    bcf PORTE, 0, A	 ;enable acce (cs pin connect to RE0)
    movlw cmd
    ;movlw 0x57         ; Load accelerometer register address
    call spi_transmit_write      ; Write register address to acc

    movlw 0xB1
    ;movlw 0b00000001      ; Load accelerometer register data
    call spi_transmit_write      ; Write register data to acc
    bsf PORTE, 0, A	; disable acc (cs pin connect to RE0)

    ;enable step detector
    bcf PORTE, 0, A	 ;enable acce (cs pin connect to RE0)
    
    movlw int_en2         ; Load accelerometer register address
    call spi_transmit_write      ; Write register address to acc
    
    movlw 0b00001000       ; Load accelerometer register data
    call spi_transmit_write      ; Write register data to acc
    bsf PORTE, 0, A	; disable acc (cs pin connect to RE0)	
   
   ;enable inerrupt pin2
    bcf PORTE, 0, A	 ;enable acce (cs pin connect to RE0)
    
    movlw int_out_ctrl         ; Load accelerometer register address
    call spi_transmit_write      ; Write register address to acc
    
    movlw 0b10000000       ; Load accelerometer register data
    call spi_transmit_write      ; Write register data to acc
    bsf PORTE, 0, A	; disable acc (cs pin connect to RE0)
;;    
    ;map step detector to interrupt pin2
    bcf PORTE, 0, A	 ;enable acce (cs pin connect to RE0)
   
    movlw int_map2        ; Load accelerometer register address
    call spi_transmit_write      ; Write register address to acc

    movlw 0b00000001      ; Load accelerometer register data
    call spi_transmit_write      ; Write register data to acc
    bsf PORTE, 0, A	; disable acc (cs pin connect to RE0)
; 
    return


reset_step:
    bcf PORTE, 0, A       
    
    movlw cmd         ; Load accelerometer register address
    call spi_transmit_write      ; Write register address to acc
    
    movlw 0xB2     ; Load accelerometer register data
    call spi_transmit_write      ; Write register data to acc
    
    bsf PORTE, 0, A
    return 

;Code that write control byte and read data byte(s) from address 
readfrom_acc:
    
    bcf PORTE, 0, A                      
    movlw step_cnt1                      ;address for step count  
    ;movlw chip_id
    call spi_transmit_write     
    call spi_transmit_read      ; Read register data
    movwf PORTH, A
    ;movwf data_from_acc_z0, A
    bsf PORTE, 0, A
    nop
    nop
    
    bcf PORTE, 0, A                       
    movlw acc_y_1         
    call spi_transmit_write     
    call spi_transmit_read      ; Read register data
    movwf PORTJ, A
    bsf PORTE, 0, A
    return 

set_up_uart:
		bcf	CFGS	; point to Flash program memory  
		bsf	EEPGD 	; access Flash program memory
		call	UART_Setup	; setup UART
		return

		start_uart0: 	    ;load the initial egg
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
start_uart1: 	    ;load the initial egg
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
start_uart2: 	    ;load the initial egg
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

uart_loop:   ;initial egg
		tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
		movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
		decfsz	counter, A		; count down to zero
		bra	uart_loop		; keep going until finished
			
		movlw	myTable_l	; output message to UART
		lfsr	2, myArray
		call	UART_Transmit_Message
		return

uart_Esc:	lfsr	0,  EscArray	; Load FSR0 with address in RAM	
	movlw	high(EscTbl)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(EscTbl)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	EscTbl_l	; bytes to read
	movwf 	counter, A		; our counter register
Escloop: 	
	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter, A		; count down to zero
	bra	Escloop		; keep going until finished
	
	movlw	EscTbl_l	; output message to UART
	lfsr	2, EscArray
	call	UART_Transmit_Message
	return 
		

    
end main