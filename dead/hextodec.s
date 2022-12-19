#include <xc.inc>
    
extrn	best_low_word, best_high_word
    
global	hextodec, sol, RES0, RES1, RES2,RES3, part1, part2, part3, part4
    
psect	udata_acs   ; reserve data space in access ram
RES1:	    ds 1	; reserve 1 byte for one byte of the solution to the multiplication
RES0:	    ds 1	; reserve 1 byte for one byte of the solution to the multiplication
RES2:	    ds 1	; reserve 1 byte for one byte of the solution to the multiplication
RES3:	    ds 1	; reserve 1 byte for one byte of the solution to the multiplication
ARG1L:	    ds 1	; reserve 1 byte for the low word of the 1st component of the multiplication
ARG2L:	    ds 1	; reserve 1 byte for the low word of the 2nd component of the multiplication
ARG1H:	    ds 1	; reserve 1 byte for the high word of the 1st component of the multiplication
ARG2H:	    ds 1	; reserve 1 byte for the high  word of the 2nd component of the multiplication
ARG2HH:	    ds 1	; reserve 1 byte for the low word of the 2nd prt of the 2nd component of thes multiplication
part1:	    ds 1	; reserve 1 byte for the most significant bit of the 1th multiplication
part2:	    ds 1	; reserve 1 byte for the most significant bit of the 2th multiplication
part3:	    ds 1	; reserve 1 byte for the most significant bit of the 3th multiplication
part4:	    ds 1	; reserve 1 byte for the most significant bit of the 4th multiplication
sol:	    ds 1	; reserve 1 byte for the result of the conversion

psect	routine_code, class=CODE	
    
hextodec:
    movlw	0x00
    movwf	sol
    movlw	0x42		; set k to 66
    movwf	ARG1L, A	; move k to first argument of multiplication
    movlw	0x00
    movwf	ARG1H, A
    movff	best_high_word, ARG2H, A	; set best value to second argument of the multiplication
    movff	best_low_word, ARG2L, A		; set best value to second argument of the multiplication
    call	multiply16x16	
    
    ; send the results of the previous multiplication to the correct location to complete another multiplication
    movf	RES3, W, A	; with the setup the most significant byte is not the first one
    ;movwf	part1, A
    movwf	ARG2HH
    movf	RES0,W, A
    movwf	ARG2L, A
    movf	RES1,W,A
    movwf	ARG2H
    movf	RES2,W,A 
    movwf	ARG2H, A
    movwf	part1, A
    movlw	0x0A
    movwf	ARG1L, A	;set the second argumn to 10
    movlw	0x00
    movwf	ARG1H, A
    call	multiply24x8
 
    ; send the results of the previous multiplication to the correct location to complete another multiplication   
    movf	RES3, W, A
    ;movwf	part2, A
    movwf	ARG2HH
    movf	RES0,W, A
    movwf	ARG2L, A
    movf	RES1,W,A
    movwf	ARG2H
    movf	RES2,W,A
    movwf	part2, A
    movwf	ARG2H
    movlw	0x0A
    movwf	ARG1L, A	;set the second argumn to 10
    movlw	0x00
    movwf	ARG1H, A
    call	multiply24x8
    
    ; send the results of the previous multiplication to the correct location to complete another multiplication
    movf	RES3, W, A
    ;movwf	part3, A
    movwf	ARG2HH,A
    movf	RES0,W, A
    movwf	ARG2L, A
    movf	RES1,W,A
    movwf	ARG2H, A
    movf	RES2, W,A
    movwf	part3, A
    movwf	ARG2H, A
    movlw	0x0A
    movwf	ARG1L, A	;set the second argumn to 10
    movlw	0x00
    movwf	ARG1H, A
    call	multiply24x8
    
   
    movf	RES2,W, A
    movwf	part4, A
    
ASCII:	; code to combine the most significant bytes of the multiplications to obtain the decimal value
    movf	part4,W,A
    addwf	sol
    movf	part3,W,A
    addwf	sol
    movf	part2,W,A
    addwf	sol
    movf	part1,W,A
    addwf	sol
    return
    
    
	
multiply16x16:		; code for a 16x16 multiplication taken from the data sheet
    MOVF    ARG1L, W
    MULWF   ARG2L ; ARG1L * ARG2L->
    ; PRODH:PRODL
    MOVFF   PRODH, RES1 ;
    MOVFF   PRODL, RES0 ;
    ;
    MOVF    ARG1H, W
    MULWF   ARG2H ; ARG1H * ARG2H->
    ; PRODH:PRODL
    MOVFF   PRODH, RES3 ;
    MOVFF   PRODL, RES2 ;
    ;
    MOVF    ARG1L, W
    MULWF   ARG2H ; ARG1L * ARG2H->
    ; PRODH:PRODL
    MOVF    PRODL, W ;
    ADDWF   RES1, F ; Add cross
    MOVF    PRODH, W ; products
    ADDWFC  RES2, F ;
    CLRF    WREG ;
    ADDWFC  RES3, F ;
    ;
    MOVF    ARG1H, W ;
    MULWF   ARG2L ; ARG1H * ARG2L->
    ; PRODH:PRODL
    MOVF    PRODL, W ;
    ADDWF   RES1, F ; Add cross
    MOVF    PRODH, W ; products
    ADDWFC  RES2, F ;
    CLRF    WREG ;
    ADDWFC  RES3, F ;
    return
    

    
multiply24x8:		; code for a 24x8 mluiplication adapted from the one given in the data sheet
    MOVF    ARG1L, W
    MULWF   ARG2L ; ARG1L * ARG2L->
    ; PRODH:PRODL
    MOVFF   PRODH, RES1 ;
    MOVFF   PRODL, RES0 ;
    
    MOVF    ARG2H, W
    MULWF   ARG1L ; ARG1H * ARG2H->
    ; PRODH:PRODL
    MOVF    PRODL, W ;
    ADDWF   RES1, F ; Add cross
    MOVF    PRODH, W ; products
    ADDWFC  RES2, F ;
    CLRF    WREG ;
    ADDWFC  RES3, F ;
    
    MOVF    ARG2HH, W
    MULWF   ARG1L ; ARG1H * ARG2H->
    ; PRODH:PRODL
    MOVF    PRODL, W ;
    ADDWF   RES1, F ; Add cross
    MOVF    PRODH, W ; products
    ADDWFC  RES2, F ;
    CLRF    WREG ;
    ADDWFC  RES3, F ;
    return
    
    end	
