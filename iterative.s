INDEX EQU 6

                    AREA arrays, data, readwrite
                    ALIGN
factorial_arr   SPACE (INDEX + 1) * 4
factorial_arr_end
         

        AREA iterative, code, readonly
        ENTRY
        THUMB
        ALIGN
fact	FUNCTION
        MOVS r2, #1       		;r2 <- 1
		STR r2,[r1, #0]   		;array[0] = 1
        B check1		  		;check if i < INDEX
loop1   MOVS r4, r2       		;r4 <- r2
		SUBS r4, #1		  		;r4 <- i - 1
		LSLS r4, #2       		;multiply r4 by 4 because of word length
		LDR r3, [r1, r4]  		;r3 <- array[i]
		MULS r3,r2,r3     		;r3 <- i * array[i - 1]
		MOVS r4, r2		  		;r4 <- r2
		LSLS r4, #2		  		;multiply r4 by 4 because of word length 
		STR r3, [r1, r4]  		;array[i] = i * array[i - 1]
		ADDS r2, #1		  		;i++
check1  CMP r2, r0        		;compare i with INDEX
        BLE loop1         		;branch if i <= INDEX
        BX LR			  		;return to main
        ENDFUNC

        ALIGN
__main  FUNCTION
		EXPORT __main
        LDR r5, =factorial_arr  ;address of factorial array
		MOVS r1,r5              ;r1 <- r5 to pass to fact function
        MOVS r0, #INDEX         ;r0 <- INDEX to pass to fact function
        BL fact                 ;go to fact function
stop    B stop                  ;while(1);
	
		ENDFUNC
		END