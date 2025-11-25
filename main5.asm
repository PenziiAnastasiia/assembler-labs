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
	Captiongreetings db "Лабораторна робота 5", 0
	Textgreetings db "Здоровенькі були!", 13, 10,
					 "Пензій Анастасія Сергіївна", 0

	CaptionBefore db "До використання побітової маски", 0
	TextBufBefore db 800 dup(?)

	CaptionAfter db "Після використання побітової маски", 0
	TextBufAfter db 800 dup(?)

	array dd 25 dup(99999999h)
	my_mask db 10 dup(66h)
	n dd 229
	m dd 74
	

.code
	main:
		invoke MessageBoxA, 0, ADDR Textgreetings, ADDR Captiongreetings, 0

		push offset TextBufBefore
		push offset array
		push 800
		call StrHex_MY
		invoke MessageBoxA, 0, ADDR TextBufBefore, ADDR CaptionBefore, 0

		; маска за варіантом
		mov al, [my_mask+9]
		shr al, 6
		mov [my_mask+9], al

		; виклик методу
		push offset array
		push offset my_mask
		push n
		push m
		call AND_LONGOP

		; друк результатів в діалоговому вікні
		push offset TextBufAfter
		push offset array
		push 800
		call StrHex_MY
		invoke MessageBoxA, 0, ADDR TextBufAfter, ADDR CaptionAfter, 0

		invoke ExitProcess, 0
	end main
