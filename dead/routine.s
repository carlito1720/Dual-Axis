#include <xc.inc>

global  initial_setup, long_move1, long_move2, best_position1, best_position2, count2, marker1, marker2, secondary_loop
   
extrn	test, move_motor1, move_motor2, ADC_Read, LDR_compare_loop, ADC_Setup, pulse_length1, pulse_length2, marker
    


	
psect	udata_acs   ; reserve data space in access ram
count1:		ds 1	; reserve 1 byte for counter 1
count2:		ds 1	; reserve 1 byte for counter 2
best_position1:	ds 1	; reserve 1 byte for best position of motor 1
best_position2:	ds 1	; reserve 1 byte for best position of motor 2
count_m1:	ds 1
count_m2:	ds 1
marker1:	ds 1
marker2:	ds 1
normal_count:	ds 1
motor_cnt_l:	ds 1	; reserve 1 byte for variable LCD_cnt_l
motor_cnt_h:	ds 1	; reserve 1 byte for variable LCD_cnt_h
motor_cnt_ms:	ds 1	; reserve 1 byte for ms counter
motor_tmp:	ds 1	; reserve 1 byte for temporary use
motor_counter:	ds 1	; reserve 1 byte for counting through nessage
yes:		ds 1
no:		ds 1
    
psect	routine_code, class=CODE
    
initial_setup:
	movlw	0x00
	movwf	best_position1,A
	movwf	best_position2, A
	movwf	marker1, A
	movwf	marker2, A
	call	ADC_Read
	call	LDR_compare_loop	; take measurement of the top position
	call	best_check
	movlw	0x06		; move motor 2 to mid position
	movwf	pulse_length2, A
	call	long_move2
	call	ADC_Read
	call	LDR_compare_loop	; take measurement of the top position
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
    
move_to_best:
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
	call	loop
	call	long_move1	; move motor 1 to the new position
	call	ADC_Read	; read the value of the intensity of that position
	call	LDR_compare_loop
	call	best_check	; check if the this position has a higher intensity and change the value of the best position
	movlw	0x00
	cpfseq	count2, A	; check if the loop is finished
	goto	another_loop
	return


	
   
    
loop:	;loop to make the step motor move by 4 steps
	movlw	0x04
	movwf	count1, A
	goto	loop_2
	    
    loop_2:
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
	
position_check1:    ;check if the best position is not 4
	movlw   4
	cpfseq  best_position1, A
	return
	movlw   0x01
	movwf   marker1, A
	return
	
position_check2:     ;check if the best position is not 26
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
	call	LDR_compare_loop
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
	call	LDR_compare_loop
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
	call	LDR_compare_loop
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
	call	LDR_compare_loop
	call	best_check
	decf	count_m2, A
	movlw	0x00
	cpfseq	count_m2, A
	goto	yet_another_loop2
	return
    
best_check: ; check if the best position has changed
	movlw	0x00
	cpfseq	marker, A	    ; test is a marker in LDR_compare_loop 
	call	change_best_position
	return
	
change_best_position:	; if the best position has changed -> update the variables
	movf	pulse_length1,W, A
	movwf	best_position1, A	    ; make the current position the best position of motor 1
	movf	pulse_length2,W,A
	movwf	best_position2, A	    ; make the current position the best position of motor 1
	return
	
long_move1:	
    	movlw	0xFF
	movwf	yes
	goto	loopy1
    loopy1:
	call	move_motor1
	decf	no
	movlw	0x00
	cpfseq	no
	goto	loopy1
	movlw	0xFF
	movwf	no
	goto	loopy3
    loopy3:
	call	move_motor1
	decf	no
	movlw	0x00
	cpfseq	no
	goto	loopy3
	return
	
	
long_move2:	
    	movlw	0xFF
	movwf	yes
	goto	loopy
    loopy:
	call	move_motor2
	decf	yes
	movlw	0x00
	cpfseq	yes
	goto	loopy
	movlw	0xFF
	movwf	yes
	goto	loopy2
    loopy2:
	call	move_motor2
	decf	yes
	movlw	0x00
	cpfseq	yes
	goto	loopy2
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

	

end