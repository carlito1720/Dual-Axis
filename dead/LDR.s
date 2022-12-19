#include <xc.inc>

global  LDR_compare_loop, best_high_word, best_low_word, test, marker
   
extrn	move_motor1, move_motor2, ADC_Read, ADC_Setup, pulse_length1, pulse_length2, motor_Setup

    
psect	udata_acs   ; reserve data space in access ram
best_low_word: ds 1 ; reserve one byte for the best high word
best_high_word:ds 1 ; reserve one byte for the byte low word
test:	       ds 1 ; reserve one byte to test if the high word was changed so that the low word is not changed again
change_marker: ds 1 ; reserve 1 byte as marker for a change in the best 'luminosity' value   
psect	routine_code, class=CODE
    
	
LDR_compare_loop:
	movlw	0x00	;set both markers to 0
	movwf	test, A
	movwf	change_marker, A
	movf	ADRESH, W, A
	cpfseq	best_high_word, A	; check if the high words are the same
	call	comp			; if not check if high word is bigger
	movlw	0x01			; check if the the high word and low word has been changed
	cpfseq	test, A
	call	low_word_comp		; if not check if the low word is larger if the high word is equal
	return
	
	
comp:	; check if the high word is high and change high and low word if so ( also change maker to 1)
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
	

low_word_comp:	; if the high words are equal and the new low word is higher change low word
	movf	ADRESH, W, A
	cpfseq	best_high_word, A
	return
	movf	ADRESL, W, A
	nop
	nop
	cpfslt	best_low_word, A
	call	low_word_change
	return

low_word_change:	; change the best low word and change the marker to 1 
	movwf	best_low_word, A
	movlw	0x01
	movwf	change_marker
	return
	
end
