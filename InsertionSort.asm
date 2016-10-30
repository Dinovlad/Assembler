format PE console

include 'INCLUDE\WIN32AX.INC'

entry start

section '.idata' import data readable
library msvcrt,'msvcrt.dll', kernel32,'kernel32.dll'

import msvcrt, printf, 'printf', exit,'exit', getchar, 'getchar'

import kernel32, ExitProcess,'ExitProcess', GetTickCount, 'GetTickCount'

section '.data' data readable writable

	s db 'Hello, world!', 10, 0 ; 10 == '\n' символ новой строки
	erMes db 'Something', 10, 0

	ar dd 7, 52, 52, 625, 723, 72, 243, 12, 234, 3, 72, 24, 12, 234

	buf rd 1

	mes db '%i ', 0
	intMes db '%i', 10, 0
	nLine db 10, 0

section '.code' code readable executable

intCompare: ; effects the same as cmp

	push eax

	mov eax, [esp + 8]
	cmp eax, [esp + 12]
	
        pop eax

	ret

printArray: ; arguments: *array, length

	
	pusha	

	mov esi, [esp + 36]
	mov edi, [esp + 40]

	shl edi, 2 ; edi = edi * 4
	add edi, esi ; edi += esi

	add esp, -4 ; leave space for an argument
	push mes

	printEl:

	cmp esi, edi
	je Q

	mov eax, [esi]
	mov [esp + 4], eax
	call [printf] 

	add esi, 4

	jmp printEl

	Q:

	add esp, 8

	push nLine
	call [printf]
	add esp, 4

	popa

	ret

pr: ; effects the same as printf preserving the registers' data

	push edx
	push ecx
	push eax
        
	push erMes 
	call [printf]
	add esp, 4

	pop eax
	pop ecx
	pop edx	
	
	ret 4	

sort:   ; first argument must point at the array, the second one contain the length,
 	; the third one point at the comparing procedure

	pusha

	mov esi, [esp + 36] ; esi addresses the array
	mov ebp, [esp + 40] ; ebp contains the length of the array
	mov edi, [esp + 44] ; edi addresses the comparator		

	cmp ebp, 2
	jl E ; if the length is less than 2 then return

	shl ebp, 2

	mov ecx, 4

	; while ecx != ebp repeat

	nextElement:

	; binarily search for the place of insertion

	xor eax, eax ; the element is to be inserted after eax and before ebx elements
	xor ebx, ebx ; so soon as eax + 4 == ebx the search is finished

	push dword [esi + ecx]
	push dword [esi]
	call edi
	jg insertion

	mov ebx, ecx	

	mov edx, ebx ; edx = eax + ebx, as eax == 0

	search:
	
	shr edx, 3
	shl edx, 2 ; edx = (eax + ebx) / 2

	cmp eax, edx
	je insertion

	; compare

	add esp, 4
	push dword [esi + edx]
	call edi	
	jg right

	mov eax, edx
	add edx, ebx
	jmp search

	right:

	mov ebx, edx
	add edx, eax
	jmp search

	insertion: ; insert the element immediately before ebx element

	mov edx, ecx
	add edx, esi

	add ebx, esi

	shift:
	
	cmp ebx, edx
	je insert

	mov eax, [edx - 4] 
	mov [edx], eax

	add edx, -4

	jmp shift

	insert:		

	add esp, 4
	pop dword [ebx]

	add ecx, 4
	
	cmp ecx, ebp
	jne nextElement

	E: ; end of the sort	

	popa

	ret

start:

	push 14
	push ar
	call printArray
	add esp, 8

        push intCompare
	push 14
	push ar
	call sort
	add esp, 12

	push 14
	push ar
	call printArray
	add esp, 8

	push 0
	call [ExitProcess]