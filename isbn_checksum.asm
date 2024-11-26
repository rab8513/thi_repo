;================================================================
; isbn_checksum.asm
;
; Author: Raphael Bauer
;
; External procedure for calculating an ISBN checksum.
;================================================================

section .data
  total_running: dd 0
  total_digits: dd 0
  total_dashes: dd 0

section .text
	global calc_isbn_checksum

calc_isbn_checksum:
	push ebp
	mov ebp, esp

	; Address of currently processed ISBN
	mov ebx, [esp + 8]

	; ECX stores the current mulitplication weight
	mov ecx, 3

	; Clean EAX
	mov eax, 0

	; Iterate over the ISBN number
	iterate_isbn:
		mov al, [ebx]							; AL stores the currently processed char / digit

		
		cmp al, 0								; Check for string termination
		je iterate_isbn_exit

		
		cmp al, '-'								; Check for '-'
		je handle_dash

		
		sub al, 48								; Remove bias from ASCII ('0' has ASCII code 48)

		
		cmp al, 0								; Check for "Not a number"
		jl handle_nan

		cmp al, 9
		jg handle_nan

		; NOTE - At this point we have the real ISBN digit stored in AL

		xor ecx, 2 ; Alternate between 1 and 3

		; Calculate next element for `total_running` and add it
		mul ecx

		add dword [total_running], eax

		add ebx, 1 ; Next char in ISBN

		add dword [total_digits], 1 			; Increment `total_digits` by 1

		jmp iterate_isbn

	iterate_isbn_exit:
  	cmp dword [total_dashes], 3					; Check for correct amount of dashes (3)
  	jne handle_wrong_amount_of_dashes

    
  	cmp dword [total_digits], 12				; Check for correct amount of digits (12)
  	jne handle_wrong_amount_of_digits

    ;---------------Calculate final checksum---------------

    ;-----Calculate remainder-----
  	mov ax, [total_running]
    mov dl, 10

    div dl

    cmp ah, 0									; Check if AH is already 0 -> Nothing more to do
    je checksum_already_zero

    mov ebx, 10									; Calculate final checksum
    movzx edx, ah

    sub ebx, edx 								; EBX = EBX - EDX

    mov eax, ebx 								; Return final result

    jmp calc_isbn_checksum_exit

  checksum_already_zero:
    mov eax, 0

	;-------------------------EXIT-------------------------
	calc_isbn_checksum_exit:
  	leave
  	ret
	
	handle_dash:							; Handle '-'
		add dword [total_dashes], 1
		add ebx, 1 ; Next char in ISBN
		
		jmp iterate_isbn


	;-------------------------ERROR HANDLING-------------------------
	
	handle_nan:								; Error: Not a number
		mov eax, -1
		jmp calc_isbn_checksum_exit
	
	handle_wrong_amount_of_dashes:			; Error: Wrong amount of dashes (expected are 3)
		mov eax, -1
		jmp calc_isbn_checksum_exit

	handle_wrong_amount_of_digits:			; Error: Wrong amount of digits
		mov eax, -1
		jmp calc_isbn_checksum_exit
