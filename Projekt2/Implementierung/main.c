#include <stdio.h>

/*
 * This external ASM function performs a matrix-vector-operation of
 * Y := ALPHA * A * X + BETA * Y
 * where A is a matrix, ALPHA and BETA are scalars, X and Y are vectors.
 * It is possible to have A transposed first.
 */
extern int dgbmv(char trans, int m, int n, int kl, int ku, double *alpha, \
              double (*a)[], int lda, double (*x)[], int incx, double *beta, \
              double (*y)[], int incy);


// Helper functions

/*
 * This function prints a vector of doubles in the form of
 * X: (1.0, 2.0, 3.0, ...) .
 */
void printv(char name, double vector[], int size) {
    int i;
    int length = size/sizeof(double);
    printf("%c    : (", name);
    for(i=0; i<length; i++) {
        printf("%12f", vector[i]);
        if( i < length-1 ) printf(", ");
        if ( (i+1)%10 == 0) printf("\n        "); // break line after 13 doubles
        }
    printf(")\n");
    }

/*
 * This function prints the error code from dgbmv():
    M_INVALID       = -1,
    N_INVALID       = -2,
    KL_INVALID      = -3,
    KU_INVALID      = -4,
    ALPHA_INVALID   = -5,
    A_INVALID       = -6,
    LDA_INVALID     = -7,
    X_INVALID       = -8,
    INCX_INVALID    = -9,
    BETA_INVALID    = -10,
    Y_INVALID       = -11,
    INCY_INVALID    = -12,
    TRANS_INVALID   = -13,
    OVERFLOW        = -14,
    NOT_A_SQUARE    = -15 .
 */
void printe(int error) {
    printf("[%i] ", error);
    switch (error) {
        case -1:
            printf("M invalid");
            break;
        case -2:
            printf("N invalid");
            break;
        case -3:
            printf("KL invalid");
            break;
        case -4:
            printf("KU invalid");
            break;
        case -5:
            printf("ALPHA invalid");
            break;
        case -6:
            printf("A invalid");
            break;
        case -7:
            printf("LDA invalid");
            break;
        case -8:
            printf("X invalid");
            break;
        case -9:
            printf("INCX invalid");
            break;
        case -10:
            printf("BETA invalid");
            break;
        case -11:
            printf("Y invalid");
            break;
        case -12:
            printf("INCY invalid");
            break;
        case -13:
            printf("TRANS invalid");
            break;
        case -14:
            printf("Overflow");
            break;
        case -15:
            printf("A is not a square matrix");
            break;
        }
    printf("\n");
    }


/*
 * This is the entry point.
 */
