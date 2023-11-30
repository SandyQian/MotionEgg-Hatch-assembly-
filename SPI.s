#include <xc.inc>

global  spi_setup, spi_transmit_write, spi_transmit_read

    
spi_setup:                             ; Set Clock edge to negative
    bcf CKE2                                  ; CKE bit in SSP2STAT, 
                                             ; MSSP enable; CKP=1; SPI master, clock=Fosc/64 (1MHz)
    movlw (SSP2CON1_SSPEN_MASK)|(SSP2CON1_CKP_MASK)|(SSP2CON1_SSPM1_MASK)
    movwf SSP2CON1, A
                                              ; SDO2 output; SCK2 output
    bcf TRISD, PORTD_SDO2_POSN, A          ; SDO2 output
    bcf TRISD, PORTD_SCK2_POSN, A          ; SCK2 output
    return
    
spi_transmit_write:		         ; Start transmission of data (assumed data held in W already)
    movwf SSP2BUF, A                      ; write data to output buffer
    call wait_transmit
    return
    
spi_transmit_read:
    movf SSP2BUF, W, A
    call wait_transmit 
    return
    
wait_transmit:                               ; Wait for transmission to complete 
    btfss SSP2IF                           ; check interrupt flag to see if data has been sent completely
    bra wait_transmit
    bcf SSP2IF                             ; clear interrupt flag
    return
    
