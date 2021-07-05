;*******************************************************************************
;@file				 Main.s
;@project		     Microprocessor Systems Term Project
;@date
;
;@PROJECT GROUP
;@groupno			 0
;@member1			 Kadir Ozlem
;@member2
;@member3
;@member4
;@member5
;*******************************************************************************
;*******************************************************************************
;@section 		INPUT_DATASET
;*******************************************************************************

;@brief 	This data will be used for insertion and deletion operation.
;@note		The input dataset will be changed at the grading. 
;			Therefore, you shouldn't use the constant number size for this dataset in your code. 
				AREA     IN_DATA_AREA, DATA, READONLY
IN_DATA			DCD		0x10, 0x20, 0x15, 0x65, 0x25, 0x01, 0x01, 0x12, 0x65, 0x25, 0x85, 0x46, 0x10, 0x00
END_IN_DATA

;@brief 	This data contains operation flags of input dataset. 
;@note		0 -> Deletion operation, 1 -> Insertion 
				AREA     IN_DATA_FLAG_AREA, DATA, READONLY
IN_DATA_FLAG	DCD		0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x00, 0x02
END_IN_DATA_FLAG


;*******************************************************************************
;@endsection 	INPUT_DATASET
;*******************************************************************************

;*******************************************************************************
;@section 		DATA_DECLARATION
;*******************************************************************************

;@brief 	This part will be used for constant numbers definition.
NUMBER_OF_AT	EQU		20									; Number of Allocation Table
AT_SIZE			EQU		NUMBER_OF_AT*4						; Allocation Table Size


DATA_AREA_SIZE	EQU		AT_SIZE*32*2						; Allocable data area
															; Each allocation table has 32 Cell
															; Each Cell Has 2 word (Value + Address)
															; Each word has 4 byte
ARRAY_SIZE		EQU		AT_SIZE*32							; Allocable data area
															; Each allocation table has 32 Cell
															; Each Cell Has 1 word (Value)
															; Each word has 4 byte
LOG_ARRAY_SIZE	EQU     AT_SIZE*32*3						; Log Array Size
															; Each log contains 3 word
															; 16 bit for index
															; 8 bit for error_code
															; 8 bit for operation
															; 32 bit for data
															; 32 bit for timestamp in us

;//-------- <<< USER CODE BEGIN Constant Numbers Definitions >>> ----------------------															
							


;//-------- <<< USER CODE END Constant Numbers Definitions >>> ------------------------	

;*******************************************************************************
;@brief 	This area will be used for global variables.
				AREA     GLOBAL_VARIABLES, DATA, READWRITE		
				ALIGN	
TICK_COUNT		SPACE	 4									; Allocate #4 byte area to store tick count of the system tick timer.
FIRST_ELEMENT  	SPACE    4									; Allocate #4 byte area to store the first element pointer of the linked list.
INDEX_INPUT_DS  SPACE    4									; Allocate #4 byte area to store the index of input dataset.
INDEX_ERROR_LOG SPACE	 4									; Allocate #4 byte aret to store the index of the error log array.
PROGRAM_STATUS  SPACE    4									; Allocate #4 byte to store program status.
															; 0-> Program started, 1->Timer started, 2-> All data operation finished.
;//-------- <<< USER CODE BEGIN Global Variables >>> ----------------------															
							


;//-------- <<< USER CODE END Global Variables >>> ------------------------															

;*******************************************************************************

;@brief 	This area will be used for the allocation table
				AREA     ALLOCATION_TABLE, DATA, READWRITE		
				ALIGN	
__AT_Start
AT_MEM       	SPACE    AT_SIZE							; Allocate #AT_SIZE byte area from memory.
__AT_END

;@brief 	This area will be used for the linked list.
				AREA     DATA_AREA, DATA, READWRITE		
				ALIGN	
__DATA_Start
DATA_MEM        SPACE    DATA_AREA_SIZE						; Allocate #DATA_AREA_SIZE byte area from memory.
__DATA_END

;@brief 	This area will be used for the array. 
;			Array will be used at the end of the program to transform linked list to array.
				AREA     ARRAY_AREA, DATA, READWRITE		
				ALIGN	
__ARRAY_Start
ARRAY_MEM       SPACE    ARRAY_SIZE						; Allocate #ARRAY_SIZE byte area from memory.
__ARRAY_END

