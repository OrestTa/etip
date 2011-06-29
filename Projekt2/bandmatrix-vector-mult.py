#!/usr/bin/env python
#-*- coding: utf-8 -*-
#
# The following programme multiplies a band matrix in band storage form and a supplied vector.
#

# Test as string or double?
TYPE="D"
#TYPE="S"

# Test values as strings

M_S = 5
N_S = 5
KU_S = 2
KL_S = 1

# Standard form:
#1: a j n 0 0
#2: f b k v 0
#3: 0 g c l p
#4: 0 0 h d m
#5: 0 0 0 i e

# Band storage form:
#1: 0 0 n v p
#2: 0 j k l m
#3: a b c d e
#4: f g h i 0
#6: 0 0 0 0 0
#7: 0 0 0 0 0
#8: 0 0 0 0 0
#9: 0 0 0 0 0

AA_S = [["0","0","n","v","p"],["0","j","k","l","m"],["a","b","c","d","e"],["f","g","h","i","0"],["0","0","0","0","0"],["0","0","0","0","0"],["0","0","0","0","0"],["0","0","0","0","0"]]

X_S = ["x1","x2","x3","x4","x5"]

AAX_S = ["nix","nix","nix","nix","nix"]

# Test values as doubles

M_D = 5
N_D = 5
KU_D = 2
KL_D = 1

# Standard form:
#1: 3.0 7.0 1.0 0.0 0.0
#2: 1.0 2.0 9.0 1.0 0.0
#3: 0.0 6.0 1.0 2.0 9.0
#4: 0.0 0.0 8.0 5.0 1.0
#5: 0.0 0.0 0.0 1.0 6.0

# Band storage form:
#1: 0.0 0.0 1.0 1.0 9.0
#2: 0.0 7.0 9.0 2.0 1.0
#3: 3.0 2.0 1.0 5.0 6.0
#4: 1.0 6.0 8.0 1.0 0.0
#6: 0.0 0.0 0.0 0.0 0.0
#7: 0.0 0.0 0.0 0.0 0.0
#8: 0.0 0.0 0.0 0.0 0.0
#9: 0.0 0.0 0.0 0.0 0.0

AA_D = [[0.0,0.0,1.0,1.0,9.0],[0.0,7.0,9.0,2.0,1.0],[3.0,2.0,1.0,5.0,6.0],[1.0,6.0,8.0,1.0,0.0],[0.0,0.0,0.0,0.0,0.0],[0.0,0.0,0.0,0.0,0.0],[0.0,0.0,0.0,0.0,0.0],[0.0,0.0,0.0,0.0,0.0]]

X_D = [12.0,3.0,1.0,0.0,8.0]

AAX_D = [0.0,0.0,0.0,0.0,0.0]

if TYPE == "D":
    M = M_D
    N = N_D
    KU = KU_D
    KL = KL_D
    AA = AA_D
    X = X_D
    AAX = AAX_D
elif TYPE == "S":
    M = M_S
    N = N_S
    KU = KU_S
    KL = KL_S
    AA = AA_S
    X = X_S
    AAX = AAX_S
else:
    print "Wrong type!"

print

# print AA
for i in xrange(0,len(AA)):
    for j in xrange(0,len(AA[0])):
        print AA[i][j],
    print
print
#/print AA

print "*"
print

# print X
for i in xrange(0,len(X)):
    print X[i],
    print
print
#/print X

print "="
print

if TYPE == "S":
    # AA * X [String]
    for i in xrange(1,N+1):
        for k in xrange(0,KU+KL+1+1):
            AAX[i-1] = AAX[i-1] + "+" + X[k+1-1] + "*" + AA[KU+i-k-1][k+1-1]
    #/AA * X [String]

elif TYPE == "D":
    # AA * X [Double]
    for i in xrange(1,N+1):
        for k in xrange(0,KU+KL+1+1):
            AAX[i-1] = AAX[i-1] + (X[k+1-1] * AA[KU+i-k-1][k+1-1])
    #/AA * X [Double]
else:
    print "Wrong type!"

# print AAX
for i in xrange(0,len(AAX)):
    print AAX[i],
    print
print
#/print AAX

