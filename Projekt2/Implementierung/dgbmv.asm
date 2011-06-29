extern  printf                          ; the C function to be called

section .data                           ; data section

; the printf format for flt64, "\n",'0'
fmt_flt:     db "first float64 on stack = %E", 10, 10, 0

; the printf format for int32, "\n",'0'
fmt_int:    db "first int = %d, second int = %d, third int = %d", 10, 10, 0

; data:
;a:  dd  5                               ; int a = 5;
flt2:   dq  -123.456789e300         ; 64-bit floating point

; in order to print, push
;                MOV EAX, [a]    ; load
;                ADD EAX, 2      ; a+2
;                PUSH EAX        ; stack3
;                PUSH dword [a]  ; value of variable a ; stack2
;                ADD EAX, 3
;                PUSH EAX        ; stack1
;                PUSH dword fmt  ; address of ctrl string ; stack0
;                CALL printf
;                POP EAX            
;                POP EAX
;                POP EAX
;                POP EAX
; http://www.cs.umbc.edu/portal/help/nasm/sample.shtml


section .text                           ; code

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
;               MOV ECX, 0              : counter
;               MOV EDX, _Y             : incremented vector*
;               MOV EAX, _BETA          : scalar*
;               MOV EBX, INCY           : increment of the vector
;               MOV ESI, N              : length of the vector
;               scalarmult foo
%macro scalarmult 1
%1:
                FLD qword [EAX]         ; first factor
                FLD qword [EDX]         ; second factor
                FMUL                    ; multiply
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
; TODO! todo todo

; Check which operation to execute
transcheck:
                MOV EAX, TRANS          ; check TRANS and
                CMP AL, 'N'             ; do not transpose if it is N or n
                JE proceed0
                CMP AL, 'n'
                JE proceed0
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

; Proceed
proceed0:
                MOV EAX, LDA            ; LDA has to fit in 16 bits!
                MUL word N              ; N has to fit in 16 bits!; TODO: error
                PUSH EAX                ; the length of A can now be found in [EBP-4]
                MOV EBX, 0              ; reserve memory for A's duplicate's pointer
                PUSH EBX                ; on the stack in [EBP-8]

; Calculate the pointer to the last element of A
                MOV EBX, _A             ; EBX now contains the pointer to the original matrix, 1. element
                DEC EAX                 ; adjust the counter
                JZ pointerlastready     ; if zero, finished
pointerlast:
                ADD EBX, 8              ; move the pointer to the following element
                DEC EAX                 ; decrementing the counter
                JNZ pointerlast         ; until it reaches zero (all elements have been skipped)
                MOV EAX, [EBP-4]        ; restore EAX
pointerlastready:                       ; EBX contains the pointer to the last element of A

; Duplicate the matrix A
matrixduplicate:
                PUSH dword [EBX+4]      ; push beginning with the last element of A
                PUSH dword [EBX]        ; 8 bytes (one double element)
                SUB EBX, 8              ; decrement EBX by 8 bytes to make it point to the previous element
                DEC EAX                 ; decrease the counter
                JNZ matrixduplicate     ; repeat until the counter reaches 0
                MOV [EBP-8], ESP        ; A's duplicate's pointer can now be found in [EBP-8]

