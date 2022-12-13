#include <xc.inc>

global  start_LDR, LDR_compare_loop
   
extrn	test, move_motor1, move_motor2, ADC_Read, LDR_compare_loop, ADC_Setup, pulse_length1, pulse_length2, motor_Setup
    
psect	routine_code, class=CODE
    
psect	udata_acs   ; reserve data space in access ram

best_low_word: ds 1 ; reserve one byte for the best high word
best_high_word:ds 1 ; reserve one byt for the byte low word
test:	       ds 1

start_LDR:		; read in value of LDR from port RA0
	movf	ADRESH, W, A		; read in high word
	movwf	best_high_word, A
	movf	ADRESL, W, A
	movwf	best_low_word, A
	return
	
LDR_compare_loop:
	movlw	0x00
	movwf	test, A
	movf	ADRESH, W, A
	cpfseq	best_high_word, A
	call	comp
	movlw	0x01
	cpfseq	test, A
	call	low_word_comp
	return
	
	
comp:
	movlw	0x01
	movwf	test, A
	movf	ADRESH, W, A
	cpfslt	best_high_word, A
	return
	movwf	best_high_word, A
	movf	ADRESL, W, A
	movwf	best_low_word, A
	
	return
	
high_word_comp:
	movwf	best_high_word, A
	movf	ADRESL, W, A
	movwf	best_low_word, A
	
	return
low_word_comp:
	movf	ADRESL, W, A
	nop
	nop
	cpfsgt	best_low_word, A
	movwf	best_low_word, A
	return


end