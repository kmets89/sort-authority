; Kaylan Mettus
; CS 218.1002
; Assignment #7

; Sort a list of number using the insertion sort algorithm.
; Also finds the minimum, median, maximum, and average of the list.

; -----
; Insertion Sort

;	insertionSort(array Arr) {
;		for i = 1 to length-1 do {
;			value := Arr[i];
;			j = i - 1;
;			while ( (j ≥ 0) and (Arr[j] > value) ) {
;				Arr[j+1] = Arr[j];
;				j = j - 1;
;			};
;			Arr[j+1] = value;
;		};
;	};

; --------------------------------------------------------------
;  Macro to convert integer to vigesimal value in ASCII format.


%macro	int2vigesimal	3
	push	rcx
	push	rdx
	push	rsi ; int
	push	rdi ; str address
	push	r8
	push	r9
	push 	r10
	push	rax

	movsxd rsi, dword [%1] ; integer
	lea	rdi, [%2] ; str address
	mov ecx, %3 ; STR_LENGTH
	mov r9, 0 ; sign = 0
	
	cmp rsi, 0 ; compare int to 0 to find neg or pos
	jl %%negative
	jmp %%signDone
	%%negative:
		neg rsi ; negate int
		mov r9, 1 ; sign = 1
	%%signDone:

	mov r8, 20 ; Will be diving by 20
	mov rax, rsi
	
	%%divLp:
		cqo ; move prev division into eax:rax
		idiv r8
		push rdx ; push remainder
		dec ecx
		cmp ecx, 2 ; loop 8 times
		jne %%divLp
		
	mov ecx, %3
	mov r8, 0 ; index starts at 0
	cmp r9, 0 ; find if pos or neg num
	jne %%negChar
	mov byte [rdi + r8], "+"
	jmp %%signCharDone
	%%negChar:
		mov byte [rdi + r8], "-"
	%%signCharDone:
	inc r8 ; index++

	%%stringLp:
		pop r10 ; pop digit and convert to vig
		mov byte [char], r10b 
		cmp r10b, 10
		jge %%alpha1
		add byte [char], "0"
		jmp %%convertDone
		%%alpha1:
			cmp r10b, 18
			jge %%alpha2
			add byte [char], "A" 
			sub byte [char], 10
			jmp %%convertDone
		%%alpha2:
			add byte [char], "A" 
			sub byte [char], 9	
		%%convertDone:
		
		mov r10b, byte [char] ; move vig digit into string
		mov byte [rdi + r8], r10b
		inc r8 ; index++
		dec ecx
		cmp ecx, 2
		jne %%stringLp
		
		inc r8 ; index++
		mov byte [rdi + r8], NULL ; add NULL termination

	pop rax
	pop r10
	pop r9
	pop	r8
	pop	rdi
	pop	rsi
	pop	rdx
	pop	rcx
%endmacro


; --------------------------------------------------------------
;  Simple macro to display a string to the console.
;	Call:	printString  <stringAddr>

;	Arguments:
;		%1 -> <stringAddr>, string address

;  Count characters (excluding NULL).
;  Display string starting at address <stringAddr>

%macro	printString	1
	push	rax			; save altered registers
	push	rdi
	push	rsi
	push	rdx
	push	rcx

	mov	rdx, 0
	mov	rdi, %1
%%countLoop:
	cmp	byte [rdi], NULL
	je	%%countLoopDone
	inc	rdi
	inc	rdx
	jmp	%%countLoop
%%countLoopDone:

	mov	rax, SYS_write		; system call for write (SYS_write)
	mov	rdi, STDOUT		; standard output
	mov	rsi, %1			; address of the string
	syscall				; call the kernel

	pop	rcx			; restore registers to original values
	pop	rdx
	pop	rsi
	pop	rdi
	pop	rax
%endmacro

; ---------------------------------------------

section	.data

; -----
;  Define constants.

TRUE		equ	1
FALSE		equ	0

EXIT_SUCCESS	equ	0			; Successful operation

STDIN		equ	0			; standard input
STDOUT		equ	1			; standard output
STDERR		equ	2			; standard error

