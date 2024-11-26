;---------------------------------------------------------------
; Lab4.asm
;
; Author: Raphael Bauer
;
; This program calculates a ISBN-13 checksum.
; Pass the ISBN as an argument. e.g. `./Lab4.out 978-129-242-010`
;
; Expected output (e.g. for 978-129-242-010):
; ISBN checksum: 3
;
; Expected output (e.g. for 978-3-518-46920):
; ISBN checksum: 0
; ---------------------------------------------------------------

extern printf
extern calc_isbn_checksum

section .data
  format_output: db `ISBN checksum: %d\n`, 0
  format_not_enough_args: db `Please pass an ISBN as an argument!\n`, 0
  format_wrong_format: db `ISBN has a wrong format!\n`, 0

section .text
  global main

main:
  ; Start per convention
	push ebp
	mov ebp, esp
	;-------------------------ARGC-------------------------
	; Load argc
	mov eax, [ebp + 8]
	; Check if an argument was passed -> 2 == one arg. (First arg. is program name)
	cmp eax, 2
	jne handle_wrong_args_amount 					; Wrong amount of args -> Output error


	mov eax, [ebp + 12] 							; Load argv into EAX
	mov eax, [eax + 4] 								; Get passed argument

	;---------Pass argument to `calc_isbn_checksum` and call it--------
	push eax
	call calc_isbn_checksum

	; Check result of EAX - -1: Error
	cmp eax, -1
	je handle_wrong_format

	add esp, 4 										; Remove EAX from stack

	; Pass arguments to `printf` and call it
	push eax
	push format_output
	call printf

	add esp, 8 										; Remove EAX and `format_output` from stack

	mov eax, 0 										; Return 0

	main_exit:
	  leave
		ret

;-------------------------ERROR HANDLING-------------------------
handle_wrong_args_amount:							; Called when the wrong amount of args is given
	push format_not_enough_args
	call printf

	add esp, 4 										; Remove `format_not_enough_args` from stack

	mov eax, -1 									; Return -1
	jmp main_exit


handle_wrong_format: 								; Error: Wrong format
	push format_wrong_format
	call printf

	add esp, 4 										; Remove `format_wrong_format` from stack

	mov eax, -1 									; Return -1
	jmp main_exit
