

; test file for the assembler dev

.global _main

_main:
    MOV x0, x1;
    MOVS   x0, #101;
    MOVS x1, #57;
    ADDS x2, x0, x1;
    BL demo;
    CMP x0, x1;
    B.eq bar;
    BL bar

demo:
    ANDS x0, x1;
    EORS x0, x1;


foo:
    ANDS x0,x2;

bar:
    MOV x0, x1;

; random comment