;@brief 	This area will be used for the error log array. 
				AREA     ARRAY_AREA, DATA, READWRITE		
				ALIGN	
__LOG_Start
LOG_MEM       	SPACE    LOG_ARRAY_SIZE						; Allocate #DATA_AREA_SIZE byte area from memory.
__LOG_END

;//-------- <<< USER CODE BEGIN Data Allocation >>> ----------------------															
							


;//-------- <<< USER CODE END Data Allocation >>> ------------------------															

;*******************************************************************************
;@endsection 	DATA_DECLARATION
;*******************************************************************************

;*******************************************************************************
;@section 		MAIN_FUNCTION
;*******************************************************************************

			
;@brief 	This area contains project codes. 
;@note		You shouldn't change the main function. 				
				AREA MAINFUNCTION, CODE, READONLY
				ENTRY
				THUMB
				ALIGN 
__main			FUNCTION
				EXPORT __main
				BL	Clear_Alloc					; Call Clear Allocation Function.
				BL  Clear_ErrorLogs				; Call Clear ErrorLogs Function.
				BL	Init_GlobVars				; Call Initiate Global Variable Function.
				BL	SysTick_Init				; Call Initialize System Tick Timer Function.
				LDR R0, =PROGRAM_STATUS			; Load Program Status Variable Addresses.
LOOP			LDR R1, [R0]					; Load Program Status Variable.
				CMP	R1, #2						; Check If Program finished.
				BNE LOOP						; Go to loop If program do not finish.
STOP			B	STOP						; Infinite loop.
				
				ENDFUNC
			
;*******************************************************************************
;@endsection 		MAIN_FUNCTION
;*******************************************************************************				

;*******************************************************************************
;@section 			USER_FUNCTIONS
;*******************************************************************************

;@brief 	This function will be used for System Tick Handler
SysTick_Handler	FUNCTION			
;//-------- <<< USER CODE BEGIN System Tick Handler >>> ----------------------															
				EXPORT SysTick_Handler
				PUSH {R4-R6,LR}						; Save the modified regiters. 
													;Other registers stored by contex switching
				LDR  R0, =TICK_COUNT					; Load TICK_COUNT Variable Address.
			    LDR  R1, [R0]						; Load Variable From Memory.
				ADDS R1, #1							; Increase TICK_COUNT Variable.
				STR  R1, [R0]						; Store TICK_COUNT Value.
				LDR	 R1, =IN_DATA					; Load Input Data Array Start Address
				LDR  R3, =IN_DATA_FLAG				; Load Input Data Operation Flag Array Start Address
				LDR  R4, =INDEX_INPUT_DS			; Load The Address of the Index Input DataSet
				LDR  R4, [R4]						; Get The Index of The Input Data Set
				LDR  R5, [R1, R4]					; Get The Data from The Input Data Set
				LDR  R6, [R3, R4]					; Get The Flag Value from The Input Data Flag Array
				CMP  R6, #0							; Check if flag is deletion operation
				BNE	 systick_ins					; Go to check insertion operation	 
				MOVS R0, R5							; Copy the data as argument
				BL   Remove							; Go to Remove Operation.
				CMP  R0, #0							; Check if error occurs
				BEQ  systick_ret					; Go to return operation if there is no error.
				B 	 writeError						; Otherwise go to write error operation.
systick_ins		CMP  R6, #1							; Check if the flag is the insertion operation
				BNE	 systick_ll2a					; Go to check linkedlist to array operation
				MOVS R0, R5							; Copy the data as argument
				BL   Insert							; Go to Insert Operation.
				CMP  R0, #0							; Check if error occurs
				BEQ  systick_ret					; Go to return operation if there is no error.
				B 	 writeError						; Otherwise go to write error operation.
systick_ll2a	CMP  R6, #2							; Check if the flag is the insertion operation
				BNE	 write_op_404					; Go to operation not found 
				BL   LinkedList2Arr					; Go to Linked List to Array Operation.
				CMP  R0, #0							; Check if error occurs
				BEQ  systick_ret					; Go to return operation if there is no error.
				B 	 writeError						; Otherwise go to write error operation.
write_op_404	MOVS R0, #6							; Operation not Found Error
writeError		MOVS R1, R0							; Copy Error Code
				LSRS R0, R4, #2						; Get Index of Dataset Array
				MOVS R2, R6							; Copy flag value as argument
				MOVS R3, R5 						; Copy the data value as argument
				BL	 WriteErrorLog					; Write the log to Error Log 
