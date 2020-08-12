

initial_sp:        .word    0x200FFFFF
reset_vector:     .word     _start

_start:

ldr r0, =0xaabbccdd
.hword 0xde00