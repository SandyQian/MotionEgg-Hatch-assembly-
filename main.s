#include <xc.inc>

extrn	UART_Setup, UART_Transmit_Message  ; external subroutines
extrn	spi_setup, spi_transmit_write, spi_transmit_read
;extrn   delay, bdelay, bbdelay, huge   ;import does not work...
	
;psect	udata_acs   ; reserve data space in access ram

psect	udata_acs   ; reserve data space in access ram
data_from_acc:    ds 1    ; reserve one byte for a counter variable
    
    acc_reg_add equ 0x40	    ;ACC_CONF
    acc_reg_data equ 0x10
psect	acc_code,class=CODE   	
main:
    org 0x0
    goto start
    
    org 0x100   
start:
    call writeto_acc
    goto 0x0
    
writeto_acc: 
    movlw acc_reg_add         ; Load accelerometer register address
    call spi_transmit_write      ; Write register address to acc
    
    movlw acc_reg_data       ; Load accelerometer register data
    call spi_transmit_write      ; Write register data to acc
    return 
    
readfrom_acc:
    movlw acc_reg_add		; Load accelerometer register address
    call spi_transmit_read      ; Write register address
    movwf data_from_acc, A       ; Write register data to access ram
    return 
end main

	