systick_ret		LDR	 R1, =IN_DATA					; Load Input Data Array Start Address
				LDR  R2, =END_IN_DATA				; Load Input Data Array End Address
				SUBS R2, R2, R1						; Size of Input Data
				ADDS R4, #4							; Increase Index Of Input DataSet
				LDR  R3, =INDEX_INPUT_DS			; Load The Address of the Index Input DataSet
				STR  R4, [R3]						; Store Index Of the Input
				CMP  R4, R2							; Check the index reach the end of the dataset
				BLO	 systick_dret					; Go return instruction
				BL   SysTick_Stop					; Stop The System Tick Interrupt if the array finished.
systick_dret    POP  {R4-R6,PC}							; return with PC.	
;//-------- <<< USER CODE END System Tick Handler >>> ------------------------				
				ENDFUNC

;*******************************************************************************				

;@brief 	This function will be used to initiate System Tick Handler
SysTick_Init	FUNCTION			
;//-------- <<< USER CODE BEGIN System Tick Timer Initialize >>> ----------------------															
				PUSH {R0-R2, LR}					; Save the modified regiters.
				BL	 SysTick_Stop					; Stop the System Tick Timer initially.
				; CPU 16 MHz, Frequency 1000 Hz
				; Period = (ReloadValue +1)/CPUFreq
				; ReloadValue + 1 = CPUFreq/Freq
				; ReloadValue + 1 = 16.000.000 / 1000
				; ReloadValue = 15.999
				LDR	 R0, =0xE000E014				; Load SYST_RVR Address.
				LDR  R1, =15999						; R1 = 15999 //Reload Value.	
				STR  R1, [R0]						; Set the Reload Value Register.
				LDR	 R0, =0xE000E018				; Load SYST_CVR Address.
				MOVS R1, #0							; R1 = 0
				STR  R1, [R0]						; Clear the Current Value Register.
				LDR	 R0, =0xE000E010				; Load SYST_CSR Address.
				LDR  R1, [R0]						; Load Control and Status Register to R1.
			    MOVS R2, #7							; MOV #7 to R2.
				ORRS R1, R1, R2						; Set CLKSOURCE, TICKINT, and ENABLE flags.	
				STR  R1, [R0]						; Set the Reload Value Register to enable interrupt and timer.
				LDR  R0, =PROGRAM_STATUS			; Load Program Status Variable Addresses.
				MOVS R1, #1							; R1 <- 1
				STR  R1, [R0]						; Store Status Variable as Timer Started.
				POP  {R0-R2, PC}					; Restore saved registers and return with PC.
;//-------- <<< USER CODE END System Tick Timer Initialize >>> ------------------------				
				ENDFUNC

;*******************************************************************************				

;@brief 	This function will be used to stop the System Tick Timer
SysTick_Stop	FUNCTION			
;//-------- <<< USER CODE BEGIN System Tick Timer Stop >>> ----------------------	
				PUSH {R0-R2}						; Save the modified regiters.
				LDR	 R0, =0xE000E010				; Load SYST_CSR Address.
				LDR  R1, [R0]						; Load Control and Status Register to R1.
				LDR  R2, =0xFFFFFFFC				; MOVS Mask value to R2.
				ANDS R1, R1, R2						; Clear TICKINT and ENABLE flags.
				STR  R1, [R0]						; Store the new register value.
													; to disable timer and interrupt.
				LDR  R0, =PROGRAM_STATUS			; Load Program Status Variable Addresses.
				MOVS R1, #2							; R1 <- 1
				STR  R1, [R0]						; Store Status Variable as Timer Stopped.
				POP  {R0-R2}						; Restore saved registers.
				BX LR								; Return.
;//-------- <<< USER CODE END System Tick Timer Stop >>> ------------------------				
				ENDFUNC

;*******************************************************************************				

;@brief 	This function will be used to clear allocation table
Clear_Alloc		FUNCTION			
;//-------- <<< USER CODE BEGIN Clear Allocation Table Function >>> ----------------------															
				PUSH {R0-R2}						; Save the modified regiters.
				LDR  R0,=AT_MEM						; Load Allocation_Table Start Address.
				LDR	 R1,=__AT_END					; Load Allocation Table End Address.
				MOVS R2, #0							; Zero value.
