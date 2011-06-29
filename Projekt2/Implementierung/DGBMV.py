#!/usr/bin/env python
#-*- coding: utf-8 -*-
#
# The following script calculates Y := ALPHA * A * X + BETA * Y
#

# Test as string or double?
TYPE="D"
#TYPE="S"

# Test values as doubles

M_D = 9
N_D = 9
KU_D = 3
KL_D = 1
LDA_D = 5

TRANS_D = 'n'

ALPHA_D = 2.0
BETA_D = 3.0

INCX_D = 1
INCY_D = 3

A_D = [[0.0, 0.0, 0.0, 1.4, 2.5, 3.6, 6.5, 4.3, 3.2], \
       [0.0, 0.0, 1.3, 2.4, 3.5, 4.6, 6.5, 4.2, 2.7], \
       [0.0, 1.2, 2.3, 3.4, 4.5, 5.6, 7.7, 8.8, 5.5], \
       [1.1, 2.2, 3.3, 4.4, 5.5, 6.6, 1.1, 2.2, 3.3], \
       [2.1, 3.2, 4.3, 5.4, 6.5, 0.0, 0.0, 0.0, 0.0]]

X_D =  [1.0,2.0,3.0,4.0,5.0,6.0,7.0,8.0,9.0]

Y_D =  [6.0,0.0,0.0,7.0,0.0,0.0,8.0,0.0,0.0, \
        9.0,0.0,0.0,0.0,0.0,0.0,6.0,0.0,0.0, \
        7.1,0.0,0.0,8.2,0.0,0.0,3.0,0.0,0.0]

AAXYB_D = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0] # this will be our result!

if TYPE == "D":
    M = M_D
    N = N_D
    KU = KU_D
    KL = KL_D
    LDA = LDA_D
    TRANS = TRANS_D
    ALPHA = ALPHA_D
    BETA = BETA_D
    INCX = INCX_D
    INCY = INCY_D
    A = A_D
    X = X_D
    Y = Y_D
    AAXYB = AAXYB_D

else:
    print "Wrong type!"

# Y := ALPHA * A * X + BETA * Y

print

# print A
print "A:"
for i in xrange(0,len(A)):
    for j in xrange(0,len(A[0])):
        print A[i][j],
    print
print
#/print A

print "*"
print
print "ALPHA:"
print ALPHA
print
print "*"
print

# print X
print "X:"
for i in xrange(0,len(X)):
    print X[i],
print
#/print X

print
print "+"
print
print "BETA:"
print BETA
print
print "*"
print

# print Y
print "Y:"
for i in xrange(0,len(Y)):
    print Y[i],
print
#/print Y

print
print "->"
print

# Y := ALPHA * A * X + BETA * Y

# ALPHA*A
print "ALPHA*A:"
for i in xrange(0,len(A)):
    for j in xrange(0,len(A[0])):
        A[i][j] = (ALPHA*A[i][j])
        print A[i][j],
    print
print

# ALPHA*A*X
print "ALPHA*A*X:"

for i in xrange(1,N+1):
    for k in xrange(0,KU+KL+1+1):
        if (KU+i-k-1) >= 0:
            if (KU+i-k-1) <= (LDA-1):
                AAXYB[i-1] = AAXYB[i-1] + (X[k+1-1] * A[KU+i-k-1][k+1-1])

# print AAXYB
for i in xrange(0,len(AAXYB)):
    print AAXYB[i],
print
print
#/print AAXYB

# Y*BETA
print "Y*BETA:"

for i in xrange(0,len(Y)):
    Y[i] = (BETA*Y[i])
    print Y[i],
print
print

# Y*BETA+ALPHA*A*X
print "Y*BETA+ALPHA*A*X:"

for i in xrange(0,len(AAXYB)):
    AAXYB[i] = Y[3*i] + AAXYB[i]
    print AAXYB[i],
print

# TODO: INC!!!
