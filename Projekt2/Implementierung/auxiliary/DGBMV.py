#!/usr/bin/env python
#-*- coding: utf-8 -*-
 ##
 # This file is part of etip-ss11-g07.
 #
 # Copyright (C) 2011 Lukas Märdian <lukasmaerdian@gmail.com>
 # Copyright (C) 2011 M. S.
<<<<<<< HEAD
 # Copyright (C) 2011 Orest Tarasiuk <orest.tarasiuk@tum.de>
=======
 # Copyright (C) 2011 Orest Tarasiuk <orest@mytum.de>
>>>>>>> 6fedb0363ec5a4d71a7250336c06b8d195fb2baa
 #
 # This program is free software; you can redistribute it and/or modify
 # it under the terms of the GNU General Public License as published by
 # the Free Software Foundation; either version 3 of the License, or
 # (at your option) any later version.
 #
 # This program is distributed in the hope that it will be useful,
 # but WITHOUT ANY WARRANTY; without even the implied warranty of
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 # GNU General Public License for more details.
 #
 # You should have received a copy of the GNU General Public License
 # along with this program. If not, see <http://www.gnu.org/licenses/>.
 ##

#
# The following script calculates Y := ALPHA * A * X + BETA * Y
#

def shift(seq, n):
    n = n % len(seq)
    return seq[n:] + seq[:n]

M = 9
N = 9
KU = 3
KL = 1
LDA = 5

TRANS = 'T'

ALPHA = 2.0
BETA = -3.0

INCX = 1
INCY = 2

A =   [[-0.0, 0.0, 0.0, 1.4, 2.5, 3.6, 6.5, -4.3, 3.2], \
       [-0.0, -0.0, 1.3, 2.4, -3.5, 4.6, 6.5, 4.2, -0.0], \
       [0.0, 1.2, 12.3, -3.4, 4.5, -1.6, 7.7, -5.1, 9.8], \
       [-1.1, 2.2, -13.3, 4.4, 5.5, -9.6, -1.8, 0.0, 3.6], \
       [2.1, 3.2, 4.3, 5.1, 6.5, 4.13, -0.0, 5.1, 0.0]]

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
X_inced =    [1.0,2.0,3.0,4.0,5,6.0,7.0,8.0,9.0] # without trailing irrelevant values
for i in xrange(0,len(X)):
    X[i] = X_inced[i*abs(INCX)]
if (INCX < 0):
    X.reverse()

#Y_inced =    [6.0,0.0,0.0,7.0,0.0,0.0,8.0,0.0,0.0, \
#              9.0,0.0,0.0,0.0,0.0,0.0,6.0,0.0,0.0, \
#              7.1,0.0,0.0,8.2,0.0,0.0,3.0,0.0,0.0] # without trailing irrelevant values
Y = [0.0]*M
Y_inced =    [-1.0,0.0,-4.0,0.0,15.0,0.0, \
              -19.3,0.0,0.0,0.0,-3.0,0.0, \
                3.5,0.0,5.1,0.0,-7.1,0.0]
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
