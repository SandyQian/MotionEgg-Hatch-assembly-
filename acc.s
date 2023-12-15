#include <xc.inc>

extrn	spi_setup, spi_transmit_write, spi_transmit_read
extrn   delay, bdelay, bbdelay, hugedelay   

global  set_up_acc, reset_step, readfrom_acc
global	set_normal_mode,set_sensitive_mode, set_robust_mode
global  set_pmu, reset_int, enable_step_detector, enable_int, map_int	
	
psect	udata_acs   ; reserve data space in access ram
data_from_acc_x0:    ds 1   
data_from_acc_x1:    ds 1	    
	;for data write
    control_byte equ 0b01000000   ;write to & 0x40 => 0 1000000
    ;for data read
    control_byte2 equ 0b10000000   ;read from & 0x78 => 1 1000000
 
    cmd		equ 0x7E	 ;address for cmd (cmd, write)
    chip_id	equ 0b10000000   ;address for chip_id (chip_id, read)
    acc_x_0	equ 0b10010010   ;address for acc_x (0x12, read, LSB)
    acc_x_1	equ 0b10010011   ;address for acc_x (0x13, read, MSB)
    acc_y_0	equ 0b10010100   ;address for acc_y (0x14, read, MSB)
    acc_y_1	equ 0b10010101   ;address for acc_y (0x15, read, MSB)
    acc_z_0	equ 0b10010110   ;address for acc_z (0x16, read, LSB)
    acc_z_1	equ 0b10010111   ;address for acc_z (0x17, read, MSB)
  
    
    step_conf0	equ 0b01111010   ;write to 0x7a
    step_conf1	equ 0b01111011   ;write to 0x7b
    step_conf0_r	equ 0b11111010   ;write to 0x7a
    step_conf1_r	equ 0b11111011   ;write to 0x7b
    step_cnt1	equ 0b11111000	 ;read from 0x78
    step_cnt0	equ 0b11111001	 ;read from 0x79
    int_en2	equ 0x52	;write to 0x52
    int_out_ctrl  equ 0x53	;write to 0x53
    int_map2  equ  0x57
  
psect	acc_code,class=CODE 

;set up for step counter to function   
set_up_acc:
    call reset_int
    call enable_step_detector
    call enable_int
    call map_int
    call set_pmu
    return
    
;set up step counter to normal mode: 
 set_normal_mode:
    ;Choose step config (step confi register 0)
    bcf PORTE, 0, A	 ;enable acce (cs pin connect to RE0)
    
    movlw step_conf0         ; Load accelerometer register address
    call spi_transmit_write      ; Write register address to acc
    movlw 0x15       ; Normal mode config0
    call spi_transmit_write      ; Write register data to acc
    bsf PORTE, 0, A	; disable acc (cs pin connect to RE0)	    
    
;Choose step config (step confi register 1)
    bcf PORTE, 0, A  
    movlw step_conf1         
    call spi_transmit_write   
    movlw 0b00001011    ; Normal mode config1
    call spi_transmit_write     
    bsf PORTE, 0, A
    
    return
    
;set up step counter to sensitive mode:    
set_sensitive_mode:
;Choose step config (step confi register 0)
    bcf PORTE, 0, A	 ;enable acce (cs pin connect to RE0)
    
    movlw step_conf0         ; Load accelerometer register address
    call spi_transmit_write      ; Write register address to acc
 
    movlw 0x2D       ; Sensitive mode config0
    call spi_transmit_write      ; Write register data to acc
    bsf PORTE, 0, A	; disable acc (cs pin connect to RE0)	    
    
;Choose step config (step confi register 1)
    bcf PORTE, 0, A  
    movlw step_conf1         
    call spi_transmit_write   
    
    movlw 0b00001000	; Sensitive mode config1
    call spi_transmit_write     
    bsf PORTE, 0, A
    
    return

;set up step counter to robust mode:
set_robust_mode: 
;Choose step config (step confi register 0)
    bcf PORTE, 0, A	 ;enable acce (cs pin connect to RE0)
 
    movlw step_conf0         ; Load accelerometer register address
    call spi_transmit_write      ; Write register address to acc
    
    movlw 0x1D       ; Robust mode config0   
    call spi_transmit_write      ; Write register data to acc
    bsf PORTE, 0, A	; disable acc (cs pin connect to RE0)	    
    
