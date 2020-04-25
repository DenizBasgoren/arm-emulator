initial_sp:	.word	0x10000
reset_vector: .word _main
_main:
    ldr r1, =#0x20000000 
    mov r2, #5
    str r2, [r1]
    ldr r3, [r1]