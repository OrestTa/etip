#include <stdio.h>

/* prototype for the asm function */
extern int dgbmv(char trans, int m, int n, int kl, int ku, double *alpha, \
              double (*a)[], int lda, double (*x)[], int incx, double *beta, \
              double (*y)[], int incy);

void printv(char name, double vector[], int inc, int size) {
        int i;
        int length = size/sizeof(double);
        printf("%c    : (", name);
        for(i=0; i<length; i=i+inc) {
            printf("%f", vector[i]);
            if( i < length-1 ) printf(", ");
            }
        printf(")\n");
    }

int main(int argc, char *argv[]) {
    /* define the parameters */
    char trans   = 'n';
    int  m       = 5;
    int  n       = 5;
    int  kl      = 3;
    int  ku      = 3;
    double alpha = 1.0;
    double a[]   = {1.0, 2.0}; 
    int lda      = 5;
    double x[]   = {1.0,2.0,3.0,4.0,5.0};
    int incx     = 1;
    double beta  = 2.0;
    double y[]   = {6.0,0.0,7.0,0.0,8.0,0.0,9.0,0.0,0.0};
    int incy     = 2;

    printf("\n");
    printf("INPUT Parameters:\n");
    printf("TRANS: %c\n", trans);
    printf("M    : %i\n", m);
    printf("N    : %i\n", n);
    printf("KL   : %i\n", kl);
    printf("KU   : %i\n", ku);
    printf("ALPHA: %f\n", alpha);
    printv('A', a, 1, sizeof(a));
    printf("LDA  : %i\n", lda);
    printv('X', x, incx, sizeof(x));
    printf("INCX : %i\n", incx);
    printf("BETA : %f\n", beta);
    printv('Y', y, incy, sizeof(y));
    printf("INCY : %i\n", incy);
    printf("\n");

    /* call the actual asm function */
    int result = dgbmv(trans, m, n, kl, ku, &alpha, &a, lda, &x, incx, \
                       &beta, &y, incy);

    /* print the calculated result or an error */
    if( result >= 0 ) {
        printf("OUTPUT Result:\n");
        printv('Y', y, incy, sizeof(y));
        }
    else {
        printf("OUTPUT Error:\n");
        printf("ERROR: %i\n", result);
    }
    printf("\n");

    return 0;
}
