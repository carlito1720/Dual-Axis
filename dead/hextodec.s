#include <xc.inc>
    
extrn	best_low_word, best_high_word
    
global	hextodec, sol, RES0, RES1, RES2,RES3, part1, part2, part3, part4
    
psect	udata_acs   ; reserve data space in access ram
RES1:	    ds 1
RES0:	    ds 1
RES2:	    ds 1
RES3:	    ds 1
ARG1L:	    ds 1
ARG2L:	    ds 1
ARG1H:	    ds 1
ARG2H:	    ds 1
ARG2HH:	    ds 1
part1:	    ds 1
part2:	    ds 1
part3:	    ds 1
part4:	    ds 1
sol:	    ds 1

psect	routine_code, class=CODE	
    
hextodec:
    movlw	0x00
    movwf	sol
    movlw	0x42		; set k to 66
    movwf	ARG1L, A	;move k to first argument of multiplication
    movlw	0x00
    movwf	ARG1H, A
    movff	best_high_word, ARG2H, A	; set detected value to second argument of the multiplication
    movff	best_low_word, ARG2L, A	; set detected value to second argument of the multiplication
    call	multiply16x16
    
     
    movf	RES3, W, A
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
    
   
    movf	RES3,W, A
    movwf	part4, A
    
ASCII:
    movf	part4,W,A
    addwf	sol
    movf	part3,W,A
    addwf	sol
    movf	part2,W,A
    addwf	sol
    movf	part1,W,A
    addwf	sol
    return
    
    
	
multiply16x16:
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
    

    
multiply24x8:
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