ca_cont			STR  R2, [R0]						; Clear actual value.
				ADDS R0, #4							; Increment address.
				CMP	 R0, R1							; Compare the actual address and the end address.
				BLO  ca_cont						; jump ca_cont, unless all elements clear.
				POP  {R0-R2}						; Restore saved registers.
				BX   LR								; Return.
;//-------- <<< USER CODE END Clear Allocation Table Function >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************		

;@brief 	This function will be used to clear error log array
Clear_ErrorLogs	FUNCTION			
;//-------- <<< USER CODE BEGIN Clear Error Logs Function >>> ----------------------															
				PUSH {R0-R2}						; Save the modified regiters.
				LDR  R0,=LOG_MEM					; Load Error Log Array Start Address.
				LDR	 R1,=__LOG_END					; Load Error Log Array Start End Address.
				MOVS R2, #0							; Zero value.
ce_cont			STR  R2, [R0]						; Clear actual value.
				ADDS R0, #4							; Increment address.
				CMP	 R0, R1							; Compare the actual address and the end address.
				BLO  ce_cont						; jump ce_cont, unless all elements clear.
				POP  {R0-R2}						; Restore saved registers.
				BX   LR								; Return.
;//-------- <<< USER CODE END Clear Error Logs Function >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************

;@brief 	This function will be used to initialize global variables
Init_GlobVars	FUNCTION			
;//-------- <<< USER CODE BEGIN Initialize Global Variables >>> ----------------------															
				PUSH {R0-R1}						; Save the modified regiters.				
				MOVS R1, #0							; R1 <- 0
				LDR  R0, =TICK_COUNT				; Load TICK_COUNT Address.
				STR  R1, [R0]						; Clear TICK_COUNT.
				LDR  R0, =FIRST_ELEMENT				; Load FIRST_ELEMENT Address.
				STR  R1, [R0]						; Clear FIRST_ELEMENT.
				LDR  R0, =INDEX_INPUT_DS			; Load INDEX_INPUT_DS Address.
				STR  R1, [R0]						; Clear INDEX_INPUT_DS.
				LDR  R0, =INDEX_ERROR_LOG			; Load INDEX_ERROR_LOG Address.
				STR  R1, [R0]						; Clear INDEX_ERROR_LOG.
				LDR  R0, =PROGRAM_STATUS			; Load PROGRAM_STATUS Address.
				STR  R1, [R0]						; Clear PROGRAM_STATUS.
				POP  {R0-R1}						; Restore saved registers.
				BX   LR								; Return.
;//-------- <<< USER CODE END Initialize Global Variables >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************	

;@brief 	This function will be used to allocate the new cell 
;			from the memory using the allocation table.
;@return 	R0 <- The allocated area address
Malloc			FUNCTION			
;//-------- <<< USER CODE BEGIN System Tick Handler >>> ----------------------	
				PUSH {R1-R7}						; Save the modified regiters.
				LDR  R0, =AT_MEM					; Load Allocation_Table Start Address
				LDR  R1, =__AT_END					; Load Allocation Table End Address
				MOVS R3, #0							; Allocation index
				MOVS R7, #1							; Comparison value
malloc_cont		MOVS R4, #0							; Bit index
				LDR  R2, [R0]						; Get actual allocation word
malloc_inner	MOVS R5, R2							; Actual value copy
				ANDS R5, R7, R5						; AND (R5 , 1) -> Last bit is zero?
				BEQ  malloc_finish					; If last bit is zero, finish function. 
				LSRS R2, R2, #1						; Shift Allocation word 1 times right
				ADDS R4, #1							; Add 1 to index counter
				CMP	 R4, #32						; CMP bit index with 32 (max + 1)
				BLO  malloc_inner					; Check operation continue if index < 32
				ADDS R0, #4							; Increment address
				ADDS R3, #1							; Increment allocation index
				CMP  R0, R1							; Check If The Allocation Table Is Full
				BLO  malloc_cont					; Jump ca_cont, until the end of the array is reached.
				MOVS R0, #0							; Return value -> 0 means Allocation Table is full.
				B   malloc_ret						; Go return operation
malloc_finish	LDR  R2, [R0]						; Get actual allocation word
				MOVS R5, R4							; Copy index value
				MOVS R6, #1							; Copy 1 value
				LSLS R6, R6, R4						; Shift 1 to the location of the address index bit.
				ORRS R2, R6, R2						; Set the allocated word index bit.
				STR  R2, [R0]						; Store the word
				LSLS R3, R3, #8						; Each alloc table has 4 Byte * 2 Item(address+value) * 32 Elements
				LSLS R4, R4, #3						; Bit index * 8
				ADDS R3, R3, R4						; Index value from start of array
				LDR  R0,=DATA_MEM					; Get start index
				ADDS R0, R0, R3						; Add index to start address
