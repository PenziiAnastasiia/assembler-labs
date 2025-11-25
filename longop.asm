.586
.model flat, c
.data
	b dd ?
	n db ?
	counter dd ?
	zsuv_cycle_2 dd ?
	index_for_A dd ?
	index_for_B dd ?
	great dd ?


	m dd ?
	N_byte dd ?
	N_bit_position dd ?
	M_byte dd ?
	M_bit_position dd ?
	array_bit db 0
	mask_bit db 0

	i dd ?


.code

; процедура додавання двох 640-бітних чисел з переносом
; перший аргумент - адреса числа A
; другий аргумент - адреса числа B
; третій аргумент - адреса результату

Add_640_LONGOP proc
	push ebp
	mov ebp,esp
	mov esi, [ebp+16]						; ESI = адреса A
	mov ebx, [ebp+12]						; EBX = адреса B
	mov edi, [ebp+8]						; EDI = адреса результату
	mov ecx, 21 	    					; ECX = потрібна кількість повторень
	mov edx, 0								; EDX = зсув

	clc										; обнулює біт CF регістру EFLAGS

	cycle:
		mov eax, dword ptr[esi+4*edx]		; 32-бітна група A
		adc eax, dword ptr[ebx+4*edx]		; додавання з переносом 32-бітів числа B
		mov dword ptr[edi+4*edx], eax

		inc edx								; зсув збільшуємо на 1
		dec ecx								; лічильник зменшуємо на 1
	jnz cycle								; якщо лічильник не 0, то перехід на мітку cycle

	pop ebp									; відновлення стеку
	ret 12									; вихід з поверненням 3 байтів стеку
Add_640_LONGOP endp


; процедура віднімання двох 480-бітних чисел з переносом
; перший аргумент - адреса числа A
; другий аргумент - адреса числа B
; третій аргумент - адреса результату

Sub_480_LONGOP proc
	push ebp
	mov ebp,esp
	mov esi, [ebp+16]						; ESI = адреса A
	mov ebx, [ebp+12]						; EBX = адреса B
	mov edi, [ebp+8]						; EDI = адреса результату
	mov ecx, 15								; ECX = потрібна кількість повторень
	mov edx, 0								; EDX = зсув

	clc										; обнулює біт CF регістру EFLAGS

	cycle:
		mov eax, dword ptr[esi+4*edx]		; 32-бітна група числа A
		sbb eax, dword ptr[ebx+4*edx]		; віднімання з переносом 32-бітів числа B
		mov dword ptr[edi+4*edx], eax

		inc edx								; зсув збільшуємо на 1
		dec ecx								; лічильник зменшуємо на 1
	jnz cycle								; якщо лічильник не 0, то перехід на мітку cycle

	pop ebp									; відновлення стеку
	ret 12									; вихід з поверненням 3 байтів стеку
Sub_480_LONGOP endp


; процедура множення довгим алгоритмом
; перший аргумент - адреса числа A розрядності N біт
; другий аргумент - адреса числа B розрядності 32 біт
; результат множення записується за адресою числа A

Mul_Nx32_LONGOP proc
    push ebp
	mov ebp, esp
	mov edi, [ebp+12]						; EDI = адреса A та результату
	mov ebx, [ebp+8]						; EBX = адреса B
	mov b, ebx								; запис 32-бітного числа в глобальну змінну b
	mov n, 10								; кількість 32-бітних груп у числі A

    xor ebx, ebx                           	; EBX = старші 32 біти попереднього результату множення
    xor ecx, ecx                           	; ECX = зсув
    xor edx, edx                           	; EDX = старші 32 біти поточного результату множення

	@mul_Nx32:
		mov eax, [edi+4*ecx]				; 32-бітна група числа A
		mul b								; множення на 32-бітне число b
		mov [edi+4*ecx], eax				; запис молодших 32-бітів результату
		clc									; обнулює біт CF регістру EFLAGS
		adc [edi+4*ecx], ebx				; додавання до молодшої групи результату старшої групи минулого результату множення
		mov ebx, edx						; старші 32 розряди результату множення для наступної ітерації стануть молодшими

		inc ecx								; i++
		dec n								: N--
    jnz @mul_Nx32							; якщо N не 0, перейти на початок циклу
	clc						
	adc [edi+4*ecx], ebx					; інакше враховуємо останній (найстарший) перенос

	pop ebp									; відновлення стеку
	ret 8									; вихід з поверненням 2 байтів стеку
Mul_Nx32_LONGOP endp


