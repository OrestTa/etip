#!/usr/bin/env python
#-*- coding: utf-8 -*-
#
# The following script calculates Y := ALPHA * A * X + BETA * Y
#

def shift(seq, n):
    n = n % len(seq)
    return seq[n:] + seq[:n]

M = 6
N = 6
KU = 3
KL = 1
LDA = 5

TRANS = 'N'

ALPHA = 7.0
BETA = 4.0

INCX = 3
INCY = -2

#A = (000936|001893|073958|264855|823740)
A =   [[0.0, 0.0, 0.0, 9.0, 3.0, 6.0], \
       [0.0, 0.0, 1.0, 8.0, 9.0, 3.0], \
       [0.0, 7.0, 3.0, 9.0, 5.0, 8.0], \
       [2.0, 6.0, 4.0, 8.0, 5.0, 5.0], \
       [8.0, 2.0, 3.0, 7.0, 4.0, 0.0]]

# transpose A
if (TRANS == 't' or TRANS == 'T' or TRANS == 'c' or TRANS == 'C'):
    A.reverse()
    kl = KL
    ku = 0
    maind = 0
    i = 0
    for line in A:
        if(kl>0):
            line = shift(line,-kl)
            kl -= 1
            A[i] = line
            i += 1
            continue
        if(ku<=KU):
            line = shift(line,ku)
            ku += 1
            A[i] = line
            i += 1
            continue 

X = [0.0]*N
#X = (1,0,0,2,0,0,3,0,0,4,0,0,5,0,0,6)
X_inced =    [1.0,0.0,0.0,2.0,0.0,0.0,3.0,0.0,0.0,4.0,0.0,0.0,5,0.0,0.0,6.0] # without trailing irrelevant values
for i in xrange(0,len(X)):
    X[i] = X_inced[i*abs(INCX)]
if (INCX < 0):
    X.reverse()

Y = [0.0]*M
#Y = (9,0,8,0,7,0,6,0,5,0,4)
Y_inced =    [9.0,0.0,8.0,0.0,7.0,0.0,6.0,0.0,5.0,0.0,4.0]
for i in xrange(0,len(Y)):
    Y[i] = Y_inced[i*abs(INCY)]
if (INCY < 0):
    Y.reverse()

AAXYB = [0.0]*N

print
print "Y = AAXYB := ALPHA * A * X + BETA * Y"

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
    for k in xrange(0,N):
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
    AAXYB[i] = Y[i] + AAXYB[i]
    print AAXYB[i],
print
print
