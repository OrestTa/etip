section .text
global dgbmv

%define TRANS [EBP+8]
%define M [EBP+12]
%define N [EBP+16]
%define KL [EBP+20]
%define KU [EBP+24]
%define _ALPHA [EBP+28]                 ; _X is X* (a pointer to X)
%define _A [EBP+32]
%define LDA [EBP+36]
%define _X [EBP+40]
%define INCX [EBP+44]
%define _BETA [EBP+48]
%define _Y [EBP+52]
%define INCY [EBP+56]

; Multiply a scalar with a vector
; you have to initalize like this:
;               MOV ECX, 0      = counter
;               MOV EDX, _Y     = vector*
;               MOV EAX, _BETA  = scalar*
;               MOV EBX, INCY   = inc
;               CALL scalarmult
scalarmult:
                FLD qword [EAX]
                FLD qword [EDX+ECX*8]
                FMUL
                FSTP qword [EDX+ECX*8]

                ADD EDX, EBX
                ADD EDX, EBX
                ADD EDX, EBX
                ADD EDX, EBX
                ADD EDX, EBX
                ADD EDX, EBX
                ADD EDX, EBX
                ADD EDX, EBX

                INC ECX
                CMP ECX, N
                JNE scalarmult
                
                RET

; The dgbmv function
dgbmv:
                push ebp                ; Prolog
                mov ebp, esp
; Check which operation we have to do
transcheck:
                MOV EAX, [EBP+8]        ; Check first Paramter TRANS
                AND EAX, 0x000000ff     ; jump to notranspose, if it is N or n
                CMP AL, 'N'             ; jump to transpose, if it is T,t,C or c
                JE notranspose          ; jump to transerror, if it is neither
                CMP AL, 'n'
                JE notranspose
                CMP AL, 'T'
                JE transpose
                CMP AL, 't'
                JE transpose
                CMP AL, 'C'
                JE transpose
                CMP AL, 'c'
                JE transpose
                JMP transerror

; Transpose the matrix
transpose:
                mov eax, 10             ; EAX = 10 (just for testing)
                ;JMP finish 
notranspose:
                mov eax, 20             ; EAX = 20 (just for testing)
                ;JMP finish
; Beta*Y
                MOV ECX, 0
                MOV EDX, _Y
                MOV EAX, _BETA
                MOV EBX, INCY
                CALL scalarmult
bsmvectmult:

vectoradd:

finish:
                ;MOV EAX, [EBP+52]       ; ALPHA pointer - some testing for now...
                ;FLD qword [EAX]         ; push ALPHA to the FPU
                ;FLD qword [EAX+4]       ; push ALPHA to the FPU again
                ;FADD                    ; add upper 2 doubles on the FPU stack
                ;FSTP qword [EAX]        ; store top double on the FPU stack
                ;MOV EAX, 0x0            ; return 0 - everything OK!
                ;MOV EAX, _Y
                ;MOV dword [EAX+4], 0x40000000
                MOV EAX, 0x0
                pop ebp                 ; Epilog
                ret
; Error cases
transerror:                             ; TRANS is neither N,n,T,t,C nor c
                mov eax, -1
                pop ebp
                ret
