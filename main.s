#include <xc.inc>

extrn	UART_Setup, UART_Transmit_Message  ; external subroutines
extrn	spi_setup, spi_transmit_write, spi_transmit_read
extrn   delay, bdelay, bbdelay, hugedelay   
	
;psect	udata_acs   ; reserve data space in access ram
    
psect	udata_acs   ; reserve data space in access ram
data_from_acc_z0:    ds 1   
data_from_acc_z1:    ds 1   
test_data:		ds 1
counter:		 ds 1		; reserve one byte for a counter variable
    
    ;for data write
    control_byte equ 0b01000000   ;write to & 0x40 => 0 1000000
    ;for data read
    control_byte2 equ 0b10000000   ;read from & 0x78 => 1 1000000
 
    cmd		equ 0x7E	 ;address for cmd (cmd, write)
    acc_x_0	equ 0b10010010   ;address for acc_x (0x12, read, LSB)
    acc_x_1	equ 0b10010011   ;address for acc_x (0x13, read, MSB)
    acc_y_0	equ 0b10010100   ;address for acc_y (0x14, read, MSB)
    acc_y_1	equ 0b10010101   ;address for acc_y (0x15, read, MSB)
    acc_z_0		equ 0b10010110   ;address for acc_z (0x16, read, LSB)
    acc_z_1		equ 0b10010111   ;address for acc_z (0x17, read, MSB)
  
    
    step_conf0	equ 0b01111010   ;write to 0x7a
    step_conf1	equ 0b01111011   ;write to 0x7b
    step_conf0_r	equ 0b11111010   ;write to 0x7a
    step_conf1_r	equ 0b11111011   ;write to 0x7b
    step_cnt1	equ 0b11111000	 ;read from 0x78
    step_cnt0	equ 0b11111001	 ;read from 0x79
    
    milestone_step equ 0x08
    goal_step equ 0x10		;number of steps to complet game
 
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
accz_data:		ds 2
      
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
    call set_up_acc	;manage configuration of accelerometer
    call step_enable
    call reset_step	;reset step
    ;call bbdelay   
    
    
    
    ;call readfrom_acc
    ;call combine_bit
    call loop1
    ;movwf PORTH, A
    ;call loop1	;loop to reach milestone step
    ;call loop2	;loop to reach goal step
    
    goto $
 
loop1: 
    ;call bbdelay
    call readfrom_acc
    movlw milestone_step     ;skip if milesto
    cpfsgt LATH, A
    bra loop1
    return
    
loop2: 
    ;call hugedelay
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
    
    ;enable step detector
    bcf PORTE, 0, A	 ;enable acce (cs pin connect to RE0)
    
    movlw 0x52         ; Load accelerometer register address
    call spi_transmit_write      ; Write register address to acc
    
    movlw 0b00001000       ; Load accelerometer register data
    call spi_transmit_write      ; Write register data to acc
    bsf PORTE, 0, A	; disable acc (cs pin connect to RE0)	
;    
;;    ;enable inerrupt pin
    bcf PORTE, 0, A	 ;enable acce (cs pin connect to RE0)
    
    movlw 0x53         ; Load accelerometer register address
    call spi_transmit_write      ; Write register address to acc
    
    movlw 0b10000000       ; Load accelerometer register data
    call spi_transmit_write      ; Write register data to acc
    bsf PORTE, 0, A	; disable acc (cs pin connect to RE0)
;;    
;     ;map inerrupt pin
    bcf PORTE, 0, A	 ;enable acce (cs pin connect to RE0)
    ;movlw 0x7E
    movlw 0x57         ; Load accelerometer register address
    call spi_transmit_write      ; Write register address to acc

    ;movlw 0xB1
    movlw 0b00000001      ; Load accelerometer register data
    call spi_transmit_write      ; Write register data to acc
    bsf PORTE, 0, A	; disable acc (cs pin connect to RE0)
; 
    return

step_enable:
    bcf PORTE, 0, A       
    
    movlw cmd         ; Load accelerometer register address
    call spi_transmit_write      ; Write register address to acc
    
    movlw 0xB1     ; Load accelerometer register data
    call spi_transmit_write      ; Write register data to acc
    
    bsf PORTE, 0, A
    return 
 
;Instruction to reset step counter
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
    ;movlw 0b11000000                ;add for acc conf
    ;movlw step_conf1_r                     ;address for step conf2(read)
    ;movlw 0b10010010
    ;movlw  0b10000011	 ; address for pmu (0X03, read)
    ;movlw 0b11010010	; address int_en
    ;movlw   0b10010011		; address for acc_x (0x13, read, MSB)
    ;movlw acc_z_1         
   ;movlw 0b10010101		;address for acc_y (0x15, read, MSB)
    ;movlw 0b10000000
    ;movlw 0b11010010
    call spi_transmit_write     
    call spi_transmit_read      ; Read register data
    movwf PORTH, A
       
    bsf PORTE, 0, A
    nop
    nop
    
    bcf PORTE, 0, A
   ;movlw step_cnt1
   ;movlw 0b10010011		; address for acc_x (0x13,  read, MSB)
    movlw acc_y_1
    ;movlw 0b10000000
    call spi_transmit_write     ; Select accelerometer register address
    call spi_transmit_read      ; Read register data
    movwf PORTJ, A 
    bsf PORTE, 0, A
    nop
    nop
    call bbdelay
    ;movwf data_from_acc
    ;call hugedelay
    return 
    
;combine_bit:
;    
;    accz_l   EQU	2
;    
;    lfsr	0, accz_data	; Load FSR0 with address in RAM	
;    movff  PORTH, TBLPTRH, A	;load high byte to TBLPTRH
;    movff  PORTJ, TBLPTRL, A	;load low byte to TBLPTRL
;    movlw	accz_l	; bytes to read
;    movwf 	counter, A		; our counter register
;    
;loop: 
;    tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
;    movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
;    decfsz	counter, A		; count down to zero
;    bra	loop		; keep going until finished
;
;    movlw	accz_l	; output message to UART
;    lfsr	2, accz_data
;    call	UART_Transmit_Message
;
;   return
;    
end main