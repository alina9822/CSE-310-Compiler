# CSE-310 Compiler Project

This repository contains a compiler-related lab project built around a lexer, a parser, and a symbol table implementation. The project is designed to demonstrate core compiler concepts such as tokenization, grammar parsing, scope management, and symbol tracking.

## Project overview

The codebase implements a simplified compiler workflow for a custom mini-language. It includes:

- a lexical analyzer written with Flex
- a grammar and parser written with Yacc/Bison
- a scope-aware symbol table for variable/function tracking
- a sample input file for testing

## Directory summary

- `1905099.l` — Flex lexer specification. It tokenizes keywords, operators, identifiers, numbers, and other language constructs.
- `1905099.y` — Yacc/Bison grammar file. It defines the language grammar and parse tree generation logic.
- `1905099_classes.h` — Core data structures for `SymbolInfo`, `ScopeTable`, and `SymbolTable`. This is the heart of the symbol table and scope management.
- `1905099_main.cpp` — Main driver program for symbol-table operations such as insert, lookup, delete, enter scope, exit scope, and print scope tables.
- `1905099_input.txt` — Example input used to test the program.
- `99s.sh` — Build script that compiles the lexer and parser into an executable.
- `lex.yy.c` — Generated lexer source from Flex.

## What the project does

The project mainly focuses on the following compiler concepts:

1. Token recognition
2. Grammar-driven parsing
3. Symbol table construction
4. Scope handling
5. Parse tree output
6. Basic error tracking and reporting

The final executable is intended to process a sequence of commands for a symbol table, such as:

- `I name type` — insert symbol
- `L name` — lookup symbol
- `D name` — delete symbol
- `S` — enter new scope
- `E` — exit current scope
- `P C` / `P A` — print current/all scopes
- `Q` — terminate

## Build and run

The project expects Flex and Yacc/Bison to be installed.

### On Ubuntu/Debian

```bash
sudo apt-get update
sudo apt-get install flex bison
bash 99s.sh
```

### Manual build

```bash
yacc -d -y 1905099.y
g++ -w -c -o y.o y.tab.c
flex 1905099.l
g++ -w -c -o l.o lex.yy.c
g++ y.o l.o -lfl -o 1905099
./1905099
```

> The current environment does not have `yacc` and `flex` installed, so the build script fails until those dependencies are present.

## Notes

This project appears to be a university compiler lab assignment and is best understood as a learning-oriented implementation rather than a production compiler. It demonstrates the internal mechanics of lexical analysis and parse tree construction for a small language grammar.

## License

This project does not include an explicit license file. Use it for academic and educational purposes unless your course or institution specifies otherwise.
