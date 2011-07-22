#!/usr/bin/env python
#-*- coding: utf-8 -*-
 ##
 # This file is part of etip-ss11-g07.
 #
 # Copyright (C) 2011 Lukas Märdian <lukasmaerdian@gmail.com>
 # Copyright (C) 2011 M. S.
 # Copyright (C) 2011 Orest Tarasiuk <orest@mytum.de>
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

'''
* The following program segment will transfer a band matrix
* from conventional full matrix storage to band storage:
*
* DO 20, J = 1, N
* K = KU + 1 - J
* DO 10, I = MAX( 1, J - KU ), MIN( M, J + KL )
* A( K + I, J ) = matrix( I, J )
* 10 CONTINUE
* 20 CONTINUE
'''

#test values
M = 4
N = 4
KU = 1
KL = 1
'''
1 2 0 0
4 5 6 0
0 8 9 3
0 0 1 2
'''
matrix = [[1,4,0,0],[2,5,8,0],[0,6,9,1],[0,0,3,2]]
A = [["x","x","x"],["x","x","x"],["x","x","x"],["x","x","x"]]
'''
x 2 6 3
1 5 9 2
4 8 1 x
'''

# print matrix
for i in xrange(0,len(matrix[0])):
    for j in xrange(0,len(matrix)):
        print matrix[j][i],
    print
print
#/print matrix

for J in xrange( 1, N+1 ):
    K = KU + 1 - J
    for I in xrange( max([1,J-KU]), min([M,J+KL])+1):
        #print K+I-1,"/",J-1," -- ",I-1,"/",J-1
        A[J-1][K+I-1] = matrix[J-1][I-1]
print

# print A
for i in xrange(0,len(A[0])):
    for j in xrange(0,len(A)):
        print A[j][i],
    print
print
#/print A
