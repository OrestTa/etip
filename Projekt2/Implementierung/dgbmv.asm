;
; The following code calculates
; Y := ALPHA * A  * X + BETA * Y
; or alternatively
; Y := ALPHA * A' * X + BETA * Y
;
; TODO:
; OVERFLOW with IMUL!!!, check negative doubles as input; LDA, Y, X could all be bigger than necessary!

extern printf                           ; the C function to be called, for testing purposes only

section .data                           ; data, for testing purposes only

; printf formats for flt64, "\n",'0'
fmt_flt:     db "first float64 on stack = %E", 10, 10, 0
fmt_flt_aa:  db "%E", 10, 0
fmt_flt_xaa: db "X(k) = %E, AA(EAX_old) = %E", 10, 0
fmt_flt_xaa2: db "AA_new(EAX_old) = %E", 10, 0

; printf formats for int32, "\n",'0'
fmt_int:    db "first int = %d, second int = %d, third int = %d", 10, 10, 0
fmt_int_k:  db "k = %d, row no = %d", 10, 0
fmt_int_k_index:  db "k = %d, index = %d", 10, 0

; mixed formats
fmt_i:  db "i = %d, last float64 = %E", 10, 0

; in order to printf EAX, push like this:
;                PUSH EAX
;                PUSH dword fmtX
;                CALL printf
;                POP EAX
;                POP EAX
; Beware! EAX, EBX, ECX, EDX can be modified by printf!
; http://www.cs.umbc.edu/portal/help/nasm/sample.shtml

section .text                           ; code

global dgbmv

; Macros

; These are our parameters put on the stack by main.c
%define TRANS [EBP+8]
%define M [EBP+12]
%define N [EBP+16]
%define KL [EBP+20]
%define KU [EBP+24]
%define _ALPHA [EBP+28]                 ; _Z means Z* (a pointer to Z)
%define _A [EBP+32]
%define LDA [EBP+36]
%define _X [EBP+40]
%define INCX [EBP+44]
%define _BETA [EBP+48]
%define _Y [EBP+52]
%define INCY [EBP+56]

; Multiply a scalar with an incremented vector
; Initalisation:
;               MOV ECX, 0              : counter i=0
;               MOV EDX, _Z             : incremented vector*
;               MOV EAX, _GAMMA         : scalar*
;               MOV EBX, INCZ           : increment of the vector
;               MOV ESI, N              : length of the vector
;               scalarmult foo
%macro scalarmult 1
                IMUL EBX, 8             ; each double is 8 bytes long
%1:
                FLD qword [EAX]         ; first factor
                FLD qword [EDX]         ; second factor
                FMUL                    ; multiply
                FSTP qword [EDX]        ; save the result
                ADD EDX, EBX            ; increase the pointer by 8*INC in order to
                ; looping i             ; make it point to the next element of the array
                INC ECX                 ; increase the counter
                CMP ECX, ESI            ; check whether all elements have been processed
                JNE %1                  ; if not, repeat
%endmacro

; Store a negatively incremented vector as a positively incremented vector on the stack
; Z_new[i-1] =Z[|INCZ| * N - |INCZ| * (i)], N be the length of the incremented array
; Initialisation:
;                MOV EAX, INCZ           ; abs(increment of the vector), has to be positive!
;                MOV ECX, N              ; element count
;                MOV EDX, _Z             ; incremented vector*
;                neginc par1 par2
; You need to update Z* with ESP afterwards
%macro neginc 2
                MOV ESI, 0              ; k=0 (to N)
%1:
                MOV EBX, EAX            ; i=INCZ (down to 0)
%2:
                PUSH dword 0            ; push INCZ qwords
                PUSH dword 0            ; i. e. create INCZ's lacuna
                ; looping i
                DEC EBX
                CMP EBX, 1
                JNE %2

                PUSH dword [EDX+4]      ; push one qword
                PUSH dword [EDX]        ; which is Z's relevant element

                MOV EDI, EAX            ; k (in N)
                IMUL EDI, 8             ; calculate the byte offset for Z ; todo of
                ADD EDX, EDI            ; EDX now points to Z's next relevant element

                ; looping k
                INC ESI
                CMP ESI, N
                JNE %1
%endmacro

%macro saveregs 0
                PUSH EAX
                PUSH EBX
                PUSH ECX
                PUSH EDX
                PUSH ESI
                PUSH EDI
