# makefile for perimeter.asm
task: main.c input.o rnd.h output.o
	gcc -g -o task main.asm input.o rnd.h output.o -no-pie
input.o: input.asm
	nasm -f elf64 -g -F dwarf input.asm -l input.lst
output.o: output.asm
	nasm -f elf64 -g -F dwarf output.asm -l output.lst
