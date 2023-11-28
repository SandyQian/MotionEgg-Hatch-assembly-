; Include the necessary header file for the specific PIC18 device
#include p18f87k22.inc

; Define configuration bits
config WDTEN = OFF       ; Disable Watchdog Timer
config FOSC = HS         ; High-speed oscillator
config LVP = OFF         ; Low-voltage programming disabled
config DEBUG = OFF       ; Disable debugging

; Define equates for the used registers
system equ 0x00           ; Register to store system configuration bits

; Code segment
    org 0x00                ; Reset vector
    goto main               ; Jump to the main code

; Interrupt vector locations (not used in this example)
    org 0x08                ; High priority interrupt vector
    goto highpriorityisr

    org 0x18                ; Low priority interrupt vector
    goto lowpriorityisr

; Main code
main:
    bsf status, rp0         ; Select bank 1
    movlw 0x00              ; Load value for system configuration register
    movwf system            ; Write to system configuration register
    bcf status, rp0         ; Select bank 0

    call system_initialize  ; Call the initialization function

mainloop:
    ; Add your application code here

    goto mainloop           ; Infinite loop

; Interrupt service routines (not used in this example)
highpriorityisr:
    retfie

lowpriorityisr:
    retfie

