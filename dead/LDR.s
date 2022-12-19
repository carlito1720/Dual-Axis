#include <xc.inc>

global  start_LDR, LDR_compare_loop, best_high_word, best_low_word, test, marker
   
extrn	move_motor1, move_motor2, ADC_Read, ADC_Setup, pulse_length1, pulse_length2, motor_Setup

    
psect	udata_acs   ; reserve data space in access ram
best_low_word: ds 1 ; reserve one byte for the best high word
best_high_word:ds 1 ; reserve one byte for the byte low word
test:	       ds 1 ; reserve one byte to test if the high word was changed so that the low word is not changed again
change_marker: ds 1 ; reserve 1 byte as marker for a change in the best 'luminosity' value   
psect	routine_code, class=CODE
    
start_LDR:		; read in value of LDR from port RA0
	movf	ADRESH, W, A		; read in high word
	movwf	best_high_word, A
	movf	ADRESL, W, A
	movwf	best_low_word, A
	return
	
LDR_compare_loop:
	movlw	0x00
	movwf	test, A
	movwf	change_marker, A
	movf	ADRESH, W, A
	cpfseq	best_high_word, A
	call	comp
	movlw	0x01
	cpfseq	test, A
	call	low_word_comp
	return
	
	
comp:
	
	movf	ADRESH, W, A
	cpfslt	best_high_word, A
	return
	movwf	best_high_word, A
	movf	ADRESL, W, A
	movwf	best_low_word, A
	movlw	0x01
	movwf	change_marker, A
	movwf	test, A
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
	cpfslt	best_low_word, A
	call	low_word_change
	return

low_word_change:
	movwf	best_low_word, A
	movlw	0x01
	movwf	change_marker
	return
end
