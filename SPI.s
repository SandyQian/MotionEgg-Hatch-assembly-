#include <xc.inc>

global  spi_setup, spi_transmit
psect	udata_acs   ; reserve data space in access ram
SPI_counter: ds    1	    ; 

psect	spi_code,class=CODE
org 0x00 
spi_setup:
    movlw 00110000b                                    ; Enable SPI mode, clock, master
    movwf SSPCON
    bsf TRISB						;same as 11111111 -> w -> TRISB
    

spi_transmit:  
    movf PortB, W                                            ; Read PortB value
    movwf SSPBUF                                         ;  Transmit (Output) value to slave
    nop
    nop
    nop
    goto spi_transmit                                           ; Repeat the process
    
