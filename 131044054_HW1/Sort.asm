        ; 8080 assembler code
        .hexfile Sort.hex
        .binfile Sort.com
        ; try "hex" for downloading in hex format
        .download bin  
        .objcopy gobjcopy
        .postbuild echo "OK!"
        ;.nodump

	; OS call list
PRINT_B		equ 1
PRINT_MEM	equ 2
READ_B		equ 3
READ_MEM	equ 4
PRINT_STR	equ 5
READ_STR	equ 6
GET_RND 	equ 7

	; Position for stack pointer
stack   equ 0F000h

	org 000H
	jmp begin

	; Start of our Operating System
GTU_OS:	PUSH D
	push D
	push H
	push psw
	nop	; This is where we run our OS in C++, see the CPU8080::isSystemCall()
		; function for the detail.
	pop psw
	pop h
	pop d
	pop D
	ret
	; ---------------------------------------------------------------
	; YOU SHOULD NOT CHANGE ANYTHING ABOVE THIS LINE        

	;File that produces 50 random bytes, sorts them in increasing order and prints them
	;on screen.

integerList: DS 100

SIZE: DS 1
Areg: DS 1
Breg: DS 1
Dreg: DS 1

begin:
	LXI SP,stack 		; always initialize the stack pointer		
	LXI H,integerList 	; HL -> Adress
	MVI A,100			;
	STA SIZE			; n=SIZE	
	MVI C,0             ;


random:	
    MVI A, GET_RND	    ; store the OS call code to A
    call GTU_OS		    ; call the OS	
	MOV M,B             ; (HL) <- RND	
 	LDA SIZE            ;     
	INX H               ;
	INX H               ;
	INR C               ;
	INR C               ;
	SUB C               ;
	JNZ random          ;
	JMP sortFunction    ; 

sortFunction:
	LXI H,integerList 	; HL -> Adress	
	MVI B,0				; i=0
	JMP outerLoop       ;

outerLoop:
    MVI C,0				; j=0
	LDA SIZE            ; n=SIZE
	CMP B 				; A-B --> n-i
	JZ print			; i == n --> print
	JP innerLoop        ; i < n  
	JMP print           ; outerLoop biterse print e git


innerLoop:
	LDA SIZE            ; n=SIZE
	DCR A               ; A=n-1
	DCR A               ; A=n-1
	CMP C 				; A-C --> (n-1)-j
	JZ inner_to_outer   ; j == (n-1)
	JP condition		; j < (n-1)
	JMP inner_to_outer  ; j > (n-1)


inner_to_outer:
	INR B 				; i++
	INR B				; i++
	JMP outerLoop    	; innerLoop biterse innerLoop a git


condition:
    LXI H,integerList 	; HL -> Adress
    MVI D,0				; D=0
	MOV E,C             ; E=j       DE --> j
	DAD D               ; HL <­ HL + DE yani array[j]
    MOV A,M             ; A<--array[j]
    STA Areg            ;

    LXI H,integerList 	; HL -> Adress
	MVI D,0				; D=0
	MOV E,C             ; E=j        DE --> j
	DAD D               ; HL <­ HL + DE yani array[j]
	INX H 				; HL++
	INX H               ; HL++
	MOV D,M             ; D<--array[j+1]

	CMP D               ; A-D
	JNC swap      		; array[j] > array[j+1]
	INR C				; j++
	INR C				; j++
	JMP innerLoop       ; condition dogru degilse j++ innerLoop

swap:
	MOV A,B             ; A = B
	STA Breg            ; Breg = A  ==> Breg = B

	LDA Areg 
    MOV M,A             ; array[j+1] = array[j]
    DCX H 				; HL--	
    DCX H 				; HL--
	MOV M,D             ; array[j] = array[j+1]

	LDA Breg            ; A = Breg
	MOV B,A             ; B = Breg
    INR C				; j++
    INR C				; j++
    JMP innerLoop       ; 

print:
	MVI C,0				; i=0
    JMP printCondition  ;

printCondition:
   	LDA SIZE            ; n=SIZE
   	CMP C 				; A-C --> n-i
   	JZ exit    			; i == n --> exit
   	JP printScreen      ; i < n
   	JMP exit          	;

printScreen:
    LXI H,integerList 	; HL -> Adress
    MVI D,0				; D=0
	MOV E,C             ; E=i       DE --> i
	DAD D               ; HL <­ HL + DE yani array[i]
    MOV B,M             ; B<--array[i]
    MVI A, PRINT_B	    ; store the OS call code to A
    call GTU_OS		    ; call the OS
    INR C				; i++
    INR C				; i++
    JMP printCondition  ;

exit:
	hlt				    ; end program