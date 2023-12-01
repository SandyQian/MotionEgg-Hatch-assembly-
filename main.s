#include <xc.inc>

extrn	UART_Setup, UART_Transmit_Message  ; external subroutines
extrn	spi_setup, spi_transmit_write, spi_transmit_read
extrn   delay, bdelay, bbdelay, hugedelay   
	
;psect	udata_acs   ; reserve data space in access ram
    
psect	udata_acs   ; reserve data space in access ram
data_from_acc:    ds 1    ; reserve one byte for a counter variable
    
    acc_reg_add equ 0x40	    ;ACC_CONF
    acc_reg_data equ 0x01
 
    acc_reg_add_1 equ 0x16
 
    acc_dummy_add equ 0x7F
 

psect	code, abs ;class=CODE   	
main:
    org 0x0
    goto start
    
    org 0x100   
start:
    ;movlw 0xFF
    ;movwf TRISD,A

    call spi_setup
    
    call dummy_read 
    call instructto_acc
   
    ;call readfrom_acc
    ;call hugedelay
    goto 0x00
    
dummy_read: 
    bsf PORTE, 0         ;Enable accelo ; cs pin connect to RE0.
    
    movlw acc_dummy_add         ; Load accelerometer register address
    call spi_transmit_write      ; Write register address to acc
   
    call spi_transmit_read      ; Write register data to acc
    
    bcf PORTE, 0
    ;call hugedelay
    return 
    
instructto_acc: 
    bsf PORTE, 0        ;cs pin connect to RE0
    
    movlw acc_reg_add         ; Load accelerometer register address
    call spi_transmit_write      ; Write register address to acc
    
    movlw acc_reg_data       ; Load accelerometer register data
    call spi_transmit_write      ; Write register data to acc
    
    bcf PORTE, 0
    ;call hugedelay
    return 
    
readfrom_acc:
    
    bsf PORTE, 0       
    
                            ; Send dummy data to trigger the SPI communication
    call spi_transmit_read  ; Transmit dummy data

    movlw acc_reg_add_1		
    call spi_transmit_write      ; Select accelerometer register address
    call spi_transmit_read      ; Read register data
    
    bcf PORTE, 0
    movwf PORTD, A       ; Write register data to access ram
    ;call hugedelay
    ;movwf data_from_acc
    
    return 
    
end main

	