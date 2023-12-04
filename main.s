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

psect	code, abs ;class=CODE   	
main:
    org 0x0
    goto start
    
    org 0x100   
start:
    movlw 0xFF
    movwf TRISD,A

    call spi_setup
    call instructto_acc
    ;call readfrom_acc
    movwf PORTD, A       ; Write register data to access ram
    ;call hugedelay
    goto 0x00

;Code block that write data into the microprocessor
instructto_acc:    
    bsf PORTE, 0, A        ;enable acce (cs/RE0 pulled low by master)
    
    movlw acc_reg_add         ; Load accelerometer register address
    call spi_transmit_write      ; Write register address to acc
    movlw acc_reg_data       ; Load accelerometer register data
    call spi_transmit_write      ; Write register data to acc
    
    bcf PORTE, 0, A
    ;call hugedelay
    return 

;Code block that read data into the microprocessor
readfrom_acc:
    
    bsf PORTE, 0, A    ;enable acce (cs/RE0 pulled low by master)
                            
    movlw control_byte2		
    call spi_transmit_write 
    call spi_transmit_read      ; Read register data
    
    bcf PORTE, 0, A      ;disable acce (cs/RE0 pulled high by master
    ;call hugedelay
    ;movwf data_from_acc
    
    return 
    
end main

	