#include <xc.inc>

global delay, bdelay, bbdelay, hugedelay


delay:	
	decfsz  0xFF, A	; decrement until zero
	bra	delay
	return
	
bdelay: 
	call delay
	call delay
	call delay
	call delay
	call delay
	return
    
bbdelay: 
	call bdelay
	call bdelay
	call bdelay
	call bdelay
	call bdelay
	call bdelay
	call bdelay
	call bdelay
	call bdelay
	call bdelay
	return

hugedelay: 
	call bbdelay
	call bbdelay
	call bbdelay
	call bbdelay
	call bbdelay
	call bbdelay
	call bbdelay
	call bbdelay
	call bbdelay
	call bbdelay
	call bbdelay
	call bbdelay
	call bbdelay
	call bbdelay
	call bbdelay
	call bbdelay
	call bbdelay
	call bbdelay
	call bbdelay
	call bbdelay
	call bbdelay
	call bbdelay
	call bbdelay
	call bbdelay
	call bbdelay
	call bbdelay
	call bbdelay
	call bbdelay
	call bbdelay
	call bbdelay
	return
    
