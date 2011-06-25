section .text
global dgbmv
global test

; The dgbmv function
dgbmv:
                push ebp
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
                pop ebp
                ret
; Error cases
transerror:                             ; TRANS is neither N,n,T,t,C nor c
                mov eax, -1
                pop ebp
                ret
