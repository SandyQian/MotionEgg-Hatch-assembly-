#include <xc.inc>

global  spi_setup, spi_transmit_write, spi_transmit_read

psect	SPI_code,class=CODE
    
spi_setup:                             ; Set Clock edge to negative
    bcf CKE1                                  ; CKE bit in SSP1STAT, 
                                             ; MSSP enable; CKP=1; SPI master, clock=Fosc/64 (1MHz)
    movlw (SSP1CON1_SSPEN_MASK)|(SSP1CON1_CKP_MASK)|(SSP1CON1_SSPM1_MASK)
    movwf SSP1CON1, A
                                              ; SDO2 output; SCK2 output
    bcf TRISC, PORTC_SDO1_POSN, A          ; SDO1 output
    bsf TRISC, PORTC_SDI1_POSN, A
    bcf TRISC, PORTC_SCK1_POSN, A          ; SCK1 output
    bsf GIE
    return
    
spi_transmit_write:		         ; Start transmission of data (assumed data held in W already)
    movwf SSP1BUF, A                      ; write data to output buffer
    call wait_transmit
    return
    
spi_transmit_read: 
    movwf SSP1BUF, A  
    call wait_transmit
    movf SSP1BUF, W, A
    return
    
wait_transmit:                               ; Wait for transmission to complete 
    btfss PIR1, 3                           ; check interrupt flag to see if data has been sent completely
    bra wait_transmit
    bcf PIR1, 3                             ; clear interrupt flag
    return
    
