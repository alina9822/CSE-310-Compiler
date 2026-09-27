# CSE-310 Compiler Project

This project is a completed academic compiler lab implementation focused on the core phases of compiler construction. It is a functioning mini-compiler for a subset of a C-like language and follows the structure expected in a compiler course project.

## What this project includes

This repository implements the main stages of a compiler:

- Lexical analysis with Flex
- Parsing with Yacc/Bison
- Symbol table and scope management
- Function and variable declarations
- Expressions and assignments
- Control flow with `if`, `else`, and `while`
- Return statements and print support
- Basic assembly-like code generation
- Sample input programs and generated output files

## Project structure

- `1905099.l` — lexer specification
- `1905099.y` — grammar, parser logic, and code generation
- `1905099_classes.h` — symbol table and scope table implementation
- `99s.sh` — build script
- `examples/inputs/` — source programs for testing
- `examples/outputs/` — generated assembly output files

## What this project is meant to do

This project is designed to demonstrate that a compiler can:

1. read a source-language program,
2. tokenize and parse it,
3. validate names and scopes,
4. generate intermediate assembly-style instructions,
5. handle a small but meaningful subset of a C-like language.

It provides a clear example of a compiler workflow suitable for a lab assignment and academic study.

## How to run

From the project root:

```bash
./1905099 examples/inputs/nested_conditions.c
```

This automatically writes the generated assembly to:

```text
examples/outputs/nested_conditions.asm
```

You may also provide an explicit output file name:

```bash
./1905099 examples/inputs/mixed_loop_logic.c examples/outputs/mixed_loop_logic.asm
```

## Build

```bash
bash 99s.sh
```

The script recompiles the lexer and parser and runs the compiler on the default example input.

## Example programs

The project includes several sample programs covering:

- arithmetic
- conditionals
- loops
- function calls
- nested logic

Example files are in:

- `examples/inputs/arithmetic.c`
- `examples/inputs/conditional_if.c`
- `examples/inputs/loop_and_function.c`
- `examples/inputs/mixed_loop_logic.c`
- `examples/inputs/nested_conditions.c`
- `examples/inputs/harder_compute_chain.c`

## Current status

This is a complete compiler-lab project in the academic sense: it covers the standard major tasks of a compiler course and generates assembly-style output for a small language subset.

The project presents a working end-to-end compiler flow for a C-like language subset, including parsing, semantic checks, and code generation in a course-appropriate structure.

## License

This project does not include a formal license file. It is intended for academic and educational use unless your course or institution specifies otherwise.