%endmacro
%macro unsaveregs 0
                POP EDI
                POP ESI
                POP EDX
                POP ECX
                POP EBX
                POP EAX
%endmacro

%macro multipl 2;;;;;;;;;;;;;;;;;;;;____??????
                PUSH EAX
                PUSH EDX
                MOV EAX, %1
                MUL %2
                JO oferror
                MOV %1, EAX
                POP EDX
                POP EAX
%endmacro

; Helper functions

; memcpy FROM, TO, LENGTH -- ESI, EDI, EBX
; FROM: pointer to starting qword                       ESI
; TO: pointer to destination qword                      EDI
; LENGTH: length in doubles (8 byte blocks / qwords)    EBX
;
; All registers remain unchanged after calling this subroutine!
memcpy:
                PUSH EDX                ; save EDX as we'll change it
                PUSH EAX                ; save EAX as we'll change it
                SHL EBX, 1              ; EBX*2 - double the length (EBX), so that we can calculate with 4 byte blocks
                MOV EDX, 0              ; init counter
cpy_loop:
                MOV EAX, [ESI+EDX*4]    ; copy 4 bytes from the starting cell to EAX
                MOV [EDI+EDX*4], EAX    ; copy 4 bytes from EAX to the destination cell
                INC EDX                 ; increment the counter
                CMP EDX, EBX            ; check if we've finished
                JNE cpy_loop            ; if not - repeat
                SHR EBX, 1              ; EBX/2 : restore the original length (EBX)
                POP EAX                 ; restore EAX
                POP EDX                 ; restore EDX
                RET

; ======================================

; DGBMV - PROLOGUE
dgbmv:
                PUSH EBP
                MOV EBP, ESP

; Save registers
                PUSH EAX
                PUSH ECX
                PUSH EDX
                PUSH ESI
                PUSH EDI
                PUSH EBX

; Try to check whether all parameters are legal
                CMP dword M, 0
                JL merror
                CMP dword N, 0
                JL nerror
                MOV EAX, dword N
                CMP EAX, dword M
                JNE mnerror             ; M != N
                CMP dword KL, 0
                JL klerror
                CMP dword KU, 0
                JL kuerror
                MOV EAX, KU             ; KU
                ADD EAX, KL             ; KU+KL
                INC EAX                 ; KU+KL+1
                CMP dword LDA, EAX
                JL ldaerror
                CMP dword INCX, 0
                JE incxerror
                CMP dword INCY, 0
                JE incyerror

; Allocate stack memory for a copy of A (transposed or normal)
; + 4 bytes for the matrix length
; + 4 bytes for 0x2A
matrix_move_prepare:
                MOV EAX, LDA            ; LDA is A's first dimension
                IMUL EAX, dword N       ; N is A's second dimension; calculate the needed length
                PUSH EAX                ; push the length of A to [EBP-28]
                PUSH dword 0x2A         ; magic happens here
alloc_loop:
                PUSH dword 0x0          ; push length-of-A qwords
                PUSH dword 0x0
                DEC EAX
                JNZ alloc_loop

                MOV EDX, _A             ; save the pointer to the original matrix A in EDX
                MOV _A, ESP             ; save the pointer to the new matrix A in _A

; Check which operation to execute
transcheck:
                MOV EAX, TRANS          ; check TRANS and
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

; Transpose the matrix - copy the original matrix A at [EDX] to its new location at _A, transposing on the fly
transpose:
; Initialize starting point, destination point and length
                ; START A
                MOV ESI, EDX
                MOV ECX, KU
                IMUL ECX, 8
                ADD ESI, ECX
                ; DESTINATION A_trans
                MOV EDI, _A
                MOV ECX, LDA
                DEC ECX
                IMUL ECX, N
                IMUL ECX, 8
                ADD EDI, ECX
                ; Length
                MOV EBX, N
                SUB EBX, KU
                ; Counter
                MOV ECX, KU
                INC ECX
; Start copying
ku_loop:
                ;memcpy ESI, EDI, EBX
                call memcpy

                CMP ECX, 1
                JE kl
                ; START := START+(N-1)*8
                MOV EAX, N
                DEC EAX
                IMUL EAX, 8
                ADD ESI, EAX
                ; DESTINATION := DESTINATION-N*8
                MOV EAX, N
                IMUL EAX, 8
                SUB EDI, EAX
                ; LENGTH := LENGTH+1
                INC EBX
                ; Decrement counter
                DEC ECX
                JNZ ku_loop
