
.section .data

pikotaro: .ascii "pen pineapple apple pen"

.section .text

initial_sp:        .word    0x200FFFF0
reset_vector:     .word     _start

_start:

ldr r1, =pikotaro
ldr r0, =0x01020304
ldr r2, =0x21222324
ldr r5, =0x51525354
ldr r6, =0x61626364
stmia r1!, {r0, r2, r5, r6}
bkpt 0
