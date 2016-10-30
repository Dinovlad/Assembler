format PE console

include 'INCLUDE\WIN32AX.INC'

entry start

section '.idata' import data readable
library msvcrt,'msvcrt.dll', kernel32,'kernel32.dll'

import msvcrt, printf, 'printf', exit,'exit', getchar, 'getchar'

import kernel32, ExitProcess,'ExitProcess'

section '.data' data readable writable

	s db 'Hello, world!', 0
	
	return rd 1

section '.code' code readable executable

pr: ; procedure printing the eax addressed string

        push edx
	push ecx
	push eax

	call [printf]

	pop eax
	pop ecx
	pop edx
	
	jmp [return]	

start:

	push s
	call [printf]
	add esp, 4

	mov eax, s
	mov [return], R
	jmp pr
	R:

	push 0
	call [ExitProcess]