; [ALPHA * A or ALPHA * A'] = AA
aa:
                MOV ECX, 0              ; counter = 0
                MOV EDX, [EBP-8]        ; EDX now points to A's duplicate
;                MOV EDX, [EBP+32]       ; EDX now points to the original A - for testing only
                MOV EAX, _ALPHA         ; EAX now points to ALPHA
                MOV EBX, 1              ; the increment of A is always 1 (a regular array)
                MOV ESI, [EBP-4]        ; A's length had been pushed from EAX in proceed0
                scalarmult scalarmult_a ; execute scalarmult
;                JMP aa_test             ; diagnose whether A*A is correct

; BETA * Y = YB, saved in Y
yb:
                MOV ECX, 0              ; counter = 0
                MOV EDX, _Y             ; EDX now points to Y
                MOV EAX, _BETA          ; EAX now points to BETA
                MOV EBX, INCY           ; EBX now is Y's increment
                MOV ESI, N              ; ESI now is Y's length
                scalarmult scalarmult_b ; execute scalarmult
;                JMP okay                ; diagnose whether Y*B is correct

; AA * X = AAX
; in Python:
; for i in xrange(1,N+1):
;     for k in xrange(0,N):
;         if (KU+i-k-1) >= 0:
;             if (KU+i-k-1) <= (LDA-1):
;                 AAXYB[i-1] = AAXYB[i-1] + (X[k+1-1] * A[KU+i-k-1][k+1-1])
; Check if
; KU+i-k-1 < 0
; or
; KU+i-k-1 > LDA-1
; if so, skip
; todo! increment for x!!!!
aax:
                MOV EAX, 0              ; memory alloc counter
                MOV EBX, 0
aax_memory:
                PUSH EBX                ; populate the stack
                PUSH EBX
                INC EAX
                CMP EAX, N              ; with N*2 dwords = N qwords
                JNE aax_memory
aax_body:
                MOV EBX, 1              ; i
for_i:                                  ; calculate AAXYB(i-1)
                MOV ECX, 0              ; k
for_k:                                  ; calculate AAXYB[i-1] + (X[k+1-1] * A[KU+i-k-1][k+1-1])
                MOV EAX, KU             ; KU
                ADD EAX, EBX            ; KU+i
                SUB EAX, ECX            ; KU+i-k
                DEC EAX                 ; KU+i-k-1 : EAX now contains the desired row of AA
                CMP EAX, 0              ; KU+i-k-1 < 0?
                JL skiptonextk          ; skip to a next k
                MOV EDX, LDA            ; LDA
                DEC EDX                 ; LDA-1
                CMP EAX, EDX            ; KU+i-k-1 > LDA-1?
                JG skiptonextk          ; skip to a next k
                DEC EAX                 ; because index(el)=(EAX-1)*N+ECX
                MUL word N              ; v. s.; todo error if too big
                ADD EAX, ECX            ; EAX now contains the index of AA's desired element, =:EAX_old

                MOV EDX, [EBP-8]        ; EDX now contains the pointer to AA
                ADD EDX, EAX            ; each element is a double, so it requires 8 bytes
                ADD EDX, EAX
                ADD EDX, EAX
                ADD EDX, EAX
                ADD EDX, EAX
                ADD EDX, EAX
                ADD EDX, EAX
                ADD EDX, EAX            ; EDX now contains the pointer to the EAX-th element of AA
                MOV EAX, EDX            ; EAX=EDX

                MOV EDX, _X             ; EDX now contains the pointer to X
                ADD EDX, ECX            ; each element is a double, so it requires 8 bytes
                ADD EDX, ECX
                ADD EDX, ECX
                ADD EDX, ECX
                ADD EDX, ECX
                ADD EDX, ECX
                ADD EDX, ECX
                ADD EDX, ECX            ; EDX now contains the pointer to the k-th element of X

                FLD qword [EAX]         ; load the EAX_old-th element of AA: AA(EAX_old)
                FLD qword [EDX]         ; load the k-th element of X: X(k)
                FMUL                    ; multiply
                FSTP qword [EAX]        ; the element that EAX points to now equals X(k)*AA(EAX_old)

                MOV EDX, EBX            ; EDX=i
                DEC EDX                 ; EDX=i-1
                FLD qword [EAX]         ; load X(k)*AA(EAX_old)
                FLD qword [ESP+EDX]     ; load AAX(EDX)
                FADD                    ; add
                FSTP qword [ESP+EDX]    ; AAX will be saved on the stack, with its first element on top

                ; looping k
skiptonextk:
                INC ECX                 ; increment k
                MOV EDX, N              ; N
                CMP ECX, EDX            ; check whether k=N
                JNZ for_k               ; if not, repeat
k_finished:
                ; looping i

;                mov edx, esp    ;mov                                     ;;;;;;;;;;;;;;;;;;;;;;;;;
;                push dword [flt2+4]
;                push dword [flt2]
                push dword fmt_flt
                call printf
                pop edx
                pop edx
                pop edx

                INC EBX                 ; increment i
                MOV EDX, N              ; N
                INC EDX                 ; N+1
                CMP EBX, EDX            ; check whether i=N+1
                JNZ for_i               ; if not, repeat
;                JMP aax_test            ; diagnose whether AAX is correct

; AAX + YB = AAXYB, saved in Y; aaxyb(i*INCY) = (aax(i) + yb(i*INCY)) for each i=0..N-1
; Warning: Y is and remains an incremented array!
aaxyb:
                MOV EBX, 0              ; counter i=0
                MOV ECX, N              ; N
                DEC ECX                 ; N-1
                MOV EAX, _Y             ; EAX now points to B*Y(0)
aaxyb_body:                             ; sum and then calculate the new pointer to B*Y(i*INCY)
                FLD qword [EAX]         ; load B*Y(i*INCY)
                FLD qword [ESP+EBX]     ; load AAX(i)
                FADD                    ; add
                FSTP qword [EAX]        ; write B*Y(i*INCY)=B*Y(i*INCY)+AAX(i)

                ADD EAX, INCY           ; each double is 8 bytes long
                ADD EAX, INCY           ; now increment the pointer by 8*INCY
                ADD EAX, INCY           ; in order to make it point to the
                ADD EAX, INCY           ; next element of B*Y
                ADD EAX, INCY           ; i. e. to B*Y(i*INCY)
                ADD EAX, INCY           ;
                ADD EAX, INCY           ;
                ADD EAX, INCY           ;

                ; looping i
                INC EBX                 ; i=i+1
                CMP EBX, ECX            ; is i=N-1?
                JNE aaxyb_body          ; if not, repeat

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


; Testing

aa_test:
                MOV ESI, 0              ; counter/index
;                PUSH dword [EBP-4]            ; length
;                PUSH dword fmt_int
;                CALL printf
;                POP EBX
;                POP EBX
;                JMP okay               ; finish
aa_test_print:
                MOV EBX, [EBP-8]        ; AA's pointer
                ADD EBX, ESI            ; increase by 8*index
                ADD EBX, ESI
                ADD EBX, ESI
                ADD EBX, ESI
                ADD EBX, ESI
                ADD EBX, ESI
                ADD EBX, ESI
                ADD EBX, ESI

                MOV ECX, [EBX+4]
                MOV EDX, [EBX]
                PUSH ECX
                PUSH EDX
                PUSH dword [EBX+4]
                PUSH dword [EBX]
                PUSH dword fmt_flt
                CALL printf
                POP EBX
                POP EBX
                POP EBX

                ; looping
                INC ESI
                CMP ESI, [EBP-4]        ; AA's length
                JNE aa_test_print       ; repeat until equal

;                MOV EAX, _Y             ; EAX now contains the pointer to Y(0)
;                MOV dword [EAX], 0      ; set Y(0)=0
;                MOV dword [EAX+4], 0    ; v. s.
;                MOV EDX, [EBP-8]        ; load AA's pointer
;                ADD EDX, 24             ; jump to AA(3)
;                FLD qword [EDX]         ; load
;                FSTP qword [EAX]        ; write [EDX] to Y(0)
                JMP okay

aax_test:
                MOV EAX, _Y             ; EAX now contains the pointer to Y(0)
                MOV dword [EAX], 0      ; set Y(0)=0
                MOV dword [EAX+4], 0    ; v. s.
                MOV EDX, ESP            ; load AAX's pointer
;                ADD EDX, 0           ; jump to AA's second-to-last element
                FLD qword [EDX]         ; load
                FSTP qword [EAX]        ; write [EDX] to Y(0)
                JMP okay