; Upper diagonals and main diagonal from A are now copied to A_trans
kl:
                ; Counter
                MOV ECX, KL
                CMP ECX, 0
                JE new_matrix_ready     ; nothing to do, as kl is 0
kl_loop:
                ; START := START+N*8
                MOV EAX, N
                IMUL EAX, 8
                ADD ESI, EAX
                ; DESTINATION := DESTINATION-(N-1)*8
                MOV EAX, N
                DEC EAX
                IMUL EAX, 8
                SUB EDI, EAX
                ; LENGTH := LENGTH-1
                DEC EBX
                ; Copy
                ;memcpy ESI, EDI, EBX
                call memcpy
                ; Decrement counter
                DEC ECX
                JNZ kl_loop

; Lower diagonals and main diagonal from A are now copied to A_trans
                JMP new_matrix_ready    ; continue after "notranspose"

; Do not transpose the matrix, just copy it over to its new location
notranspose:
                MOV ESI, EDX            ; initiate starting point = *A_original
                MOV EDI, _A             ; initiate destination point = *A_new
                MOV EBX, [EBP-28]       ; initiate length (in doubles) = LDA*N
                call memcpy             ; copy

new_matrix_ready:                       ; proceed

; [ALPHA * A or ALPHA * A'] = AA
aa:
                MOV ECX, 0              ; counter = 0
                MOV EDX, _A             ; EDX now points to A's duplicate
                MOV EAX, _ALPHA         ; EAX now points to ALPHA
                MOV EBX, 1              ; the increment of A is always 1 (a regular array)
                MOV ESI, [EBP-28]       ; A's length had been pushed from EAX in matrix_move_prepare
                scalarmult scalarmult_a ; execute scalarmult
;                JMP aa_test             ; diagnose whether A*A is correct

; BETA * Y = YB, saved in Y
yb:
                CMP dword INCY, 0
                JG yb_multiply          ; if INCY is positive, skip the following

                MOV EAX, INCY
                IMUL EAX, -1            ; INCY -> -INCY, INCY is positive now
                MOV INCY, EAX           ; update INCY with -INCY
                MOV ECX, N              ; initialise N
                MOV EDX, _Y             ; initialise Y*
                neginc niy0, niy1       ; push Y as a positively incremented array

                MOV ESI, ESP            ; initialise the starting memory qword
                MOV EDI, _Y             ; initialise the destination memory qword
                MOV EBX, N              ; initialise N
                IMUL EBX, INCY          ; N*INCY returns the count of qwords
                CALL memcpy             ; which will be copied back into Y
; todo - clean up the stack????

yb_multiply:
                MOV ECX, 0              ; counter = 0
                MOV EDX, _Y             ; EDX now points to Y
                MOV EAX, _BETA          ; EAX now points to BETA
                MOV EBX, INCY           ; EBX is Y's increment now
                MOV ESI, N              ; ESI is Y's length now
                scalarmult scalarmult_b ; execute scalarmult
;                JMP okay                ; diagnose whether Y*B is correct

prepare_x:
                CMP dword INCX, 0       ; if INCX is positive
                JG incx_pos             ; skip the following
; If INCX is negative, store X's relevant elements on the stack
                MOV EAX, INCX
                IMUL EAX, -1            ; INCX -> -INCX, INCX is positive now
                MOV INCX, EAX           ; update INCX
                MOV ECX, N
                MOV EDX, _X

                MOV ESI, 0              ; k=0 (to N)
x_1:
                PUSH dword [EDX+4]      ; push one qword
                PUSH dword [EDX]        ; which is X's relevant element

                MOV EDI, EAX            ; k (in N)
                IMUL EDI, 8             ; byte offset for X ; todo of
                ADD EDX, EDI            ; EDX now points to X's next relevant element

                ; looping k
                INC ESI
                CMP ESI, N
                JNE x_1

                MOV _X, ESP             ; update X*
                JMP aax                 ; proceed

incx_pos:                               ; INCX is positive
                MOV EAX, N              ; i=N
incx_alloc:
                PUSH dword 0x0          ; allocate one qword
                PUSH dword 0x0
                DEC EAX
                JNZ incx_alloc

                MOV ESI, _X             ; source cell
                MOV EDI, ESP            ; destination cell
                MOV EBX, 1              ; length to copy

                MOV ECX, INCX
                IMUL ECX, 8             ; byte offset
incx_pos_loop:
                CALL memcpy
                ADD ESI, ECX            ; offset the source
                ADD EDI, 8              ; point to the next qword
                INC EAX
                CMP EAX, N
                JNE incx_pos_loop       ; repeat N times for N elements

                MOV _X, ESP             ; update X*

; AA * X = AAX
; in Python:
; for i in xrange(1,N+1):
;     for k in xrange(0,N):
;         if (KU+i-k-1) >= 0:
;             if (KU+i-k-1) <= (LDA-1):
;                 AAX[i-1] = AAX[i-1] + (X[k+1-1] * AA[KU+i-k-1][k+1-1])
aax:
                MOV EAX, 0              ; memory alloc counter
                MOV EBX, 0              ; default value for AAX's elements
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
                DEC EAX                 ; KU+i-k-1 : EAX now contains the desired row of AA (beginning at 0)

                ;PUSH EAX                ; row
                ;PUSH ECX                ; k
                ;PUSH dword fmt_int_k
                ;CALL printf             ; print
                ;POP ECX
                ;POP ECX
                ;POP EAX

                ; Check if the element exists

                MOV EDX, LDA            ; LDA
                DEC EDX                 ; LDA-1
                CMP EAX, EDX            ; KU+i-k-1 > LDA-1?
                JG skiptonextk          ; skip to a next k
                CMP EAX, 0              ; KU+i-k-1 < 0?
                JL skiptonextk          ; skip to a next k
                IMUL EAX, dword N       ; because index(el)=EAX*N+ECX; todo error if OF
                ADD EAX, ECX            ; EAX now contains the index of AA's desired element, =:EAX_old

                ;PUSH EAX                ; index
                ;PUSH ECX                ; k
                ;PUSH dword fmt_int_k_index
                ;CALL printf             ; print
                ;POP ECX
                ;POP ECX
                ;POP EAX

                ; Calculate the pointer to A[KU+i-k-1][k+1-1] and X[k]

                IMUL EAX, 8             ; EAX now contains the byte offset for AA ; todo OF

                MOV EDX, _A             ; EDX now contains the pointer to AA
                ADD EDX, EAX            ; EDX now contains the pointer to the EAX_old-th element of AA
                MOV EAX, EDX            ; EAX:=EDX

                MOV ESI, ECX            ; copy k
                IMUL ESI, 8             ; ESI now contains the byte offset for X ; todo OF
                MOV EDX, _X             ; EDX now contains the pointer to X
                ADD EDX, ESI            ; EDX now contains the pointer to the k-th element of X

                ;PUSH EAX
                ;PUSH EBX
                ;PUSH ECX
                ;PUSH dword [EAX+4]      ; AA(EAX_old)
                ;PUSH dword [EAX]
                ;PUSH dword [EDX+4]      ; X(k)
                ;PUSH dword [EDX]
                ;PUSH dword fmt_flt_xaa
                ;CALL printf             ; print
                ;POP EAX
                ;POP EAX
                ;POP EAX
                ;POP EAX
                ;POP EAX
                ;POP ECX
                ;POP EBX
                ;POP EAX

                ; Multiply (X[k] * AA[KU+i-k-1][k]

                FLD qword [EAX]         ; load the EAX_old-th element of AA: AA(EAX_old)
                FLD qword [EDX]         ; load the k-th element of X: X(k)
                FMUL                    ; multiply ; todo of
                FSTP qword [EAX]        ; the element that EAX points to now equals X(k)*AA(EAX_old)

                ;PUSH EAX
                ;PUSH EBX
                ;PUSH ECX
                ;PUSH dword [EAX+4]      ; AA(EAX_old)
                ;PUSH dword [EAX]
                ;PUSH dword fmt_flt_xaa2
                ;CALL printf             ; print
                ;POP EAX
                ;POP EAX
                ;POP EAX
                ;POP ECX
                ;POP EBX
                ;POP EAX

                ; Add AAX[i-1] + (X[k] * AA[KU+i-k-1][k]

                MOV EDX, EBX            ; EDX=i
                DEC EDX                 ; EDX=i-1
                IMUL EDX, 8             ; EDX now contains the byte offset for AAX ; todo OF
                ADD EDX, ESP            ; EDX now contains the pointer to AAX(i-1)

                ;saveregs
                ;PUSH dword [EAX+4]      ; AAX(EDX)
                ;PUSH dword [EAX]
                ;PUSH dword fmt_flt_xaa2
                ;CALL printf             ; print
                ;POP EAX
                ;POP EAX
                ;POP EAX
                ;unsaveregs

                FLD qword [EAX]         ; load X(k)*AA(EAX_old)
                FLD qword [EDX]         ; load AAX(i-1)
                FADD                    ; add
                FSTP qword [EDX]        ; AAX will be saved on the stack, with its first element on top

skiptonextk:
                ; looping k
                INC ECX                 ; increment k
                MOV EDX, N              ; N
                CMP ECX, EDX            ; check whether k=N
                JNZ for_k               ; if not, repeat
k_finished:
                ; looping i
                INC EBX                 ; increment i
                MOV EDX, N              ; N
                INC EDX                 ; N+1
                CMP EBX, EDX            ; check whether i=N+1
                JNZ for_i               ; if not, repeat
;                JMP aax_test            ; diagnose whether AAX is correct


; AAX + YB = AAXYB, saved in Y
; AAXYB(i*INCY) = (AAX(i) + YB(i*INCY)) for each i=0..N-1
; Y is and remains an incremented array
aaxyb:
                MOV EBX, 0              ; counter i=0
                MOV ECX, N              ; N
                MOV EAX, _Y             ; EAX now points to B*Y(0)
aaxyb_body:                             ; sum and then calculate the new pointer to B*Y(i*INCY)
                MOV ESI, EBX            ; ESI now contains i
                IMUL ESI, 8             ; ESI now contains 8*i, the byte offset for AAX ; todo OF
                FLD qword [EAX]         ; load B*Y(i*INCY)
                FLD qword [ESP+ESI]     ; load AAX(i)
                FADD                    ; add
                FSTP qword [EAX]        ; write B*Y(i*INCY)=B*Y(i*INCY)+AAX(i)

                MOV ESI, INCY           ; ESI now contains INCY
                IMUL ESI, 8             ; ESI now contains the offset for B*Y ; todo OF
                ADD EAX, ESI            ; EAX now is the pointer to B*Y(i*INCY)

                ; looping i
                INC EBX                 ; i=i+1
                CMP EBX, ECX            ; is i=N?
                JNE aaxyb_body          ; if not, repeat

; Calculation successful
okay:
                MOV EAX, 0              ; set return to 0
                JMP finish

; Errors
merror:
                MOV EAX, -1
                JMP finish
nerror:
                MOV EAX, -2
                JMP finish
klerror:
                MOV EAX, -3
                JMP finish
kuerror:
                MOV EAX, -4
                JMP finish
alphaerror:
                MOV EAX, -5
                JMP finish
aerror:
                MOV EAX, -6
                JMP finish
ldaerror:
                MOV EAX, -7
                JMP finish
xerror:
                MOV EAX, -8
                JMP finish
incxerror:
                MOV EAX, -9
                JMP finish
betaerror:
                MOV EAX, -10
                JMP finish
yerror:
                MOV EAX, -11
                JMP finish
incyerror:
                MOV EAX, -12
                JMP finish
transerror:                             ; TRANS is none of N, n, T, t, C, c
                MOV EAX, -13
                JMP finish
oferror:
                MOV EAX, -14
                JMP finish
mnerror:
                MOV EAX, -15            ; A is not a square matrix!
                JMP finish

; EPILOGUE
finish:
                ; Restore registers
                ;MOV EAX, [EBP-4]        ; used for the return code
                MOV ECX, [EBP-8]
                MOV EDX, [EBP-12]
                MOV ESI, [EBP-16]
                MOV EDI, [EBP-20]
                
                CMP EBP, ESP            ; is the stack empty?
                JE finished             ; if so, nothing else to do
finishing:
                POP EBX                 ; pop from the stack
                CMP EBP, ESP            ; until it's empty
                JNE finishing
finished:                               ; stack clean, EBX restored
                POP EBP
                RET


; Testing

aa_test:
                MOV ESI, 0              ; counter/index
;                PUSH dword [EBP-28]            ; length
;                PUSH dword fmt_int
;                CALL printf
;                POP EBX
;                POP EBX
;                JMP okay               ; finish
aa_test_print:
                MOV EBX, _A             ; AA's pointer
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
                PUSH dword fmt_flt_aa
                CALL printf
                POP EDX
                POP EDX
                POP ECX

                ; looping
                INC ESI
                CMP ESI, [EBP-28]        ; AA's length
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

