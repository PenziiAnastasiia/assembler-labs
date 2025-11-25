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
	Captiongreetings db "Лабораторна робота 7", 0
	Textgreetings db "Здоровенькі були!", 13, 10,
					 "Пензій Анастасія Сергіївна", 0

	Caption db "Res", 0
	TextBuf db 32 dup(?)

	n db 7													; розмірність масивів
	A dd 1.1093, 2.0923, 5.13, 5.4563, 3.56, 8.531, 5.672	; масив
	B dd 3.21, 2.10134, 3.4567, 2.3156, 1.001, 6.11, 3.9919	; масив
	Res dd ?												; результат пошуку максимального квадрата різниці

.code
	main:
		invoke MessageBoxA, 0, ADDR Textgreetings, ADDR Captiongreetings, 0

		xor ecx, ecx
		@cycle:
			fld [A+4*ecx]		; число A
			fsub [B+4*ecx]		; A - B
			fmul st(0), st(0)	; (A - B)^2
			fcom Res			; порівняння зі значенням, що знаходиться в Res
			fstsw ax			; збереження регістрів статусу в регістр ax
			sahf				; встановлення системних прапорів 
			jb @next			; якщо Res менше за значення на вершині стеку, то
				fstp Res		; Res = st(0)
			@next:
				inc ecx
				cmp cl, n
				jl @cycle

		push offset TextBuf
		push offset Res
		call FloatToDec

		invoke MessageBoxA, 0, ADDR  TextBuf, ADDR Caption, 0

		invoke ExitProcess, 0
	end main