CC=gcc
ASM=nasm

all: dgbmv

dgbmv.o: dgbmv.asm
	${ASM} -f elf32 -g -F dwarf -o dgbmv.o dgbmv.asm

dgbmv: dgbmv.o main.c
	${CC} -Wall -g -m32 -O0 -o dgbmv dgbmv.o main.c

clean:
	rm dgbmv dgbmv.o
