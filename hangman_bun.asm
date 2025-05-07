include emu8086.inc
org 100h


CALL FIRST_PAGE  ;CALL THE PROCEDURE THAT DISPLAYS THE FIRST PAGE


;MOV CX, 10
;PUSH CX   
GAME: 


   
   CMP BX,1 
   JE END:   
   MOV DH, 12
   MOV DL, 39          ;SET CURSOR FOR DISPLAY ____
   MOV AH, 2
   INT 10h
   
   LEA DX, DISPLAY     ;DISPLAYS THE DISPLAY ____
   MOV AH, 9
   INT 21H
   
   
   MOV DH, 20
   MOV DL, 0          ;SET CURSOR FOR LETTER
   MOV AH, 2
   INT 10h
   PRINT "TYPE A LETTER: "
   
   MOV AH, 1         ;READ CHARACTER FROM standard input, with echo, result is stored in AL.
   INT 21h 
   MOV GUESS, AL      ;STORE USER GUESS         
   
   CALL CHECK 
   
   CALL VERIFY_CHANCES
   
   ;MOV BX, 1
   CALL VERIFY_WORD 
   

LOOP GAME     

RET       

DEFINE_CLEAR_SCREEN
DEFINE_PRINT_STRING
DEFINE_PRINT_NUM
DEFINE_PRINT_NUM_UNS

NO_CHANCES DW 6 
X DW 7
wrong_cursor_column dw 52
wrong_cursor_row dw 0  
letters dw 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
WORD DB 'APPLE$',0
DISPLAY db '_ _ _ _ _$', 0  
GUESS DB ?
;LEVEL1_WORDS db 'LION$', 'BEAR$', 'FROG$', 'WOLF$', 'DEER$', 0 
;LEVEL2_WORDS db 'APPLE$', 'GRAPE$', 'MANGO$', 'PEACH$', 'BERRY$', 0 
;LEVEL3_WORDS db 'CHERRY$', 'BANANA$', 'ORANGE$', 'PEARLS$', 'ALMOND$', 0
;WORD_INDEX DB ?      
      
      
;>>>>STRAT PAGE PROCEDURE<<<<
FIRST_PAGE PROC
    MOV DH, 10
    MOV DL, 34 
    ;MOV BH, 0
    MOV AH, 2                 
    INT 10h 
    PRINT ">HANGMAN<"    
    
    
    ;MOV DH, 12
    ;MOV DL, 35
    ;MOV BH, 0                 
    ;MOV AH, 2
    ;INT 10h      
    ;PRINT "LEVEL 1"  
    
    MOV DH, 14
    MOV DL, 36
    ;MOV BH, 0          
    MOV AH, 2
    INT 10h      
    PRINT "START"  
    MOV cx, 1000                  
    
    WAIT_CLICK:         ;WAIT TO CLICK ON THE STRAT BUTTON
        MOV AX, 3
        INT 33h 
        CMP BX, 1
        JNE WAIT_CLICK 
        CMP CX, 288     ;MIN X VALUE
        JL WAIT_CLICK
        CMP CX, 325     ;MAX X VALUE
        JG WAIT_CLICK
        CMP DX, 112     ;MIN Y VALUE
        JL WAIT_CLICK
        CMP DX, 120     ;MAX Y VALUE
        JG WAIT_CLICK
        MOV AX, 3
        INT 10h  
        CALL LEVEL_PAGE 


    RET
    
FIRST_PAGE ENDP


;>>>>STRAT PAGE PROCEDURE<<<<
LEVEL_PAGE PROC 
    
    MOV DH, 12
    MOV DL, 35
    ;MOV BH, 0          
    MOV AH, 2
    INT 10h      
    PRINT "LEVEL 1"  
    MOV cx, 1000    
     
        
    WAIT_CLICK_LEVEL1:         ;WAIT TO CLICK ON THE STRAT BUTTON
        MOV AX, 3
        INT 33h 
        CMP BX, 1
        JNE WAIT_CLICK_LEVEL1 
        CMP CX, 279     ;MIN X VALUE
        JL WAIT_CLICK_LEVEL1
        CMP CX, 335     ;MAX X VALUE
        JG WAIT_CLICK_LEVEL1
        CMP DX, 95     ;MIN Y VALUE
        JL WAIT_CLICK_LEVEL1
        CMP DX, 103     ;MAX Y VALUE
        JG WAIT_CLICK_LEVEL1
        MOV AX, 3
        INT 10h  
        CALL GAME_PAGE               
    
     RET

LEVEL_PAGE ENDP

            ;>>>>PICK A RANDOM WORD FROM VECTOR<<<< 
            ;PICK_RANDOM PROC
                ;MOV AH, 0      ;GET SYSTEM TIME INTERRUPT
                ;INT 1Ah  
                ;MOV AL, DL     ;USE LOW BYTE OF THE SECOND COUNTER
                ;XOR AH, AH
                ;DIV BYTE PTR 5
                ;MOV WORD_INDEX, AL   ;SAVE THE INDEX OF THE RANDOM WORD
                ;RET
            
            ;PICK_RANDOM ENDP 
            
            ;>>>>PICK A RANDOM WORD FROM VECTOR<<<<


 
