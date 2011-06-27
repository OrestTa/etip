section .text
global dgbmv

%define TRANS [EBP+8]
%define M [EBP+12]
%define N [EBP+16]
%define KL [EBP+20]
%define KU [EBP+24]
%define _ALPHA [EBP+28]                 ; _X means X* (a pointer to X)
%define _A [EBP+32]                     ; *
%define LDA [EBP+36]
%define _X [EBP+40]                     ; *
%define INCX [EBP+44]
%define _BETA [EBP+48]                  ; *
%define _Y [EBP+52]                     ; *
%define INCY [EBP+56]

; Multiply a scalar with an incremented vector
; Initalisation:
;               MOV ECX, 0      : counter
;               MOV EDX, _Y     : incremented vector*
;               MOV EAX, _BETA  : scalar*
;               MOV EBX, INCY   : increment of the vector
;               MOV ESI, N      : length of the vector
;               CALL scalarmult

%macro scalarmult 1
%1:
                FLD qword [EAX]         ; first factor
                FLD qword [EDX]         ; second factor
                FMUL                    ; multiply!
                FSTP qword [EDX]        ; save the result

                ADD EDX, EBX            ; increase the pointer by 8*INC in order to
                ADD EDX, EBX            ; make it point to the next element of the array
                ADD EDX, EBX
                ADD EDX, EBX
                ADD EDX, EBX
                ADD EDX, EBX
                ADD EDX, EBX
                ADD EDX, EBX

                INC ECX                 ; increase the counter
                CMP ECX, ESI            ; check whether all elements have been processed
                JNE %1                  ; if not, repeat
%endmacro

; DGBMV - PROLOGUE
dgbmv:
                PUSH EBP
                MOV EBP, ESP

; Check which operation to execute
transcheck:
                MOV EAX, TRANS          ; Check paramter TRANS
                CMP AL, 'N'             ; jump to notranspose if it is N or n
                JE notranspose
                CMP AL, 'n'
                JE notranspose
                CMP AL, 'T'             ; jump to transpose if it is T, t, C or c
                JE transpose
                CMP AL, 't'
                JE transpose
                CMP AL, 'C'
                JE transpose
                CMP AL, 'c'
                JE transpose
                JMP transerror          ; jump to transerror otherwise

; Transpose the matrix
transpose:
                mov eax, 10             ; EAX = 10 (just for testing)
                JMP finish              ; TODO! 

; Proceed without transposing the matrix
notranspose:
                MOV EAX, LDA            ; LDA has to fit in 16 bits!
                MUL word N              ; N has to fit in 16 bits!; TODO: error
                ADD EAX, EAX            ; duplicate EAX (each double needs 8 bytes instead of 4)
                PUSH EAX

; Allocate memory
alloc:
                PUSH dword 0x0          ; populate the stack with 0s to allow for dynamic management
                DEC EAX                 ; do it EAX times, i. e. LDA * N * 2
                JNZ alloc               ; repeat until EAX=0
                MOV EAX, [EBP-4]        ; restore LDA * N * 2

; Duplicate the matrix
                MOV EDX, EBP            ; copy the base pointer
                SUB EDX, EAX            ; calculate the position of the duplicated matrix (EDX)
                SUB EDX, 4              ; populate the stack with duplicated matrix' elements
                MOV EBX, _A             ; EBX contains the pointer to the original matrix
                PUSH dword 0x0
copy_loop:
                MOV ECX, [EBX]
                MOV [EBP-8], ECX
                ADD EBX, 4
                ADD EDX, 4
                DEC EAX
                JNE copy_loop
; Beta*Y
BETA_Y:
                MOV ECX, 0
                MOV EDX, _Y
                MOV EAX, _BETA
                MOV EBX, INCY
                MOV ESI, N
                scalarmult scalarmult_b
; Alpha*A
ALPHA_A:
                MOV ECX, 0
                ;MOV EDX, [ESP]
                MOV EDX, _A
                MOV EAX, _ALPHA
                MOV EBX, 1
                MOV ESI, [EBP-4]
                SHR ESI, 1
                scalarmult scalarmult_a

bsmvectmult:

vectoradd:

; The function succeded 
okay:
                MOV EAX, 0              ; set return to 0
                JMP finish

; Errors
transerror:                             ; TRANS is none of N, n, T, t, C, c
                MOV EAX, -1             ; set return to -1
                JMP finish

; EPILOGUE
finish:
                POP EBX                 ; pop from the stack
                CMP EBP, ESP            ; until it's empty
                JNE finish
                POP EBP
                RET