;Choose step config (step confi register 1)
    bcf PORTE, 0, A  
    movlw step_conf1         
    call spi_transmit_write   
    
    movlw 0b00001111	; Robust mode config1
    call spi_transmit_write     
    bsf PORTE, 0, A
    
    return


;set the step counter to 0    
reset_step:
    bcf PORTE, 0, A       
    
    movlw cmd         ; Load accelerometer register address
    call spi_transmit_write      ; Write register address to acc
    
    movlw 0xB2     ; Load accelerometer register data
    call spi_transmit_write      ; Write register data to acc
    
    bsf PORTE, 0, A
    return 
    
    
;read from the step counter and export value to H
readfrom_acc:
    
    bcf PORTE, 0, A                      
    movlw step_cnt1                      ;address for step count  
    ;movlw chip_id
    call spi_transmit_write     
    call spi_transmit_read      ; Read register data
    movwf PORTH, A
    ;movwf data_from_acc_z0, A
    bsf PORTE, 0, A
    nop
    nop
    
    bcf PORTE, 0, A                       
    movlw acc_x_0         
    call spi_transmit_write     
    call spi_transmit_read      ; Read register data
    andlw 0b00000011
    movwf data_from_acc_x0
   
    movf data_from_acc_x0, W, A
    andlw 0b00000001
    movwf PORTJ, A
    
    movf data_from_acc_x0, W, A
    andlw 0b00000010
    movwf PORTB, A
    
 
    bsf PORTE, 0, A
    return 
    
    
    
set_pmu:
 ;Power mode : Suspend -> Normal mode (acceleration)  
    bcf PORTE, 0, A  
    movlw cmd      ;Address fo command reg (cmd) 
    call spi_transmit_write     
    
    movlw 0b00010001      ;Sets the PMU mode for the accelerometer to normal (01 end)    
    call spi_transmit_write     
    bsf PORTE, 0, A
    
;Power mode : Suspend -> Normal mode (gyro)  
    bcf PORTE, 0, A  
    movlw cmd      ;Address fo command reg (cmd) 
    call spi_transmit_write     
    
    movlw 0b00010101      ;Sets the PMU mode for the gyroscope to normal (01 end)    
    call spi_transmit_write     
    bsf PORTE, 0, A
    
;Power mode : Suspend -> Normal mode (mag)  
    bcf PORTE, 0, A  
    movlw cmd      ;Address fo command reg (cmd) 
    call spi_transmit_write     
    
    movlw 0b00011001      ;Sets the PMU mode for the magnetometer to normal (01 end)    
    call spi_transmit_write     
    bsf PORTE, 0, A
    
    return
    
    
reset_int: 
;reset inerrupt pin
    bcf PORTE, 0, A	 ;enable acce (cs pin connect to RE0)
    movlw cmd
    ;movlw 0x57        
    call spi_transmit_write      ; Write register address to acc

    movlw 0xB1
    ;movlw 0b00000001      ; Load accelerometer register data
    call spi_transmit_write      ; Write register data to acc
    bsf PORTE, 0, A	; disable acc (cs pin connect to RE0)
    
    return
    
enable_step_detector:
;enable step detector
    bcf PORTE, 0, A	 ;enable acce (cs pin connect to RE0)
    
    movlw int_en2         ; step_interrupt address
    call spi_transmit_write     
    
    movlw 0b00001000       ; enable instruction
    call spi_transmit_write      ; Write register data to acc
    bsf PORTE, 0, A		
    
    return
    
    
enable_int:
;enable inerrupt pin2
    bcf PORTE, 0, A	 ;enable acce (cs pin connect to RE0)
    
    movlw int_out_ctrl         ; Load accelerometer register address
    call spi_transmit_write      ; Write register address to acc
    
    movlw 0b10000000       ; Load accelerometer register data
    call spi_transmit_write      ; Write register data to acc
    bsf PORTE, 0, A	; disable acc (cs pin connect to RE0)
    
    return
    
map_int:  
;map step detector to interrupt pin2
    bcf PORTE, 0, A	 ;enable acce (cs pin connect to RE0)
   
    movlw int_map2        ; Load accelerometer register address
    call spi_transmit_write      ; Write register address to acc

    movlw 0b00000001      ; Load accelerometer register data
    call spi_transmit_write      ; Write register data to acc
    bsf PORTE, 0, A	; disable acc (cs pin connect to RE0)
; 
    return
    
    
    

    
   

    
    
    
    
 
 