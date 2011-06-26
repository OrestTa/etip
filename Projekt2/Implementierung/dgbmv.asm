section .text
global dgbmv

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
                JMP finish 
notranspose:
                mov eax, 20             ; EAX = 20 (just for testing)
                JMP finish
scalarmult:

bsmvectmult:

vectoradd:

finish:
                MOV EAX, [EBP+28]       ; ALPHA pointer - some testing for now...
                FLD qword [EAX]         ; push ALPHA to the FPU
                FLD qword [EAX]         ; push ALPHA to the FPU again
                FADD                    ; add upper 2 doubles on the FPU stack
                FSTP qword [EAX]        ; store top double on the FPU stack
                MOV EAX, 0x0            ; return 0 - everything OK!
                pop ebp                 ; Epilog
                ret
; Error cases
transerror:                             ; TRANS is neither N,n,T,t,C nor c
                mov eax, -1
                pop ebp
                ret
