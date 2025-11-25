.586
.model flat, stdcall
option casemap :none

include \masm32\include\kernel32.inc
include \masm32\include\user32.inc
include module.inc
include longop.inc

includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\user32.lib

.data
	Captiongreetings db "Лабораторна робота 6", 0
	Textgreetings db "Здоровенькі були!", 13, 10,
					 "Пензій Анастасія Сергіївна", 0

	Caption1 db "66!", 0
	TextBufFactorial66 db 320 dup(?)

	Caption2 db "Формула", 0
	TextBufY db 32 dup(?)

	n dd 66
	ResultFactorial dd 12 dup(0)

	x dd 0FFFFFFF0h
	y dd 0
	m db 3
	

.code
	main:
		invoke MessageBoxA, 0, ADDR Textgreetings, ADDR Captiongreetings, 0

		inc ResultFactorial
		@factorial66:
			push offset ResultFactorial
			push n
			call Mul_Nx32_LONGOP
			dec n
		jne @factorial66
		
		push offset ResultFactorial
		push 384
		push offset TextBufFactorial66
		call StrDec
		invoke MessageBoxA, 0, ADDR  TextBufFactorial66, ADDR Caption1, 0

		inc m			; m + 1
		mov cl, m
		mov eax, x
		shl eax, cl		; x * 2^(m+1)
		mov x, eax
		shr eax, 16		; старші розряди
		mov dx, ax		; старші розряди в регістр dx
		mov eax, x		; молодші розряди в регістр ax
		and eax, 0000FFFFh
		mov bx, 9
		idiv bx			; x * 2^(m+1) / 9
		dec ax
		xor ax, 0FFFFh
		mov y, eax		; частковий результат
		mov [TextBufY], '-'

		push offset y
		push 16
		push offset TextBufY
		call StrDec
		invoke MessageBoxA, 0, ADDR  TextBufY, ADDR Caption2, 0

		invoke ExitProcess, 0
	end main
