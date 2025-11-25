.586
.model flat, stdcall
option casemap :none

include \masm32\include\kernel32.inc
include \masm32\include\user32.inc
include \masm32\include\windows.inc
include \masm32\include\comdlg32.inc
include module.inc
include longop.inc

includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\comdlg32.lib


.data
	Captiongreetings db "Лабораторна робота 8", 0
	Textgreetings db "Здоровенькі були!", 13, 10,
					 "Пензій Анастасія Сергіївна", 0
	
	szFileName db 256 dup(0)
	szTextBuf db 384 dup(?)
	newLine db 13, 10
	hFile dd 0

	pResult dd ?
	pValue dd ?
	n dd 1


.code
	MySaveFileName proc
		LOCAL ofn : OPENFILENAME
		invoke RtlZeroMemory, ADDR ofn, SIZEOF ofn		; спочатку усі поля обнулюємо
		mov ofn.lStructSize, SIZEOF ofn
		mov ofn.lpstrFile, OFFSET szFileName
		mov ofn.nMaxFile, SIZEOF szFileName
		invoke GetSaveFileName,ADDR ofn					; виклик вікна File Save As
		ret
	MySaveFileName endp

	main:
		invoke MessageBoxA, 0, ADDR Textgreetings, ADDR Captiongreetings, 0

		call MySaveFileName				; вибір файлу з діалогового вікна
		cmp eax, 0
		je @exit						; файл не обрано 

		invoke CreateFile, ADDR szFileName,			; відкриття або створення файлу із зазначеним імʼям
						   GENERIC_WRITE,
						   FILE_SHARE_WRITE,
					 	   0, CREATE_ALWAYS,
						   FILE_ATTRIBUTE_NORMAL,
						   0
		cmp eax, INVALID_HANDLE_VALUE
		je @exit						; доступ до файлу неможливий
		mov hFile, eax

		invoke GlobalAlloc, GPTR, 768	; динамічний блок памʼяті для двох масивів
		mov pResult, eax				; масив для результату факторіалів
		mov dword ptr [eax], 1			; початкове значення факторіалу
		add eax, 384
		mov pValue, eax					; масив для запису результату факторіалів у буфер

		@factorial_1_66:
			push pResult
			push n
			call Mul_Nx32_LONGOP

			push pResult
			push pValue
			push 384
			call Copy_LONGOP

			lea ebx, szTextBuf
			mov ecx, 24
			xor eax, eax
			@loop:						; цикл, який обнулює буфер
				mov [ebx], eax
				add ebx, 4
				dec ecx
			jnz @loop

			push pValue
			push 384
			push offset szTextBuf
			call StrDec

			invoke WriteFile, hFile, ADDR szTextBuf, 384, NULL, 0	; запис факторіалу у файл
			invoke WriteFile, hFile, ADDR newLine, 2, NULL, 0		; наступний рядок файлу
			invoke WriteFile, hFile, ADDR newLine, 2, NULL, 0		; наступний рядок файлу
			
			inc n
			mov eax, n
			cmp eax, 66
		jle @factorial_1_66

		invoke CloseHandle, hFile				; закрити файл
		invoke GlobalFree, pResult				; знищення динамічного блоку памʼяті
		@exit:
		invoke ExitProcess, 0
	end main