SYS_read	equ	0			; system call code for read
SYS_write	equ	1			; system call code for write
SYS_open	equ	2			; system call code for file open
SYS_close	equ	3			; system call code for file close
SYS_fork	equ	57			; system call code for fork
SYS_exit	equ	60			; system call code for terminate
SYS_creat	equ	85			; system call code for file open/create
SYS_time	equ	201			; system call code for get time

LF		equ	10
NULL		equ	0
ESC		equ	27

LIMIT		equ	10000
STR_LENGTH	equ	12

; -----
;  Provided data

lst	dd	 -147,  1123,  2245,  4440,  -165
	dd	    1,    54,    28,    13,  -222
	dd	   69,  -126,  -571,  -147,  -228
	dd	   27,     0,  -177,   -75,    14
	dd	 -181,    25,    15,    22, -1217
	dd	    1,    10,  -129,  -212,  -134
	dd	  127,    64,  -140,   172,    24
	dd	  125,    16,    62,     8,    92
	dd	-2161,  -134,   151,    32,    12
	dd	   29,   114,    22,  -113,  1131
	dd	 1113, -1232,  2146,  3376,  5120
	dd	 2356,  3164, 34565,  3155, 23157
	dd	-1001,   128,    33,   105,  8327
	dd	  101,   115,   108, 12233, -2115
	dd	 1227,  1226,  5129,   117,   107
	dd	  105,   109,   730,  -150,  3414
	dd	 1107,  6103,  1245,  6440,   465
	dd	 2311,   254,  4528,   913,  6722
	dd	-1149,  2126,  5671,  4647,  4628
	dd	 -327, -2390,   177,  8275,  5614
	dd	 3121,   415,  -615,    22,  7217
	dd	  -11,    10,   129,  -812,  2134
	dd	-1221,   -34,  6151,   432,   114
	dd	  629,   114,   522,  2413,   131
	dd	 5639,   126,    62,    41,   127
	dd	 -877,   199,  5679,   101,  3414
	dd	  117,    54,    40,  -172,  4524
	dd	  125,    16,  9762,     0, 11292
	dd	-2101,   133,   133,    50,  4532
	dd	 8619,    15,  1618,   113,  -115
	dd	 1219,  3116,   -62,    17,   127
	dd	 6787,  4569,    79, 15675,    14
	dd	 1104,  6825,    84,    43,    76
	dd	  134, -4626,   100,  4566,  2346
	dd	   14,  6786,   617,   183, -3512
	dd	 7881, -8320,  3467,  4559, -1190
	dd	  103,   112,   146,   186,   191
	dd	  186,   134,  1125, -5675,  3476
	dd	 2137,  2113, -1647,   114,    15
	dd	-6571, -7624,   128,   113,  3112
	dd	  724,  6316,    17,   183, -4352
	dd	 1121,   320,  4540,  5679, -1190
	dd	 9125,   116,  -122,   117,   127
	dd	 5677,   101,  3727,   125,  3184
	dd	 1897,  6374,   190,     3,    24
	dd	  125,   116,  8126,  6784, 12329
	dd	 1104,   124,  -112,   143,   176
	dd	 7534,  2126,  6112,   156,  1103
	dd	 6759,  6326,  2171,  -147, -5628
	dd	 7527,  7569,  3177,  6785,  3514
	dd	  153,   172,  5146,   176,   170
	dd	 1156,   164,  4165,  -155,  5156
	dd	  894,  6325,  2184,    43,    76
	dd	 5634,  7526,  3413,  7686,  7563
	dd	 2147,   113,  -143,   140,   165
	dd	  191,   154,  2168,   143,   162
	dd	 -511,  6383,  -133,    50,  -825
	dd	 5721,  5615,  4568,  7813,  1231
	dd	  169,   146,  1162,   147,   157
	dd	  167,   169,  2177,   175,  2144
	dd	 5527,  6364,  -330,   172,    24
	dd	 7525,  5616,  5662,  6328,  2342
	dd	  181,   155,  2145,   132,   167
	dd	  185,   150,  5149,   182,   434
	dd	 6581,  3625,  6315,     9,  -617
	dd	 7855, 16737,  6129,  4512,   134
	dd	  177,   164,  3160,   172,   184
	dd	  175,   166,  6762,   158,  4572
	dd	 6561,    83,  1133,   150,   135
	dd	 5631, -8185,  2178,   197,   185
	dd	  147,   123,  3645,    40, -1766
	dd	-3451, -1954,  4628, -1613,  5432
	dd	 5649,  6366,  2162,   167,   167
	dd	  177,   169,  2177,  -175,   169
	dd	 1161,   122,  1151,    32, -8770
	dd	   29,  5464, -3242, -1213,   131
	dd	 5684,   179,  2117,   183,   190
	dd	  100, -4611,  3123,  3122,  -131
	dd	 1123,  1142,  3146,    76,  5460
	dd	  156, 18964,  3466,   155,  4357
