; 2 processes access parallelly one integer and
; increase it using "inc" a billion times

; the result is strictly 2000000000 and no information is being lost
; because the "inc" is an atomic operation

; the similar code in C (using "i++") effects a number between 10^9 and 2*10^9
; because "++" is not atomic

; compile this file with fasm
; compile the resulting ".o" file with gcc to get the executable file

format ELF

section '.data' writable

	s db 'Hello, world!', 0
	
	form db '%s', 10, 0

	path db 'dev.asm', 0

	mesInt db '%d', 10, 0

	key rd 1
	shmid rd 1
	i rd 1
	
	pid rd 1	

section '.code' executable

public main

extrn ftok	
extrn printf
extrn exit
extrn shmget
extrn shmat
extrn getpid
extrn 'wait' as waitForChild

main:

	push 0
	push path
	call ftok

	mov [key], eax
	
	mov eax, 666o
	or eax, 512 ; 512 == IPC_CREAT
	push eax
	push 4
	push [key]
	call shmget

	mov [shmid], eax

	push 0
	push 0
	push eax
	call shmat

	mov dword [eax], 0
	mov [i], eax

	mov eax, 2
	int 0x80 ; fork

	mov [pid], eax ; eax == 0 for the child

	mov eax, [i] ; shared variable address

	mov ecx, 1000000000
	L:

	inc dword [eax]

	loop L

	cmp [pid], 0
	jne output

	mov eax, 1
	int 0x80 ; the child must terminate

	output:

	push 0
	call waitForChild
	add esp, 4

	mov eax, [i]
	push dword [eax]
	push mesInt
	call printf
	add esp, 8
	
	xor eax, eax
	inc eax ; eax = 1
	int 0x80 ; system call exit
