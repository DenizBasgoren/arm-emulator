
.section .text

initial_sp:        .word    0x200FFFFF
reset_vector:     .word     onReset

.global onReset
