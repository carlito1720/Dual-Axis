#include <xc.inc>

global  initial_setup, long_move1, long_move2, best_position1, best_position2, count2, marker1, marker2, secondary_loop
   
extrn	test, move_motor1, move_motor2, ADC_Read, LDR_compare_loop, ADC_Setup, pulse_length1, pulse_length2, marker
    


	
psect	udata_acs   ; reserve data space in access ram
count1:		ds 1	; reserve 1 byte for counter 1
count2:		ds 1	; reserve 1 byte for counter 2
best_position1:	ds 1	; reserve 1 byte for best position of motor 1
best_position2:	ds 1	; reserve 1 byte for best position of motor 2
marker1:	ds 1	; reserve 1 byte as a marker for position 4
marker2:	ds 1	; reserve 1 byte as a marker for position 26
c1:		ds 1	; reserve 1 byte for a counter for the repeated pwm signal of motor 1
c2:		ds 1	; reserve 1 byte for a counter for the repeated pwm signal of motor 2
count_m1	ds 1	; reserve 1 byte for upwards secondary scan
count_m2	ds 1	; reserve 1 byte for downwards secondary scan

psect	routine_code, class=CODE
    
initial_setup:
	movlw	0x00		; change all marker to 0
	movwf	best_position1,A
	movwf	best_position2, A
	movwf	marker1, A
	movwf	marker2, A
	call	ADC_Read	; take measurement of the top position
	call	LDR_compare_loop	; compare to previous result
	call	best_check
	movlw	0x06		; move motor 2 to mid position
	movwf	pulse_length2, A
	call	long_move2
	call	ADC_Read
	call	LDR_compare_loop	; compare to previous result
	call	best_check
	call	scan1
	call	move_to_best
	call	secondary_loop
	return
	
	
secondary_loop:
	call	position_check1
	call	position_check2
	call	special_scan21
	call	special_scan22
	call	scan2
	call	move_to_best
	return
    
    
move_to_best:	; code to move the apparatus to the best recorded position
	movf	best_position1, W,A
	movwf	pulse_length1, A
	call	long_move1	    ; move motor 1 back to the best position 
	movf	best_position2,W, A
	movwf	pulse_length2, A
	call	long_move2	    ; move motor 2 back to the best position 
	return
	
	
scan1:	    ;	initial scan that quickly scans the whole hemisphere
	movlw	0x05		; create counter for motor 1 to go 360
	movwf	count2, A
	goto	another_loop
    another_loop:
	decf	count2
	call	increment_loop
	call	long_move1	; move motor 1 to the new position
	call	ADC_Read	; read the value of the intensity of that position
	call	LDR_compare_loop	; compare to previous result
	call	best_check	; check if the this position has a higher intensity and change the value of the best position
	movlw	0x00
	cpfseq	count2, A	; check if the loop is finished
	goto	another_loop
	return


	
   
    
increment_loop:	;loop to make the step motor move by 4 steps
	movlw	0x04
	movwf	count1, A
	goto	loop
	    
    loop:
	decf	count1, A
	incf	pulse_length1, A    ; increment pulse length of motor 1
	movlw	0x00
	cpfseq	count1, A	    ; check if the loop is finished
	goto	loop_2
	return

	
scan2:	
	movlw	0x00	    ; check if the best positions is not at the edge
	cpfseq	marker1, A
	return
	movlw	0x00
	cpfseq	marker2, A
	return
	movlw	0x02
	addwf	pulse_length1, 1
	addwf	pulse_length2, 1
	call	down_in_m2
	movlw	0x02
	subwf	pulse_length1,1
	call	up_in_m2
	movlw	0x02
	subwf	pulse_length1, 1
	call	down_in_m2
	
	return
	
    
special_scan21:
	movlw	0x01
	cpfseq	marker1, A
	return
	movlw	0x02
	addwf	pulse_length1, 1
	subwf	pulse_length2, 1
	call	up_in_m2
	movlw	0x02
	subwf	pulse_length1, A
	call	down_in_m2
	movlw	24
	movwf	pulse_length1 ,A
	call	up_in_m2
	return
	
special_scan22:
	movlw	0x01
	cpfseq	marker2, A
	return
	movlw	0x02
	addwf	pulse_length1, 1
	subwf	pulse_length2, 1
	call	up_in_m2
	movlw	0x02
	subwf	pulse_length1, A
	call	down_in_m2
	movlw	24
	movwf	pulse_length1 , A
	call	up_in_m2
	return
	
position_check1:    ;check if the best position is not 4, if so change marker 1 to 1
	movlw   4
	cpfseq  best_position1, A
	return
	movlw   0x01
	movwf   marker1, A
	return
	
position_check2:     ;check if the best position is not 26, if so change marker 2 to 1
	movlw   26
	cpfseq  best_position1, A
	return
	movlw   0x01
	movwf   marker2, A
	return

up_in_m2:   ; routine to move motor 2 up 3 times and take measurements
	call	long_move1
	call	long_move2
	call	ADC_Setup
	call	ADC_Read
	call	LDR_compare_loop	; compare to previous result
	call	best_check
	movlw	0x02
	movwf	count_m2, A
	goto	yet_another_loop

    yet_another_loop:
	movlw	0x02
	addwf	pulse_length2, 1
	call	long_move2
	call	ADC_Setup
	call	ADC_Read
	call	LDR_compare_loop	; compare to previous result
	call	best_check
	decf	count_m2, A
	movlw	0x00
	cpfseq	count_m2, A
	goto	yet_another_loop
	return


down_in_m2:	; routine to move motor 2 down 3 times and take measurements
	call	long_move1
	call	long_move2
	call	ADC_Setup
	call	ADC_Read
	call	LDR_compare_loop	; compare to previous result
	call	best_check
	movlw	0x02
	movwf	count_m2, A
	goto	yet_another_loop2

    yet_another_loop2:
	movlw	0x02
	subwf	pulse_length2, 1
	call	long_move2
	call	ADC_Setup
	call	ADC_Read
	call	LDR_compare_loop	; compare to previous result
	call	best_check
	decf	count_m2, A
	movlw	0x00
	cpfseq	count_m2, A
	goto	yet_another_loop2
	return
    
best_check: ; check if the best position has changed
	movlw	0x00
	cpfseq	change_marker, A	    ; test is a marker in LDR_compare_loop is once meaning the best position has changed
	call	change_best_position
	return
	
change_best_position:	; if the best position has changed -> update the variables
	movf	pulse_length1,W, A
	movwf	best_position1, A	    ; make the current position the best position of motor 1
	movf	pulse_length2,W,A
	movwf	best_position2, A	    ; make the current position the best position of motor 1
	return
	
long_move1:	; code do reapeat the PWM signal for motor 1
    	movlw	0xFF
	movwf	c1
	goto	loop1
    loop1:
	call	move_motor1
	decf	c1
	movlw	0x00
	cpfseq	c1
	goto	loopy1
	movlw	0xFF
	movwf	c1
	goto	loop3
    loop3:
	call	move_motor1
	decf	c1
	movlw	0x00
	cpfseq	c1
	goto	loop3
	return
	
	
long_move2:	; code do reapeat the PWM signal for motor 2
    	movlw	0xFF
	movwf	c2
	goto	loop
    loop:
	call	move_motor2
	decf	c2
	movlw	0x00
	cpfseq	c2
	goto	loopy
	movlw	0xFF
	movwf	c2
	goto	loop2
    loop2:
	call	move_motor2
	decf	c2
	movlw	0x00
	cpfseq	c2
	goto	loop2
	return



end
