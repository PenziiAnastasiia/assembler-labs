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
	Captiongreetings db "Лабораторна робота 4", 0
	Textgreetings db "Здоровенькі були!", 13, 10,
					 "Пензій Анастасія Сергіївна", 0

	Caption1 db "66!", 0
	TextBufFactorial66 db 320 dup(?)

	Caption2 db "66! x 66!", 0
	TextBufFact_x_Fact_66 db 640 dup(?)

	Caption3 db "11..1 x 11..1, NxN", 0
	TextBufResultTest1 db 640 dup(?)

	Caption4 db "11..1 x 11..1, Nx32", 0
	TextBufResultTest2 db 320 dup(?)

	Caption5 db "55..5 x 80..01, NxN", 0
	TextBufResultTest3 db 640 dup(?)

	n dd 66								; число n
	ResultFactorial dd 10 dup(0)		; результат n!
	ResultFact_x_Fact dd 20 dup(0)		; результат n1 * n1

	ValueTest1 dd 10 dup(0FFFFFFFFh)	; тест1: число 
	ResultTest1 dd 20 dup(0)			; результат тесту1

	ValueTest2_1 dd 11 dup(0FFFFFFFFh)	; тест2: число1 та результат тесту2
	ValueTest2_2 dd 1 dup(0FFFFFFFFh)	; тест2: число2

	ValueTest3_1 dd 10 dup(55555555h)	; тест3: число1
	ValueTest3_2 dd 10 dup(0)			; тест3: число2
	ResultTest3 dd 20 dup(0)			; результат тесту3
	

.code
	main:
		invoke MessageBoxA, 0, ADDR Textgreetings, ADDR Captiongreetings, 0
		
		; Задача 1: факторіал числа n
		inc ResultFactorial
		@factorial66:
			push offset ResultFactorial	; буфер проміжних та кінцевого результатів
			push n						; число
			call Mul_Nx32_LONGOP		; виклик множення з цими аргументами
			dec n						; зменшення числа
		jne @factorial66

		; Задача 1: вивід результату
		push offset TextBufFactorial66
		push offset ResultFactorial
		push 320
		call StrHex_MY
		invoke MessageBoxA, 0, ADDR TextBufFactorial66, ADDR Caption1, 0

		; Задача 2: квадрат результату факторіала
		push offset ResultFact_x_Fact	; буфер результату
		push offset ResultFactorial		; аргумент1 функції множення
		push offset ResultFactorial		; аргумент2 функції множення
		call Mul_NxN_LONGOP				; виклик множення

		; Задача 2: вивід результату
		push offset TextBufFact_x_Fact_66
		push offset ResultFact_x_Fact
		push 640
		call StrHex_MY
		invoke MessageBoxA, 0, ADDR TextBufFact_x_Fact_66, ADDR Caption2, 0

		; Тест 1: квадрат тестового числа
		push offset ResultTest1			; буфер результату
		push offset ValueTest1			; аргумент1 функції множення
		push offset ValueTest1			; аргумент1 функції множення
		call Mul_NxN_LONGOP				; виклик множення

		; Тест 1: вивід результату
		push offset TextBufResultTest1
		push offset ResultTest1
		push 640
		call StrHex_MY
		invoke MessageBoxA, 0, ADDR TextBufResultTest1, ADDR Caption3, 0

		; Тест 2: множення двох тестових чисел
		mov [ValueTest2_1+40], 0
		push offset ValueTest2_1
		push ValueTest2_2
		call Mul_Nx32_LONGOP

		; Тест 2: вивід результату
		push offset TextBufResultTest2
		push offset ValueTest2_1
		push 352
		call StrHex_MY
		invoke MessageBoxA, 0, ADDR TextBufResultTest2, ADDR Caption4, 0

		; Тест 3: множення двох тестових чисел
		mov [ValueTest3_2], 1
		mov [ValueTest3_2+36], 80000000h
		push offset ResultTest3
		push offset ValueTest3_1
		push offset ValueTest3_2
		call Mul_NxN_LONGOP

		; Тест 3: вивід результату
		push offset TextBufResultTest3
		push offset ResultTest3
		push 640
		call StrHex_MY
		invoke MessageBoxA, 0, ADDR TextBufResultTest3, ADDR Caption5, 0

		invoke ExitProcess, 0
	end main