int main(int argc, char *argv[]) {

    /* define INPUT parameters here */
    char trans   = 't';
    int  m       = 9;
    int  n       = 9;
    int  kl      = 1;
    int  ku      = 3;
    double alpha = -2.0;
    // bandmatrix - row by row
    double a[]   = {0.0, 0.0, 0.0, 1.4, 2.5, 3.6, 6.5, 4.3, 3.2, \
                    0.0, 0.0, 1.3, 2.4, 3.5, 4.6, 6.5, 4.2, 0.0, \
                    0.0, 1.2, 2.3, 3.4, 4.5, 5.6, 7.7, 5.1, 9.8, \
                    1.1, 2.2, 3.3, 4.4, 5.5, 6.6, 1.8, 0.0, 3.6, \
                    2.1, 3.2, 4.3, 5.4, 6.5, 4.3, 0.0, 5.1, 0.0, \
                    1.1,2.2,3.3,4.4,5.5}; // A with extended length (testing)
    int lda      = 5;
    double x[]   = {1.0,0.0,2.0,0.0,3.0,0.0,4.0,0.0,5.0,0.0,6.0,0.0,7.0,0.0,8.0,0.0,9.0,0.0,\
                    1.1,2.2,3.3,4.4,5.5,6.6}; // X with extended length (testing)
    int incx     = -2;
    double beta  = -3.0;
    double y[]   = {6.0,0.0,0.0,7.0,0.0,0.0,8.0,0.0,0.0, \
                    9.0,0.0,0.0,0.0,0.0,0.0,6.0,0.0,0.0, \
                    7.1,0.0,0.0,8.2,0.0,0.0,3.0,0.0,0.0, \
                    0.0, 3.0, 2.3, 3.2}; // Y with extended length (testing)
    int incy     = 3;


    /* define INPUT parameters here */
/*    char trans   = 'n';
    int  m       = 9;
    int  n       = 9;
    int  kl      = 1;
    int  ku      = 3;
    double alpha = 2.0;
    // bandmatrix - row by row
    double a[]   = {0.0, 0.0, 0.0, 1.4, 2.5, 3.6, 6.5, 4.3, 3.2, \
                    0.0, 0.0, 1.3, 2.4, 3.5, 4.6, 6.5, 4.2, 0.0, \
                    0.0, 1.2, 2.3, 3.4, 4.5, 5.6, 7.7, 5.1, 9.8, \
                    1.1, 2.2, 3.3, 4.4, 5.5, 6.6, 1.8, 0.0, 3.6, \
                    2.1, 3.2, 4.3, 5.4, 6.5, 4.3, 0.0, 5.1, 0.0}; 
    int lda      = 5;
    double x[]   = {1.0,2.0,3.0,4.0,5.0,6.0,7.0,8.0,9.0};
    int incx     = 1;
    double beta  = 3.0;
    double y[]   = {6.0,0.0,0.0,7.0,0.0,0.0,8.0,0.0,0.0, \
                    9.0,0.0,0.0,0.0,0.0,0.0,6.0,0.0,0.0, \
                    7.1,0.0,0.0,8.2,0.0,0.0,3.0,0.0,0.0};
    int incy     = 3;
*/
    /* define INPUT parameters here */
/*    char trans   = 'n';
    int  m       = 6;
    int  n       = 6;
    int  kl      = 1;
    int  ku      = 3;
    double alpha = 2.0;
    // bandmatrix - row by row
    double a[]   = {0.0, 0.0, 0.0, 1.4, 2.5, 3.6, \
                    0.0, 0.0, 1.3, 2.4, 3.5, 4.6, \
                    0.0, 1.2, 2.3, 3.4, 4.5, 5.6, \
                    1.1, 2.2, 3.3, 4.4, 5.5, 6.6, \
                    2.1, 3.2, 4.3, 5.4, 6.5, 0.0}; 
    int lda      = 5;
    double x[]   = {1.0,2.0,3.0,4.0,5.0,6.0};
    int incx     = 1;
    double beta  = 3.0;
    double y[]   = {1.0, 2.0, 3.0, 4.0, 5.0, 6.0};
    int incy     = 1;*/


    /* print INPUT paramters */
    printf("********************************************************************************\n");
    printf("*                                    DGBMV                                     *\n");
    printf("********************************************************************************\n");
    printf("INPUT Parameters:\n");
    printf("TRANS: %c\n", trans);
    printf("M    : %i\n", m);
    printf("N    : %i\n", n);
    printf("KL   : %i\n", kl);
    printf("KU   : %i\n", ku);
    printf("ALPHA: %f\n", alpha);
    printv('A', a, sizeof(a));
    printf("LDA  : %i\n", lda);
    printv('X', x, sizeof(x));
    printf("INCX : %i\n", incx);
    printf("BETA : %f\n", beta);
    printv('Y', y, sizeof(y));
    printf("INCY : %i\n", incy);
    printf("\n");

    /* call the ASM function */
    int result = dgbmv(trans, m, n, kl, ku, &alpha, &a, lda, &x, incx, \
                       &beta, &y, incy);

    /* print the result or an error */
    if( result >= 0 ) {
        printf("OUTPUT Result:\n");
        printv('Y', y, sizeof(y));
        //printv('A', a, 1, sizeof(a)); // - for testing purposes only
        }
    else {
        printf("OUTPUT Error:\n");
        printe(result);
    }

    return 0;
    }