; процедура множення довгим алгоритмом
; перший аргумент - адреса результату
; другий аргумент - адреса числа A розрядності N біт
; третій аргумент - адреса числа B розрядності N біт

Mul_NxN_LONGOP proc
	push ebp
	mov ebp, esp
	mov ebx, [ebp+16]						; EBX = адреса результату
	mov edi, [ebp+12]						; EDI = адреса A
	mov esi, [ebp+8]						; ESI = адреса B
	mov counter, 10							; кількість 32-бітних груп числа B
	mov index_for_B, 0						; індекс 32-бітної групи числа B
  
	@mul_NxN:
		mov index_for_A, 0					; індекс 32-бітної групи числа A
		mov ecx, index_for_B
		mov zsuv_cycle_2, ecx				; зсув для запису результатів
		mov eax, [esi+4*ecx]				; 
		mov b, eax							; запис 32-бітної групи числа B в глобальну змінну b
		mov n, 10							; кількість 32-бітних груп числа A

		xor edx, edx						; EDX = старші 32 біти поточного результату множення
		mov great, 0						; змінна для старшої 32-бітної групи множення

		@mul_Nx32:
			mov ecx, index_for_A
			mov eax, [edi+4*ecx]    		; 32-бітна група числа A
			mul b							; множення 32-бітної групи числа A на 32-бітне число B

			mov ecx, zsuv_cycle_2
			clc
			adc [ebx+4*ecx], eax			; додавання до результату молодшої 32-бітної групи 
			mov eax, great
			clc
			adc [ebx+4*ecx], eax			; додавання до результату старшої 32-бітної групи з попередньої ітерації
			mov great, edx					; старшої 32 розряди результату множення для наступної ітерації стануть молодшими

			inc index_for_A
			inc zsuv_cycle_2
			dec n
		jnz @mul_Nx32						; якщо N не 0, перейти на початок циклу
		clc
		adc [ebx+4*ecx+4], edx				; додавання найстаршої групи множення після циклу1 до результату

		inc index_for_B
		dec counter
	jnz @mul_NxN

	pop ebp									; відновлення стеку
	ret 12									; вихід з поверненням 3 байтів стеку
Mul_NxN_LONGOP endp


; процедура для виконання побітового І між масивом і маскою
; перший аргумент - адреса масиву, що міститиме результуючий масив
; другий аргумент - адреса маски
; третій аргумент - N біт, з якого необхідно почати виконувати І
; четвертий аргумент - кількість M бітів, протягом яких треба виконати І

AND_LONGOP proc
	push ebp
	mov ebp, esp
	mov edi, [ebp+20]						; EDI = адреса масиву
	mov esi, [ebp+16]						; ESI = адреса маски
	mov ebx, [ebp+12]						; EBX = біт N
	mov edx, [ebp+8]						; EDX = кількість M бітів
	mov m, edx
	mov M_byte, 0
	mov M_bit_position, 0

	mov ecx, ebx
	shr ebx, 3								; номер байту, в якому знаходиться біт N
	and ecx, 07h							; бітова позиція в байті
	mov N_byte, ebx
	mov N_bit_position, ecx

	@cycle:
		mov ebx, M_byte
		mov ecx, M_bit_position
		mov al, 1
		shl al, cl							; маска вирізання M-біту (00..010..00)
		mov ah, [esi+4*ebx]
		and ah, al
		mov mask_bit, ah					; збереження значення M-біту з маски

		mov ebx, N_byte
		mov ecx, N_bit_position
		mov al, 1
		shl al, cl							; маска вирізання N-біту (00..010..00)
		mov ah, [edi+ebx]
		and ah, al
		mov array_bit, ah					; збереження значення N-біту з масиву
		
		and ah, mask_bit					; виконуємо AND
		cmp ah, array_bit					; порівняння результату зі значенням біту в початковому масиві
		je @changes_dont_need				; якщо змін не відбулось, переходимо на відповідну мітку
			cmp ah, 0						; порівнюємо результат з 0
			jne @ifone						; якщо результат не дорівнює нулю, переходимо на мітку
				not al
				and [edi+ebx], al			; встановлення нуля на місце поточного байту в масиві
				jmp @changes_dont_need
			@ifone:							; мітка, яка встановлює одиницю на місце поточного байту в масиві
				or [edi+ebx], al
				jmp @changes_dont_need
		@changes_dont_need:				
			inc N_bit_position				; підвищуємо бітову позицію в байті
			cmp N_bit_position, 8			; переконуємось в тому, що позиція не вийшла за межі байту
			jne @not_equal1					; якщо не вийшла, переходимо на відповідну мітку
				mov N_bit_position, 0		; якщо вийшла, тоді бітову позицію скидуємо до 0,
				inc N_byte					; а номер байту підвищуємо на одиницю
				jmp @not_equal1
			@not_equal1:
				inc M_bit_position
				cmp M_bit_position, 8		; переконуємось в тому, що позиція не вийшла за межі байту
				jne @not_equal2				; якщо не вийшла, переходимо на відповідну мітку
					mov M_bit_position, 0	; якщо вийшла, тоді бітову позицію скидуємо до 0,
					inc M_byte				; а номер байту підвищуємо на одиницю
					jmp @not_equal2
				@not_equal2:
					dec m
	jnz @cycle								; якщо M не 0, перейти на початок циклу

	pop ebp									; відновлення стеку
	ret 16									; вихід з поверненням 4 байтів стеку