malloc_ret		POP  {R1-R7}						; Restore saved registers.
				BX	 LR								; Return
;//-------- <<< USER CODE END System Tick Handler >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used for deallocate the existing area
;@param		R0 <- Address to deallocate
Free			FUNCTION			
;//-------- <<< USER CODE BEGIN Free Function >>> ----------------------
				PUSH {R1-R5}						; Save the modified regiters.	
				LDR	 R2, =DATA_MEM					; Load Data Memory Start Address
				LDR  R3, =AT_MEM					; Load Allocation_Table Start Address
				SUBS R2, R0, R2						; Get the difference between data address and start address
				MOVS R4, R2							; Copy The Difference Value
				LSRS R4, R4, #6						; Memory address of Allocation Line Offset
				MOVS R5, #3							; MOV 3 value to clear last two bits in the address
				BICS R4, R4, R5						; Clear the last two bits to get line.
				ADDS R4, R3, R4						; Memory address of Allocation Line
				LDR	 R3, [R4]						; Get the allocation line of the Data
				MOVS R5, #0xFF						; Set FF value to get bit index
				ANDS R2, R5, R2						; Get only first 8 bits
				LSRS R2, R2, #3						; Shift 3 bit to divide offset (4 Byte value * 2 Item (address+value))
				MOVS R5, #1							; Copy 1 value
				LSLS R5, R5, R2						; Shift 1 to the location of the address index bit.
				BICS R3, R3, R5					    ; Clear the index bit to release address
				STR	 R3, [R4]						; Store the new line
				POP  {R1-R5}						; Restore saved registers.
				BX	 LR								; Return
