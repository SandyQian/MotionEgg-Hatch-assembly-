#include <xc.inc>

extrn	UART_Setup, UART_Transmit_Message  ; external subroutines
extrn	spi_setup, spi_transmit_write, spi_transmit_read
extrn   delay, bdelay, bbdelay, hugedelay   
	
;psect	udata_acs   ; reserve data space in access ram
    
psect	udata_acs   ; reserve data space in access ram
data_from_acc:    ds 1    ; reserve one byte for a counter variable
    
    ;for data write
    control_byte equ 01000000   ;write to & inv (0x40) => 0 1000000
    ;for data read
    control_byte2 equ 11000000   ;read from & inv (0x40) => 1 1000000
    command       equ 00000001
psect	code, abs ;class=CODE   	
main:
    org 0x0
    goto start
    
    org 0x100   
start:
    movlw 0xFF
    movwf TRISD,A

    call spi_setup
    call readfrom_acc
    movwf PORTD, A       ; Write register data to access ram
    ;call hugedelay
    goto 0x00
    
instructto_acc: 
    bcf PORTE, 0       ;enable acce (cs pin connect to RE0)
    
    movlw control_byte         ; Load accelerometer register address
    call spi_transmit_write      ; Write register address to acc
    
    movlw 0x10       ; Load accelerometer register data
    call spi_transmit_write      ; Write register data to acc
    
    bsf PORTE, 0
    ;call hugedelay
    return 

;Code that write control byte and read data byte(s) from address 
readfrom_acc:
    
    bcf PORTE, 0, A    ;enable acce (cs/RE0 pulled low by master)
                            
    movlw control_byte2
    call spi_transmit_read
    
    ;movlw 0x00
    ;movwf SSP1BUF, A
    ;movlw 0x10 
    ;call spi_transmit_read      ; Read register data
   
    bsf PORTE, 0, A      ;disable acce (cs/RE0 pulled high by master
    ;call hugedelay
    ;movwf data_from_acc
    
    return 
    
end main

	