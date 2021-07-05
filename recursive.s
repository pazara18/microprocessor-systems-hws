INDEX EQU 6

                    AREA arrays, data, readwrite
                    ALIGN
factorial_arr   SPACE (INDEX + 1) * 4
factorial_arr_end
         

        AREA recursive, code, readonly
        ENTRY
        ALIGN
fact 	FUNCTION
		PUSH {r1, r3, LR}  	;push r1, r3 and lr to stack
		CMP r1, #2			;compare n to 2
		BLT ret 			;branch to ret if n < 2
		MOVS r2, r1			;r2 <- n
		MOVS r3, r2			;r3 <- r2
		SUBS r1, r1, #1 	;r1 <- n - 1
		BL fact 			;r2 <- fact(n - 1)
		MULS r3, r2, r3 	;r3 <- n * fact(n - 1)
		MOVS r2, r3 		;r2 <- r3
		POP {r1, r3, PC} 	;pop and return
ret		MOVS r2, #1 		;set r2 to 1
		POP {r1, r3, PC} 	;pop and return	
        ENDFUNC

        ALIGN
__main  FUNCTION
		EXPORT __main
        LDR r5, =factorial_arr  ;address of factorial array
		MOVS r0,r5              ;r0 <- r5 to pass to fact function
        LDR r6, =INDEX         	;r0 <- INDEX to pass to fact function
		
		MOVS r1, #0				;using r1 as i for the for loop i = 0
        B check					;check condition for loop1
loop   	BL fact					;call fact where n is r1
		MOVS r4,r1				;r4 <- r1
		LSLS r4, #2				;multiply r4 by 4 because of word length
		STR r2, [r0,r4]			;factorial_arr[i] = fact(i)
        ADDS r1, #1				;i++
check  	CMP r1, r6				;check if i <= INDEX
        BLE loop				;if condition is satsisfied enter loop1
stop    B stop                  ;while(1);
	
		ENDFUNC
		END