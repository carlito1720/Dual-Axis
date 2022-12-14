#include <xc.inc>

global	pulse_length1, pulse_length2
    
extrn	motor_Setup, move_motor1, move_motor2	    ; external motor subroutines
extrn	LCD_Setup, LCD_Write_Message, LCD_Write_Hex, marker, LCD_clear ; external LCD subroutines
extrn	ADC_Setup, ADC_Read			    ; exernal anolog to digital conveter subroutines
extrn	initial_setup, long_move1, long_move2,best_position1, best_position2, secondary_loop
extrn	start_LDR, LDR_compare_loop, best_high_word, best_low_word
extrn	hextodec, sol

psect	udata_acs   ; reserve data space in access ram
delay_count:   ds 1 ; reserve one byte for counter in the delay routine
pulse_length1: ds 1 ; reserve 1 byte for duty cycl of motor 1  
pulse_length2: ds 1	; reserve 1 byte for duty cycle of motor 2    
motor_cnt_l:	ds 1	; reserve 1 byte for variable LCD_cnt_l
motor_cnt_h:	ds 1	; reserve 1 byte for variable LCD_cnt_h
motor_cnt_ms:	ds 1	; reserve 1 byte for ms counter
motor_tmp:	ds 1	; reserve 1 byte for temporary use
motor_counter:	ds 1	; reserve 1 byte for counting through nessage   
sleepcount:	ds 1	; reserve 1 byte for sleep counter
    
psect	code, abs
	
	
rst: 	org 0x0
 	goto	setup

	; ******* Programme FLASH read Setup Code ***********************
setup:	
	call	motor_Setup	; setup motors
	call	LCD_Setup	; setup UART
	call	ADC_Setup
	movlw	0x00
	movwf	best_low_word, A
	movwf	best_high_word, A
	movwf	pulse_length1, A
	movwf	pulse_length2, A
	movlw	0x0B
	
	movwf	pulse_length2, A
	call	long_move2
	
	movlw	0x04
	movwf	pulse_length1, A
	call	long_move1

	goto	start
	
	
; ******* Main programme ****************************************
start:
	call	ADC_Read
	call	initial_setup
	goto	lets_go_boys
    lets_go_boys:
	call	LCD_clear
	call	hextodec
	movf	sol,W,A
	call	LCD_Write_Hex
	call	sleep_setup
	call	ADC_Read
	call	LDR_compare_loop
	movwf	0x00
	cpfseq	marker
	call	secondary_loop
	goto	lets_go_boys
	return
	


long_asss_delay:
	movlw	0xFF
	call	motor_delay_ms
	movlw	0xFF
	call	motor_delay_ms
	movlw	0xFF
	call	motor_delay_ms
	movlw	0xFF
	call	motor_delay_ms
	movlw	0xFF
	call	motor_delay_ms
	movlw	0xFF
	call	motor_delay_ms
	movlw	0xFF
	call	motor_delay_ms
	movlw	0xFF
	call	motor_delay_ms
	return
	




motor_delay_ms:		    ; delay given in ms in W
	movwf	motor_cnt_ms, A
motorlp2:	
	movlw	100	    ;0.08 ms delay
	call	motor_delay_x4us	
	decfsz	motor_cnt_ms, A
	bra	motorlp2
	return
    
motor_delay_x4us:		    ; delay given in chunks of 4 microsecond in W
	movwf	motor_cnt_l, A	; now need to multiply by 16
	swapf   motor_cnt_l, F, A	; swap nibbles
	movlw	0x0f	    
	andwf	motor_cnt_l, W, A ; move low nibble to W
	movwf	motor_cnt_h, A	; then to LCD_cnt_h
	movlw	0xf0	    
	andwf	motor_cnt_l, F, A ; keep high nibble in LCD_cnt_l
	call	motor_delay
	return

motor_delay:			; delay routine	4 instruction loop == 250ns	    
	movlw 	0x00		; W=0
motorlp1:	decf 	motor_cnt_l, F, A	; no carry when 0x00 -> 0xff
	subwfb 	motor_cnt_h, F, A	; no carry when 0x00 -> 0xff
	bc 	motorlp1		; carry, then loop again
	return			; carry reset so return

		
move_to_best:
	movf	best_position1, A
	movwf	pulse_length1, A
	call	move_motor1	    ; move motor 1 back to the best position 
	movf	best_position2, A
	movwf	pulse_length2, A
	call	move_motor2	    ; move motor 2 back to the best position 

sleep_setup:
	movlw	0x05		; number of WDT timeouts 18ms
	movwf	sleepcount
	goto	sleeploop
	
sleeploop:
	sleep			; go to sleep until WDT wakeup (~2.3 seconds)
	decf	sleepcount	; decrement count, skip if 0
	movlw	0x00
	cpfseq	sleepcount
	goto	sleeploop	; goto sleep unitl count complete
	return
	
	end	 rst