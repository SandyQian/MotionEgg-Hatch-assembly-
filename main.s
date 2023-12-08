#include <xc.inc>

extrn	UART_Setup, UART_Transmit_Message  ; external subroutines
extrn	spi_setup, spi_transmit_write, spi_transmit_read
extrn   delay, bdelay, bbdelay, hugedelay   
	
;psect	udata_acs   ; reserve data space in access ram
    
psect	udata_acs   ; reserve data space in access ram
data_from_acc:    ds 1    ; reserve one byte for a counter variable
    
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
    
    
    bcf	  TRISE, 0

    call spi_setup
    
   
    ;call reset_acc
    
    
    call instructto_acc
   
    ;call bdelay
   
    ;movlw 0x80
    movlw step_conf1_r
    call readfrom_acc
    movwf   PORTH, A       ; Write register data to access ram
   
    movlw step_conf2_r
    call readfrom_acc
    movwf PORTJ, A       ; Write register data to access ram

    ;call hugedelay
    goto 0x0
    
instructto_acc: 
    bcf PORTE, 0, A      ;enable acce (cs pin connect to RE0)
    
    movlw step_conf1         ; Load accelerometer register address
    call spi_transmit_write      ; Write register address to acc
    
    movlw 0x1d       ; Load accelerometer register data
    call spi_transmit_write      ; Write register data to acc
    
    bsf PORTE, 0, A
    
    bcf PORTE, 0, A 
    movlw step_conf2         ; Load accelerometer register address
    call spi_transmit_write      ; Write register address to acc
    
    movlw 0x07       ; Load accelerometer register data
    call spi_transmit_write      ; Write register data to acc
    
    ;movlw 0x7E
    ;call spi_transmit_write 
    
    ;movlw 0x2B
    ;call spi_transmit_write 
    
    bsf PORTE, 0, A
    ;call hugedelay
    return 

;Code that write control byte and read data byte(s) from address 
readfrom_acc:
    
    bcf PORTE, 0, A    ;enable acce (cs/RE0 pulled low by master)
                           
    call spi_transmit_write
    call spi_transmit_read
    
    ;call spi_transmit_read
    
    ;movlw 0x00
    ;movwf SSP1BUF, A
    ;movlw 0x10 
    ;call spi_transmit_read      ; Read register data
   
    bsf PORTE, 0, A      ;disable acce (cs/RE0 pulled high by master
    ;call hugedelay
    ;movwf data_from_acc
    
    return 
reset_acc:
    bcf PORTE, 0, A        ;enable acce (cs pin connect to RE0)
    
    movlw 0x7E         ; Load accelerometer register address
    call spi_transmit_write      ; Write register address to acc
    
    movlw 0xB2     ; Load accelerometer register data
    call spi_transmit_write      ; Write register data to acc
    
    bsf PORTE, 0, A
    return     
end main

