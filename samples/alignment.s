
.section .bss
.balign 4
orange:		.space 4
juice:		.space 4

.section .data

apple:        .asciz    "apple"
pineapple:     .asciz     "pineeapple"
pen:		.asciz	"pen"


.section .text

initial_sp:        .word    0x200FFFFF
reset_vector:     .word     _start

.global _start

_start:
  .hword 0xde00