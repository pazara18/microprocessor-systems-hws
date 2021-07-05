LIMIT EQU 120

                    AREA arrays, data, readwrite
                    ALIGN
prime_numbers_arr   SPACE (LIMIT + 1) * 4
prime_numbers_arr_end
prime_bool_arr      SPACE LIMIT + 1
prime_bool_arr_end          

        AREA sieve_of_eratosthenes, code, readonly
        ENTRY
        THUMB
        ALIGN
sieve   FUNCTION
        MOVS r1, #0			;using r1 as i for first for loop i = 0
        B check1			;check condition for loop1
loop1   MOVS r2, r1			;r2 <- r1
        LSLS r2, #2			;multiply r2 by 4 becasue of word length
        MOVS r3, #0			;r3 <- 0
        STR r3, [r5, r2]	;prime_numbers[i] = 0
        MOVS r3, #1			;r3 <- 1
        STRB r3, [r6,r1]	;prime_bool[i] = true use STRB instead of STR because word length is 1 (similar in other instructions involving prime_bool array)
        ADDS r1, #1			;i++
check1  CMP r1, r0			;check if i <= LIMIT
        BLE loop1			;if condition is satsisfied enter loop1
        MOVS r1, #2			;using r1 as i for 2nd loop i = 2
        B check2			;check condition for loop2
loop2   LDRB r4, [r6,r1]	;r4 <- prime_bool[i]
        CMP r4, #0			;compare r4 with 0
        BEQ inc2			;branch to end if prime_bool[i] == false
        MOVS r2, r1			;r2 <- r1 r2 will be used as j for inner loop
        MULS r2, r1, r2		;r2 <- i * i
        B check3			;check condition for inner loop
loop3   MOVS r3, #0			;r3 <- 0
		STRB r3, [r6,r2]	;prime_bool[j] = false
inc2    ADDS r2,r1			;j += i for inner loop
check3  CMP r2,r0			;compare j with LIMIT
        BLE loop3			;branch if j <= LIMIT
        ADDS r1, #1			;i++ for outer loop
check2  MOVS r4,r1			;r4 <- r4
        MULS r4,r1,r4		;r4 <- i * i
        CMP r4,r0			;compare i * i and LIMIT
        BLE loop2			;branch if i * i <= LIMIT
        MOVS r1, #0			;r1 <- 0 r1 = index
        MOVS r2, #2			;r2 <- 2 r2 will be used as i for loop4
        B check4			;check condition for last loop
loop4	LDRB r3, [r6,r2]	;r3 <- prime_bool[i]
        CMP r3, #0			;compare r3 with 0
        BEQ inc4			;branch to end of loop if prime_bool[i] == false
        MOVS r3, r1			;r3 <- index
        LSLS r3, #2			;multiply r3 with 4 because word length is 4
        STR r2, [r5, r3]	;prime_number[index] = i
        ADDS r1, #1			;index++
inc4    ADDS r2, #1			;i++
check4  CMP r2, r0			;compare i with LIMIT
        BLE loop4			;enter loop if i <= LIMIT
        BX LR				;return to main
        ENDFUNC

        ALIGN
__main  FUNCTION
		EXPORT __main
        LDR r5, =prime_numbers_arr	;start address of prime_numbers[LIMIT + 1]
        LDR r6, =prime_bool_arr		;start address of prime_bool[LIMIT + 1]
        LDR r0, =LIMIT				;r0 <- LIMIT
        BL sieve					;go to sieve function
stop    B stop						;while(1)
	
		ENDFUNC
		END