        ; 8080 assembler code
        .hexfile PrintNumbers.hex
        .binfile PrintNumbers.com
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

	;File that prints integers from 0 to 50 by steps of 2 on the screen. Each
	;number will be printed on a new line.


begin:
	LXI SP,stack 	; always initialize the stack pointer	
	MVI C,26		; C=26 initialize
	MVI B,0			; B=0  initialize

loop:
	MVI A, PRINT_B	; store the OS call code to A
	call GTU_OS		; call the OS	
	INR B      		; B++
	INR B      		; B++
	DCR C      		; C--
	JNZ loop	    ; go to loop if C!=0
	
	hlt				; end program