;//-------- <<< USER CODE END Free Function >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used to insert data to the linked list
;@param		R0 <- The data to insert
;@return    R0 <- Error Code
Insert			FUNCTION			
;//-------- <<< USER CODE BEGIN Insert Function >>> ----------------------															
				PUSH {R1-R7,LR}						; Save the modified regiters.		
				LDR	 R2, =FIRST_ELEMENT				; Set First Element Pointer Address
				LDR  R1, [R2]						; Load First Element Pointer
				MOVS R3, R0							; MOV Insert Data to R3
				BL	 Malloc							; Find suitable address
				CMP  R0, #0							; Check if address is allocated. 
				BEQ  ins_noalloc					; Return with error!
				STR  R3, [R0]						; Store the value to element
				CMP  R1, #0							; R1 start point of the linked list
				BNE	 ins_chk_first					; If equal zero linked list empty, not find the insert location.
				STR  R0, [R2]						; Set new cell address as First Element
				MOVS R3, #0 						; clear r0
				STR	 R3, [R0,#4]					; Set the next pointer of the element as 0
				MOVS R0, #0 						; No Error Occurs
				B	 ins_ret						; Go to return instruction
ins_chk_first	LDR  R4, [R1]						; Get first element value
				MOVS R6, R1							; Copy the first element addresses
				CMP  R3, R4							; Compare Start element and actual value
				BEQ  ins_exist						; Return with error! //Same data
				BGT  ins_cont						; If actual value less and equal then start element, this value will be first element
				STR  R1, [R0,#4]					; NewElement-> Next = FirstElement
				STR	 R0, [R2]						; Set the New Element as First Element
				MOVS R0, #0 						; No Error Occurs
				B	 ins_ret						; Go to return instruction
ins_cont		LDR  R2, [R1,#4]					; Get next element pointer
				CMP	 R2, #0							; Compare the pointer
				BNE  ins_next_el					; Continue with next element if it is not zero
				STR  R0, [R1,#4]					; LastElement-> Next = NewElement
				STR	 R2, [R0, #4]					; NewElement -> Next = 0 //It is the last element 
				MOVS R0, #0 						; No Error Occurs
				B	 ins_ret						; Go to return instruction
ins_next_el		LDR	 R4, [R2]						; Get CurrentElement->Next->Value
				CMP	 R3, R4							; Compare next value with new value
				BEQ  ins_exist						; Return with error! //Same data
				BLO	 ins_val						; If value less than then next value insert it.
				MOV	 R1, R2							; Else CurrentElement = CurrentElement -> Next
				B	 ins_cont						; Check next element
ins_val			STR	 R2, [R0,#4]					; NewElement->Next = CurrentElement-> Next
				STR  R0, [R1,#4]					; CurrentElement-> Next = NewElement
				MOVS R0, #0 						; No Error Occurs
				B	 ins_ret						; Go to return instruction
ins_exist		BL    Free							; Release allocated area.
				MOVS R0, #2							; Error -> There is same data in the linked list		
				B    ins_ret						;Go to return instruction
ins_noalloc		MOVS R0, #1							; Error -> There is no allocable area.				
ins_ret			POP  {R1-R7, PC}					; Restore saved registers and return with PC.
;//-------- <<< USER CODE END Insert Function >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used to remove data from the linked list
;@param		R0 <- the data to delete
;@return    R0 <- Error Code
Remove			FUNCTION			
;//-------- <<< USER CODE BEGIN Remove Function >>> ----------------------															
				PUSH {R1-R7,LR}						; Save the modified regiters.	
				LDR	 R2, =FIRST_ELEMENT				; Set First Element Pointer Address
				LDR  R1, [R2]						; Load First Element Pointer.
				CMP  R1, #0							; Check the first element is exist.
				BEQ	 rem_empty						; If R1==0; list is empty, return with error.	
rem_cont		LDR  R3, [R1]						; get first element value
				cmp  R0, R3							; Compare value with first value
				bne  rem_loop						; If not equal search other element
				ldr  R4, [R1, #4]					; Get FirstElement -> Next
				STR	 R4, [R2]						; Set FirstElement = FirstElement->Next
				MOVS R0, R1							; Set r0 as argument
				BL	 Free							; Realese first element memory address
				MOVS R0, #0							; Clear r0 as argument
				B	 rem_ret						; Go to return instruction
rem_next		MOV  R1, R2							; Current = Current -> Next
rem_loop		LDR	 R2, [R1,#4]					; Get next element address
				cmp  R2, #0							; While until the next pointer is null
				BEQ  rem_notfound					; Return with error if the pointer is null
rem_check		LDR  R3, [R2]						; Get Current_Element->Next->Value
				CMP	 R3, R0							; Check Current element value with value
				BNE	 rem_next						; Continue with next element if not equal
				LDR	 R3, [R2, #4]					; Get Current_Element->Next->Next
				STR	 R3, [R1, #4]					; Set Current_Element->Next = Current_Element->Next->Next
				movs R0, R2							; Set Current_Element->Next as argument
				BL	 Free							; Free Current_Element->Next
				MOVS R0, #0							; Clear r0 as argument
				B	 rem_ret						; Go to return instruction
rem_empty		MOVS R0, #3							; Error -> Linked List is empty.
				B	 rem_ret						; Go to return instruction
rem_notfound	MOVS R0, #4							; Error -> The data is not found.
rem_ret			POP  {R1-R7, PC}					; Restore saved registers and return with PC.
;//-------- <<< USER CODE END Remove Function >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used to clear the array and copy the linked list to the array
;@return	R0 <- Error Code
LinkedList2Arr	FUNCTION			
;//-------- <<< USER CODE BEGIN Linked List To Array >>> ----------------------															
				PUSH {R1-R3}						; Save the modified regiters.
				LDR  R0, =ARRAY_MEM					; Load Array Start Address.
				LDR  R1, =__ARRAY_END				; Load Array End Address.
				MOVS R2, #0							; Zero value.
arr_clear		CMP  R0, R1							; Compare if R0 reach the end address.
				BHS  arr_copy						; Jump Arr Copy Operation if all value cleared.
				STR  R2, [R0]						; Clear actual address.
				ADDS R0, #4							; Increase the array address.
				B	 arr_clear						; Jump Array Clear.
arr_copy		LDR  R0, =ARRAY_MEM					; Load Array Start Address.
				LDR	 R2, =FIRST_ELEMENT				; Set First Element Pointer Address
				LDR  R2, [R2]						; Load First Element Pointer.
				CMP  R2, #0							; Check if the linked list is empty.
				BEQ  ll_empty						; Return with error if the linked list is empty.
arr_cpy_loop	LDR  R3, [R2]						; Get The Current Element Value 
				STR  R3, [R0]						; Store The Current Element Value
				ADDS R0, #4							; Increase the array address.
				LDR  R2, [R2, #4]					; CurrentElement = CurrentElement -> Next
				CMP  R2, #0							; Check the program reach the linked list end.	 
				BNE  arr_cpy_loop					; Continue if the program does not copy the all elements.
				MOVS R0, #0							; Set R0 = 0 to define function finished without error.
				B    ll2a_ret						; Otherwise, go to return instruction
ll_empty		MOVS R0, #5							; Error -> The linked list is empty. 
ll2a_ret		POP  {R1-R3}     					; Restore saved registers and return with PC.
				BX	 LR
;//-------- <<< USER CODE END Linked List To Array >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used to write errors to the error log array.
;@param		R0 -> Index of Input Dataset Array
;@param     R1 -> Error Code 
;@param     R2 -> Operation (Insertion / Deletion / LinkedList2Array)
;@param     R3 -> Data
WriteErrorLog	FUNCTION			
;//-------- <<< USER CODE BEGIN Write Error Log >>> ----------------------															
				PUSH {R0-R6,LR}						; Save the modified regiters.
				MOVS R4, R0							; Copy R0 to R4.
				BL	 GetNow							; Call GetNow
				LDR  R5, =LOG_MEM					; Load Error Log Start Address.
				LDR  R6, =INDEX_ERROR_LOG			; Load INDEX_ERROR_LOG Address.
				LDR  R6, [R6]						; Load INDEX_ERROR_LOG Value.
				ADDS R5, R5, R6						; Log Address = Start Address + Index
				LDR  R6, =__LOG_END					; Load Error Log End Address.
				CMP	 R5, R6							; Check If Error Log Array is full.
				BHS  wel_end						; Go to wel_end label and do not store the log 
													; if the error log array is full
				STRH R4, [R5, #0]					; Store Index of Input Dataset
				STRB R1, [R5, #2]					; Store Error Code
				STRB R2, [R5, #3]					; Store Operation
				STR	 R3, [R5, #4]					; Store Data
				STR  R0, [R5, #8]					; Store Timestamp (in us)
				LDR  R0, =INDEX_ERROR_LOG			; Load INDEX_ERROR_LOG Address.
				LDR  R1, [R0]						; Load INDEX_ERROR_LOG Value.
				ADDS R1, #12						; Increase INDEX_ERROR_LOG
				STR  R1, [R0]						; Load INDEX_ERROR_LOG Value.
wel_end			POP  {R0-R6, PC}					; Restore saved registers and return with PC.
;//-------- <<< USER CODE END Write Error Log >>> ------------------------				
				ENDFUNC
				
;@brief 	This function will be used to get working time of the System Tick timer
;@return	R0 <- Working time of the System Tick Timer (in us).			
GetNow			FUNCTION			
;//-------- <<< USER CODE BEGIN Get Now >>> ----------------------															
				PUSH {R1-R3}						; Save the modified regiters.
				LDR	 R0, =0xE000E018				; Load SYST_CVR Address.
				LDR	 R1, [R0]						; Load SystemTick Current Value to R1.
				LDR  R0, =TICK_COUNT				; Load TICK_COUNT Address.
				LDR  R2, [R0]						; Get TICK_COUNT.
				LDR R3, =1000						; R3 = Period (1000 us)
				MULS R3, R2, R3						; R3 = R2 * R3 
													; TotalTime = TickCount * Period (Until the last timer interrupt.)
				LDR  R0, =16000						; R0 = 16000 //Reload Value + 1.
				SUBS R0, R0, R1						; Clock cycle count since the last timer interrupt.
													; ClockCycle = Reload Value + 1 - SysTick Current Value
				LSRS R0, R0, #4						; R0 = R0/16 (Time (in us) since the last timer interrupt)
				ADDS R0, R0, R3						; NOW = Time until the last timer interrupt + Time since the last timer interrupt 
				POP  {R1-R3}						; Restore saved registers.
				BX LR
;//-------- <<< USER CODE END Get Now >>> ------------------------
				ENDFUNC
				
;*******************************************************************************	

;//-------- <<< USER CODE BEGIN Functions >>> ----------------------															


;//-------- <<< USER CODE END Functions >>> ------------------------

;*******************************************************************************
;@endsection 		USER_FUNCTIONS
;*******************************************************************************
				ALIGN
				END		; Finish the assembly file
				
;*******************************************************************************
;@endfile 			main.s
;*******************************************************************************				

