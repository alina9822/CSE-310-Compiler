#!/bin/bash

INPUT_FILE="${1:-examples/inputs/arithmetic.c}"
OUTPUT_FILE="${2:-assembly.asm}"

yacc -d -y 1905099.y
g++ -w -c -o y.o y.tab.c
flex 1905099.l
g++ -w -c -o l.o lex.yy.c
g++ y.o l.o -lfl -o 1905099
./1905099 "$INPUT_FILE" "$OUTPUT_FILE"
