.586
.model flat, c
.code

; процедура StrHex_MY записує текст шістнадцяткового коду
; перший параметр - адреса буфера результату (рядка символів)
; другий параметр - адреса числа
; третій параметр - розрядність числа у бітах (має бути кратна 8)

StrHex_MY proc
	push ebp
	mov ebp,esp

	mov ecx, [ebp+8]    		; кількість бітів числа
	cmp ecx, 0
	jle @exitp
	shr ecx, 3 ;кількість байтів числа
	mov esi, [ebp+12]   		; адреса числа
	mov ebx, [ebp+16]   		; адреса буфера результату
@cycle:
	mov dl, byte ptr[esi+ecx-1]	; байт числа - це дві hex-цифри

	mov al, dl
	shr al, 4 					; старша цифра
	call HexSymbol_MY
	mov byte ptr[ebx], al

	mov al, dl 					; молодша цифра
	call HexSymbol_MY
	mov byte ptr[ebx+1], al

	mov eax, ecx
	cmp eax, 4
	jle @next
	dec eax
	and eax, 3 					; проміжок розділює групи по вісім цифр
	cmp al, 0
	jne @next
	mov byte ptr[ebx+2], 32 	; код символа проміжку
	inc ebx
@next:
	add ebx, 2
	dec ecx
	jnz @cycle
	mov byte ptr[ebx], 0 		; рядок закінчується нулем
@exitp:
	pop ebp
	ret 12
StrHex_MY endp


; ця процедура обчислює код hex-цифри
; параметр - значення AL
; результат -> AL

HexSymbol_MY proc
	and al, 0Fh
	add al, 48 			; так можна тільки для цифр 0-9
	cmp al, 58
	jl @exitp
	add al, 7 			; для цифр A,B,C,D,E,F
@exitp:
	ret
HexSymbol_MY endp


; ця процедура записує 8 символів HEX коду числа
; перший параметр - 32-бітне число
; другий параметр - адреса буфера тексту

DwordToStrHex proc
	push ebp
	mov ebp,esp
	mov ebx,[ebp+8] 	; другий параметр
	mov edx,[ebp+12] 	; перший параметр
	xor eax,eax
	mov edi,7
@next:
	mov al,dl
	and al,0Fh 			; виділяємо одну шістнадцяткову цифру
	add ax,48 			; так можна тільки для цифр 0-9
	cmp ax,58
	jl @store
	add ax,7 			; для цифр A,B,C,D,E,F
@store:
	mov [ebx+edi],al
	shr edx,4
	dec edi
	cmp edi,0
	jge @next
	pop ebp
	ret 8
DwordToStrHex endp

end
