;
; The following code calculates
; Y := ALPHA * A  * X + BETA * Y
; or alternatively
; Y := ALPHA * A' * X + BETA * Y
;
; TODO:
; On entry, BETA specifies the scalar beta. When BETA is 
; supplied as zero then Y need not be set on input. 
; incx, negative inc, check negative doubles as input; transpose
; save registers; save INCs and perhaps X or V

extern printf                           ; the C function to be called, for testing only

section .data                           ; data, for testing only

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

; Data:                                  ; for testing only
;a:  dd   5                              ; int a = 5;
;flt2:   dq  -123.456789e300             ; 64-bit floating point

; in order to print, push like this:
;                MOV EAX, [a]    ;
;                ADD EAX, 2      ; 
;                PUSH EAX        ; stack3
;                PUSH dword [a]  ; stack2
;                ADD EAX, 3
;                PUSH EAX        ; stack1
;                PUSH dword fmt  ; stack0
;                CALL printf
;                POP EAX            
;                POP EAX
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

; Store a negatively incremented vector as a positively incremented vector
; manipulating it's pointer; update INCZ
; z_new[i] = z[|INCZ| * n - |INCZ| * (i+1)]
%macro neginc 0
               ;??????????????????? 
%endmacro

%macro saveregs 0
                PUSH EAX
                PUSH EBX
                PUSH ECX
                PUSH EDX
                PUSH ESI
%endmacro
%macro unsaveregs 0
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

; DGBMV - PROLOGUE
dgbmv:
                PUSH EBP
                MOV EBP, ESP

; Try to check whether all parameters are legal
                CMP dword M, 0
                JL merror
                CMP dword N, 0
                JL nerror
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


; memcpy FROM, TO, LENGTH -- ESI, EDI, EBX
; FROM: Pointer to starting point
; TO: Pointer to destination point
; LENGTH: Length in doubles (8 byte blocks)
;
; All registers stay unchanged after calling this subroutine!
memcpy:
                PUSH EDX                ; save EDX, as we'll change it
                PUSH EAX                ; save EAX, as we'll change it
                SHL EBX, 1              ; EBX*2 - double the length (EBX), so that we can calculate with 4 byte blocks
                MOV EDX, 0              ; init counter
cpy_loop:
                MOV EAX, [ESI+EDX*4]    ; move 4 bytes from starting point to EAX
                MOV [EDI+EDX*4], EAX    ; move 4 bytes from EAX to destination point
                INC EDX                 ; increment counter
                CMP EDX, EBX            ; check if we're finished
                JNE cpy_loop            ; if not - repeat
                SHR EBX, 1              ; EBX/2 - restore the original length (EBX)
                POP EAX                 ; restore EAX, as we changed it
                POP EDX                 ; restore EDX, as we changed it
                ret

; Transpose the matrix -- Copy the origianl Matrix A to it's new location at [EBP-8] and transpose it on the fly
transpose:
                MOV EAX, LDA            ; calculate needed size for A_trans
                IMUL EAX, dword N
                PUSH EAX                ; push the lenght of A
                PUSH dword 0x0          ; reserve memory for A's duplicate's pointer at [EBP-8]
alloc_loop:
                PUSH dword 0x0          ; push "lenght of A" qwords, to reserver memory for A_trans
                PUSH dword 0x0
                DEC EAX
                JNZ alloc_loop

                MOV [EBP-8], ESP        ; save pointer to A_trans in [EBP-8]
; ======================================================================================================================
                ; START A
                MOV ESI, _A
                MOV ECX, KU
                IMUL ECX, 8
                ADD ESI, ECX
                ; ZIEL A_trans
                MOV EDI, [EBP-8]
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
ku_loop:
                ;memcpy ESI, EDI, EBX
                call memcpy

                ; START := START+(N-1)*8
                MOV EAX, N
                DEC EAX
                IMUL EAX, 8
                ADD ESI, EAX
                ; ZIEL := ZIEL-N*8
                MOV EAX, N
                IMUL EAX, 8
                SUB EDI, EAX
                ; LENGTH := LENGTH+1
                INC EBX
                ; Decrement counter
                DEC ECX
                JNZ ku_loop
; ============================================================ Upper Diagonals and Main Diagonal from A are now copied to A_trans
                ; Length--
                DEC EBX
                ; Counter
                MOV ECX, KL
                JMP aa_test
kl_loop:
                ; START := START+N*8
                MOV EAX, N
                IMUL EAX, 8
                ADD ESI, EAX
                ; ZIEL := ZIEL-(N-1)*8
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
; ============================================================ Lower Diagonals and Main Diagonal from A are now copied to A_trans
; Proceed
proceed0:
                MOV EAX, LDA            ; LDA, first operand
                ;MOV EAX, 0xFFFFFFFF     ; test for OF detection
                IMUL EAX, dword N       ; LDA*N, second operand; TODO: error if OF
                ;JC oferror
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
;                 AAX[i-1] = AAX[i-1] + (X[k+1-1] * AA[KU+i-k-1][k+1-1])
; todo! increment for x!!!!
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
                DEC EAX                 ; KU+i-k-1 : EAX now contains the desired row of AA, from 0

                ;PUSH EAX                ; row
                ;PUSH ECX                ; k
                ;PUSH dword fmt_int_k
                ;CALL printf             ; print
                ;POP ECX
                ;POP ECX
                ;POP EAX

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

                IMUL EAX, 8             ; EAX now contains the byte offset for AA ; todo OF

                MOV EDX, [EBP-8]        ; EDX now contains the pointer to AA
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

                ;PUSH EAX                ; row
                ;PUSH ECX                ; k
                ;PUSH dword fmt_int_k
                ;CALL printf             ; print
                ;POP EDX
                ;POP EDX
                ;POP EDX

                INC ECX                 ; increment k
                MOV EDX, N              ; N
                CMP ECX, EDX            ; check whether k=N
                JNZ for_k               ; if not, repeat
k_finished:
                ; looping i

                ;saveregs
                ;PUSH dword [EDX+4]
                ;PUSH dword [EDX]
                ;PUSH EBX                ; i
                ;PUSH dword fmt_i
                ;CALL printf             ; print the last float64 on stack
                ;POP EBX
                ;POP EBX
                ;POP EDX
                ;POP EDX
                ;unsaveregs

                INC EBX                 ; increment i
                MOV EDX, N              ; N
                INC EDX                 ; N+1
                CMP EBX, EDX            ; check whether i=N+1
                JNZ for_i               ; if not, repeat
;                JMP aax_test            ; diagnose whether AAX is correct

; AAX + YB = AAXYB, saved in Y; AAXYB(i*INCY) = (AAX(i) + YB(i*INCY)) for each i=0..N-1
; Warning: Y is and remains an incremented array!
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

; The function succeded 
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

; EPILOGUE
finish:
                CMP EBP, ESP            ; is the stack empty?
                JE finished             ; if so, nothing else to do
finishing:
                POP EBX                 ; pop from the stack
                CMP EBP, ESP            ; until it's empty
                JNE finishing
finished:
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
                PUSH dword fmt_flt_aa
                CALL printf
                POP EDX
                POP EDX
                POP ECX

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

