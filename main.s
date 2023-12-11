#include <xc.inc>

extrn	UART_Setup, UART_Transmit_Message  ; external subroutines
extrn	spi_setup, spi_transmit_write, spi_transmit_read
extrn   delay, bdelay, bbdelay, hugedelay   
	
;psect	udata_acs   ; reserve data space in access ram
    
psect	udata_acs   ; reserve data space in access ram
data_from_acc1:    ds 1    ; reserve one byte for a counter variable
data_from_acc2:    ds 1    
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
    
    milestone_step equ 0x80
    goal_step equ 0x05		;number of steps to complet game
      
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
    
    call spi_setup
    
    call reset_acc
    
    call set_up_acc

    ;call bbdelay   
    
    call readfrom_acc
    ;movwf PORTH, A
    ;call loop1	;loop to reach milestone step
    ;call loop2	;loop to reach goal step
    
    goto 0x0
 
;loop1: 
;    ;call bbdelay
;    call readfrom_acc
;    movlw milestone_step
;    cpfsgt PORTH, A
;    bra loop1
;    return
    
;loop2: 
;    call hugedelay
;    call readfrom_acc
;    movlw goal_step
;    cpfsgt data_from_acc1, A
;    bra loop2
;    return
    
    
set_up_acc:              ;set up step counter to normal mode: 
    bcf PORTE, 0, A      ;enable acce (cs pin connect to RE0)
    
    movlw step_conf1         ; Load accelerometer register address
    call spi_transmit_write      ; Write register address to acc
    
    movlw 0x2D       ; Load accelerometer register data
    call spi_transmit_write      ; Write register data to acc
    bsf PORTE, 0, A
    
    bcf PORTE, 0, A  
    movlw step_conf2         ; Load accelerometer register address
    call spi_transmit_write      ; Write register address to acc
    
    movlw 0x08      ; Load accelerometer register data
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
                           
    ;movlw step_cnt2
    movlw 0b10000011		   ; address for pmu
    call spi_transmit_write      ; Select accelerometer register address
    call spi_transmit_read      ; Read register data
    movwf PORTH, A
       
    bsf PORTE, 0, A
    nop
    nop
    
    bcf PORTE, 0, A
    ;movlw step_cnt1
    movlw 0b10010010		; address for acc_x
    call spi_transmit_write     ; Select accelerometer register address
    call spi_transmit_read      ; Read register data
    movwf PORTJ, A 
 
    bsf PORTE, 0, A      ;disable acce (cs/RE0 pulled high by master
    ;call hugedelay
    ;movwf data_from_acc
    
    return 
    
end main

	