AND_LONGOP endp


; побітове ділення великого числа на 10 методом старших розрядів

DIV10_LONGOP proc
	; попередньо, в регістрах повинні лежати:
	; edi - адреса числа A
	; ecx - кількість бітів числа
	; esi -	адреса часткового результату
	; edx - адреса залишку

	mov eax, ecx
	sub eax, 4
	mov i, eax					; запис і
	sub ecx, 1
	shr ecx, 3					; номер старшого байту числа A

	xor eax, eax
	mov ah, [edi+ecx]
	shr ah, 4					; 4 старші розряди старшого байту діленого 
	
	@cycle:
	mov ebx, i
	mov ecx, ebx
	shr ebx, 3					; байт запису часткового результату D
	and ecx, 07h				; позиція потрібного біту у байті
	mov al, 1
	shl al, cl					; маска 0.010.0

	cmp ah, 10
	jl @B_is_greater_than
		or [esi+ebx], al		; запис 1 у результат D
		sub ah, 10				; R - 10
		jmp @next
	@B_is_greater_than:
		not al
		and [esi+ebx], al		; запис 0 у результат D
		jmp @next
	@next:
		dec i
		js @end
		shl ah, 1				; зсув R вліво
		and ah, 00001111b		; залишаємо лише 4 біти
		mov ebx, i
		mov ecx, ebx
		shr ebx, 3				; байт наступного біту числа A
		and ecx, 07h			; позиція наступного біту числа A
		mov al, 1
		shl al, cl				; маска 0.010.0
		mov bh, [edi+ebx]
		and bh, al				; значення наступного біту числа A
		cmp bh, 0
		je @cycle				; якщо значення біту = 1
			add ah, 1			; то R = R + 1
			jmp @cycle
	@end:
	mov [edx], ah				; запис залишку R
	ret							; вихід без очищення стеку
DIV10_LONGOP endp


; ділення великого числа на 10 побайтно від старшого до молодшого

DIV10_groups8_LONGOP proc
	; попередньо, в регістрах повинні лежати:
	; edi - адреса числа A
	; ecx - кількість бітів числа
	; esi -	адреса часткового результату
	; edx - адреса залишку

	shr ecx, 3					; кількість байтів
	mov bl, 10
	xor ah, ah

	@cycle:
		mov al, [edi+ecx-1]		; старший байт числа A
		div bl
		mov [esi+ecx-1], al		; запис часткового результату D
		dec ecx
	jnz @cycle
	mov [edx], ah				; запис залишку R
	ret							; вихід без очищення стеку
DIV10_groups8_LONGOP endp


; процедура копіювання масиву даних з одного місця памʼяті в інше блоками по 4 байти
; перший аргумент - адреса джерела даних
; другий аргумент - адреса призначення даних
; третій аргумент - кількість бітів, що необхідно скопіювати

Copy_LONGOP proc
	push ebp
	mov ebp, esp
	mov edi, [ebp+16]			; адреса звідки копіювати дані
	mov esi, [ebp+12]			; адреса куди копіювати дані
	mov edx, [ebp+8]			; кількість бітів

	shr edx, 4					; кількість блоків по 32 біти				
	mov ecx, 1					; лічильник скопійованих блоків

	@cycle:
		mov eax, [edi]          ; читаємо 4 байти з джерела
		mov [esi], eax          ; записуємо у призначення
		add edi, 4              ; пересуваємо вказівник джерела
		add esi, 4              ; пересуваємо вказівник призначення
		inc ecx
		cmp ecx, edx
	jne @cycle
	
	pop ebp						; відновлення стеку
	ret 12						; вихід з поверненням 3 байтів стеку
Copy_LONGOP endp

end