        ; 8080 assembler code
        .hexfile BinarySearch.hex
        .binfile BinarySearch.com
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

	;Produces 50 random bytes and sorts them. Your program then take a
	;number from the keyboard, makes a binary search on these numbers. If found prints the
	;memory address else prints "error"


integerList: DS 100
bulundu: dw 'Aranan Elemanin Bulundugu Adres : ',00AH,00H ; null terminated string
hata:	dw 'Aranan Eleman Bulunamadi. ',00AH,00H ; null terminated string


SIZE: DS 1
Areg: DS 1
Breg: DS 1
Dreg: DS 1

first: DS 1
last : DS 1
value: DS 1 
index: DS 1 


begin:
	LXI SP,stack 		; always initialize the stack pointer		
	LXI H,integerList 	; HL -> Adress
	MVI A,100			;
	STA SIZE			; n=SIZE	
	MVI C,0             ;


;RANDOM NUMBERS
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



;SORT FUNCTIONS
sortFunction:
	LXI H,integerList 	; HL -> Adress	
	MVI B,0				; i=0
	JMP outerLoop       ;

outerLoop:
    MVI C,0				; j=0
	LDA SIZE            ; n=SIZE
	CMP B 				; A-B --> n-i
	JZ searchFunction	; i == n 
	JP innerLoop        ; i < n  
	JMP searchFunction  ; outerLoop biterse

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

	LDA Areg            ;
    MOV M,A             ; array[j+1] = array[j]
    DCX H 				; HL--	
    DCX H 				; HL--
	MOV M,D             ; array[j] = array[j+1]

	LDA Breg            ; A = Breg
	MOV B,A             ; B = Breg
    INR C				; j++
    INR C				; j++
    JMP innerLoop       ; 



;SEARCH FUNCTIONS
searchFunction:
	LXI H,integerList 	; HL -> Adress

	;Aranacak degeri kullanıcıdan okuma
    MVI A, READ_B	    ; store the OS call code to A
    call GTU_OS		    ; call the OS
    MOV A,B             ;
    STA value           ;

	MVI A,0             ; first = 0
	STA first			; first = 0

	LDA SIZE	        ;
	DCR A               ;
	DCR A               ; last = SIZE -1
	STA last            ; last = SIZE -1

	MVI C,0             ;
	JMP print           ;

print:
	MVI C,0				; i=0
    JMP printCondition  ;

printCondition:
   	LDA SIZE            ; n=SIZE
   	CMP C 				; A-C --> n-i
   	JZ binarySearch		; i == n --> exit
   	JP printScreen      ; i < n
   	JMP binarySearch    ;

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


binarySearch:
	LDA first           ; 
	MOV C,A             ;
	LDA last 	        ;
	SUB C               ; last - first > 0
	JNC middle          ;  
	JMP notFound        ;

middle:
	LDA first           ;
	MOV C,A             ;
	LDA last            ;

	ADD C               ; A = last + first
	RAR                 ; A = (last + first)/2 
	ANI 254             ; 254 --> 1111 1110 cift yapma 

	LXI H,integerList 	; HL -> Adress
    MVI D,0				; D=0
	MOV E,A             ; E=middle  DE --> middle
	DAD D               ; HL <­ HL + DE yani array[middle]
    MOV B,M             ; B<--array[middle]
    STA index           ; 
    

    ;array[middle] == value
    LDA value     		; A = value 
    SUB B               ; A = value - array[middle]
    JZ found            ;

    ;value > array[middle]
    LDA value           ;
    MOV B,M             ; B<--array[middle]
    SUB B               ; A = value - array[middle] > 0
    JNC rightSearch     ;

    ;value < array[middle]
    JMP leftSearch      ;  


found:
	LXI B, bulundu	    ;
	MVI A, PRINT_STR	; store the OS call code to A
	call GTU_OS	 		; call the OS

	LDA index           ; bulunan index	
	LXI H,integerList 	; HL -> Adress
    MVI D,0				; D=0
	MOV E,A             ; E=middle  DE --> middle
	DAD D               ; HL <­ HL + DE yani array[middle]

	MOV B,L             ;
    MVI A, PRINT_B	    ; store the OS call code to A
    call GTU_OS		    ; call the OS
	JMP exit	        ;

rightSearch:
	LDA index           ; A = middle
	INR A               ;
	INR A               ; middle + 1 
	STA first           ; 
	JMP binarySearch    ;

leftSearch:
	LDA index           ; A = middle
	DCR A               ;
	DCR A               ; middle + 1 
	STA last            ;
	JMP binarySearch    ;

notFound:
	LXI B, hata	        ;
	MVI A, PRINT_STR	; store the OS call code to A
	call GTU_OS	 		; call the OS
	JMP exit			;


;EXIT
exit:
	hlt					; end program