;>>>>BASIC LEVEL PAGE PROCEDURE<<<<
GAME_PAGE PROC
    MOV DH, 0
    MOV DL, 0                 ;SET CUROSR FOR WRONG ANSWERS AND PRINT WRONG ANSWERS
    MOV AH, 2
    INT 10h   
    PRINT "Chances left: "    ;PRINT CHNACES LEFT
    CALL CHANCES 
    MOV DH, 0
    MOV DL, 39                 ;SET CUROSR FOR WRONG ANSWERS AND PRINT WRONG ANSWERS
    MOV AH, 2
    INT 10h      
    PRINT "Wrong answers: "  
    MOV BX,0
    CALL GAME  
    RET
GAME_PAGE ENDP

 
 
;>>>>CHANCES PROCEDURE<<<<
CHANCES PROC     ; procedure declaration.
    MOV DH, 0
	MOV DL, 14
	MOV AH, 2
	INT 10h  
    MOV AX, NO_CHANCES
    CALL PRINT_NUM
    RET     ; return to caller.
CHANCES ENDP  



;>>>>WRONG ANSWERS PROCEDURE<<<<     
WRONG_ANSWERS PROC   
    MOV AX, wrong_cursor_row
    MOV DH, AL  
    ADD wrong_cursor_column, 2    ;MOVE CURSOR TO THE NEXTB POSITION
    MOV AX, wrong_cursor_column
	MOV DL, AL   
	MOV AH, 2
	INT 10h  
	
    MOV DL, GUESS       ;WRITE THE WRONG LETTER
    MOV AH, 2
    INT 21H 
    RET
WRONG_ANSWERS ENDP





;>>>>CHECK GUESS PROCEDURE<<<<
CHECK PROC
   MOV CX, 5        ;WORD NUMBER OF LETTERS
   MOV SI, 0        ;WORD INDEX
   MOV DI, 0        ;DISPLAY INDEX 
   
   VERIFY_GUESS: 
        MOV AX, WORD[SI]
        CMP AL, GUESS     ;COMPARE THE LETTERS
        JE CORRECT        ;JUMP IF MATCH
           
        INC SI            ;MOVE TO NEXT LETTER
        ADD DI, 2         ;NEXT _ IN DISPLAY
        
        
        LOOP VERIFY_GUESS
        
   JMP WRONG ;JUMP IF NO MACH     
            
CORRECT:  
     MOV SI, 0        ;WORD INDEX
     MOV DI, 0        ;DISPLAY___ INDEX  
     MOV CX, 5  
     
     SHOW:
     MOV AX, WORD[SI]
     CMP AL, GUESS     ;COMPARE THE LETTERS
     JNE DONOTHING    
     
     MOV DISPLAY[DI], AL
     
     DONOTHING:   
         INC SI            ;MOVE TO NEXT LETTER
         ADD DI, 2         ;NEXT _ IN DISPLAY   
     
     LOOP SHOW
     RET   
   
   WRONG:
      DEC NO_CHANCES        ;DECREASE THE CHANCES
      CALL CHANCES          ;DISPLAY THE CHANCES LEFT
      CALL WRONG_ANSWERS    ;DISPLAY THE WRONG LETTER
    RET   
      
   POP CX 
CHECK ENDP

LOSE PROC 
   MOV AX, 3
   INT 10h
   MOV DH, 10
   MOV DL, 34 
   ;MOV BH, 0
   MOV AH, 2                 
   INT 10h 
   PRINT "GAME OVER" 
   MOV BX, 1
   CALL END  
LOSE ENDP

WINNER PROC 
   MOV AX, 3
   INT 10h
   MOV DH, 10
   MOV DL, 34 
   ;MOV BH, 0
   MOV AH, 2                 
   INT 10h 
   PRINT "WINNER"
   MOV BX, 1
   CALL END
   RET  
WINNER ENDP


VERIFY_CHANCES PROC
        CMP NO_CHANCES, 0
        JNE NOTHING  
        CALL LOSE
        NOTHING:
 RET
VERIFY_CHANCES ENDP  



VERIFY_WORD PROC  
     MOV DI, 0        ;DISPLAY___ INDEX  
     MOV CX, 5 
     MOV BX, 1 
     
     VERIFY:
     CMP DISPLAY[DI], '_'     ;COMPARE THE LETTERS  
     
     JNE NEXT_LETTER    
     MOV BX, 0 
     JMP DONE
     
     
      
     NEXT_LETTER:   
         ADD DI, 2         ;NEXT _ IN DISPLAY   
         LOOP VERIFY  
         
     DONE:
     CMP BX, 1 
     JE WINNER
     RET   
VERIFY_WORD ENDP


END: 



 