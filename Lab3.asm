;---------------------------------------------------------------
; Lab3.asm
;
; Author: Kevin Koenigseder, Raphael Bauer
;
;
; This program calculates the Collatz sequence.
; Pass the start value as an argument. e.g. `./Lab3.out 13`
;
;
; Expected output (e.g. for 13):
; 13
; 40
; 20
; 10
; 5
; 16
; 8
; 4
; 2
; 1
; ---------------------------------------------------------------

extern printf ; Using the C function for output - the object file needs to be linked with a C library
extern atoi   ; Using the C function for converting string to int

section .data
  wrong_args_passed_err_msg: db `Wrong arguments. Please pass one positive integer as an argument!\n`, 0 ; Error for wrong / no arguments

  decformat: db `%d\n`, 0 ; Define the (unsigned) decimal format for use with C's `printf` function 

section .text ; Code segment starts here
  global main

; Main function
main:
  ; Start per convention
  push ebp
  mov ebp, esp

  mov eax, [esp + 8] ; Load argc
  
  ; Check if an argument was passed -> 2 == one arg
  cmp eax, 2
  jne wrong_args_passed ; Wrong arguments -> Output error

  mov eax, [esp + 12] ; Load argv into eax
  mov eax, [eax + 4] ; Get passed argument

  ; Convert String to integer using atoi
  push eax
  call atoi

  ; Note: At this point the passed value is saved as integer in eax

  add esp, 4 ; Remove eax from stack

  ; Check if passed value is valid
  cmp eax, 1
  jl wrong_args_passed ; Check if passed integer is less than 1 -> Output error

; Calculate Collatz sequence
calc_collatz:
  ; Output number
  push eax
  push decformat
  call printf

  add esp, 4 ; Remove decformat from stack
  pop eax ; Reassign eax

  ; Check if we already reached '1' -> End the loop
  cmp eax, 1
  je end

  ; Check if the number is even or odd
  test eax, 1b
  jnz n_odd ; Jump if zero-flag is not zero

; Calc next Collatz item if the number is even
n_even:
  shr eax, 1 ; Right shift -> eax = eax / 2
  jmp calc_collatz

; Calc next Collatz item if number is odd
n_odd:
  imul eax, 3 ; eax = 3 * eax + 1
  add eax, 1

  jmp calc_collatz

; Wrong args were passed -> Error
wrong_args_passed:
  push wrong_args_passed_err_msg
  call printf

  add esp, 4 ; Remove `wrong_args_passed_err_msg` from stack

; Stop the program
end:
  mov eax, 0 ; return 0

  ; Exit the program per convention
  leave
  ret