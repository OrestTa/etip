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
;               scalarmult foo

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

; Check whether all parameters are legal
; TODO!

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
                PUSH EAX

; Calculate the pointer to the last element of A
                MOV EBX, _A             ; EBX now contains the pointer to the original matrix, 1. element
                DEC EAX                 ; adjust the counter
                JZ pointerlastready     ; if zero, finished
pointerlast:
                ADD EBX, 8              ; move the pointer to the following element
                DEC EAX                 ; decreasing the counter
                JNZ pointerlast         ; until it reaches zero (all elements have been skipped)
                MOV EAX, [EBP-4]        ; restore EAX
pointerlastready:

; Duplicate the matrix A
matrixduplicate:
                PUSH dword [EBX+4]      ; push beginning with the last element of A
                PUSH dword [EBX]        ; 8 bytes (one double element)
                SUB EBX, 8              ; decrement EBX by 8 bytes to make it point to the previous element
                DEC EAX                 ; decrease the counter
                JNZ matrixduplicate     ; repeat until the counter reaches 0

; [ALPHA * A or ALPHA * A'] = AA
aa:
                MOV ECX, 0              ; counter = 0
                MOV EDX, ESP            ; EDX now points to A's duplicate
;                MOV EDX, [EBP+32]       ; EDX now points to the original A
                MOV EAX, _ALPHA         ; EAX now points to ALPHA
                MOV EBX, 1              ; the increment of A is always 1 (a regular array)
                MOV ESI, [EBP-4]        ; A's length had been pushed from EAX at the beginning
                scalarmult scalarmult_a ; execute scalarmult

; BETA * Y = YB, saved in Y
yb:
                MOV ECX, 0              ; counter = 0
                MOV EDX, _Y             ; EDX now points to Y
                MOV EAX, _BETA          ; EAX now points to BETA
                MOV EBX, INCY           ; EBX now is Y's increment
                MOV ESI, N              ; ESI now is Y's length
                scalarmult scalarmult_b ; execute scalarmult

; AA * X = AAX
aax:

; AAX + YB = AAXYB, saved in Y
aaxyb:

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
