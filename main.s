#include <xc.inc>

extrn	UART_Setup, UART_Transmit_Message  ; external subroutines
extrn	spi_setup, spi_transmit_write, spi_transmit_read
extrn   delay, bdelay, bbdelay, hugedelay   
    
extrn   set_up_acc, reset_step, readfrom_acc, set_normal_mode,set_sensitive_mode, set_robust_mode
extrn   set_pmu, reset_int, enable_step_detector, enable_int, map_int
extrn	set_up_uart, print_I, print_E, print_EC, print_R, clear_screen
	
;psect	udata_acs   ; reserve data space in access ram
    
psect	udata_acs   ; reserve data space in access ram
data_from_acc_z0:    ds 1   
data_from_acc_z1:    ds 1  
delay_count:ds 1    ; reserve one byte for counter in the delay routine
    
    ;for data write
    control_byte equ 0b01000000   ;write to & 0x40 => 0 1000000
    ;for data read
    control_byte2 equ 0b10000000   ;read from & 0x78 => 1 1000000
  
    milestone_step equ 0x0F     ;15 high-knees to make crack on egg
    goal_step equ 0x1E		;30 high-knees to hatch the egg


      
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
    call set_up_uart
   
    call clear_screen
    call clear_screen
    call print_I    ;print game name and instruction
    
    call hugedelay 
    call hugedelay
    call hugedelay
    call hugedelay 
    
    call set_up_acc	;manage configuration of accelerometer
    call set_normal_mode
    ;call set_sensitive_mode
    ;call set_robust_mode
   
    call clear_screen
    call print_E	;print egg table 	
    
    call reset_step	;reset step

    call loop1	;loop to reach milestone step
    call clear_screen      
    call print_EC	;print egg-crack table 
    
    call loop2	;loop to reach goal step
    call clear_screen	 ;clear screen
    call print_R	 ;3rd UART image
    
    goto $
 
loop1: 
    call set_pmu        ;needed for the measurement unit to function normally 
    call readfrom_acc
    movlw milestone_step
    cpfsgt LATH, A
    bra loop1
    return
    
loop2:    
    call readfrom_acc
    movlw goal_step
    cpfsgt LATH, A
    bra loop2
    return

    
end main