len	dd	400

min	dd	0
med	dd	0
max	dd	0
sum	dd	0
avg	dd	0

; -----
;  Misc. data definitions (if any).

char db " "

; -----
;  Provided string definitions.

newLine		db	LF, NULL

hdr		db	LF, "---------------------------"
		db	"---------------------------"
		db	LF, ESC, "[1m", "CS 218 - Assignment #7", ESC, "[0m"
		db	LF, "Shell Sort", LF, LF, NULL

hdrMin		db	"Minimum:  ", NULL
hdrMax		db	"Maximum:  ", NULL
hdrMed		db	"Median:   ", NULL
hdrSum		db	"Sum:      ", NULL
hdrAve		db	"Average:  ", NULL

; ---------------------------------------------

section .bss

tmpString	resb	STR_LENGTH

; ---------------------------------------------

section	.text
global	_start
_start:

; ******************************

mov ecx, 1 ;i = 1
mov r10d, dword [len]
sub r10d, 1 ; i < len - 1

forLp:
	mov r8d, dword [lst + ecx * 4] ;value = Arr[i]
	mov esi, ecx
	sub esi, 1 ; j = i - 1
	whileLp:
		cmp esi, 0
		jl whileDone ; while j >= 0
		mov eax, dword [lst + esi * 4] ;arr[j]
		cmp eax, r8d
		jle whileDone ; while arr[j] > value
		mov dword [lst + esi * 4 + 4], eax ; arr[j + 1] = arr[j]
		sub esi, 1 ; j--
		jmp whileLp
	whileDone:
	mov dword [lst + esi * 4 + 4], r8d
	inc ecx
	cmp ecx, r10d
	jle forLp
	
mov eax, dword [lst]
mov dword [min], eax ; set min

mov esi, dword [len]
mov eax, dword [lst + esi * 4 - 4]
mov dword [max], eax ; set max

mov ecx, 0
;mov esi, dword [len]
mov eax, 0

sumLp:
	add eax, dword [lst + ecx * 4]
	inc ecx
	cmp ecx, dword [len]
	jl sumLp

mov dword [sum], eax ; set sum
cdq
idiv dword [len] ; sum / len
mov dword [avg], eax ; set avg

; median
mov eax, dword [len]
cdq
mov r10d, dword [len]
mov r9d, 2
div r9d
cmp edx, 0
jne oddLst
; if even find average between the midde two values
evenLst:
	mov r11d, dword [lst + eax * 4]
	add r11d, dword [lst + eax * 4 - 4]
	mov eax, r11d
	cdq
	idiv r9d
	mov dword [med], eax
	jmp medianDone
; if odd find the middle value
oddLst:
	mov r11d, dword [lst + eax * 4]
	mov dword [med], r11d
medianDone:
	
; ******************************
;  Display results to screen in vigesimal.

	printString	hdr

	printString	hdrMin
	int2vigesimal	min, tmpString, STR_LENGTH
	printString	tmpString
	printString	newLine

	printString	hdrMax
	int2vigesimal	max, tmpString, STR_LENGTH
	printString	tmpString
	printString	newLine

	printString	hdrMed
	int2vigesimal	med, tmpString, STR_LENGTH
	printString	tmpString
	printString	newLine

	printString	hdrSum
	int2vigesimal	sum, tmpString, STR_LENGTH
	printString	tmpString
	printString	newLine

	printString	hdrAve
	int2vigesimal	avg, tmpString, STR_LENGTH
	printString	tmpString
	printString	newLine
	printString	newLine

; ******************************
;  Done, terminate program.

last:
	mov	rax, SYS_exit
	mov	rbx, EXIT_SUCCESS
	syscall
