
.section .bss
orange:		.space 4
juice:		.space 4

.section .data

apple:        .asciz    "apple"
pineapple:     .asciz     "pineapple"
pen:		.asciz	"pen"


.section .text

initial_sp:        .word    0x200FFFFF
reset_vector:     .word     _start

.global _start

_start:
  ldr r1, =apple // r1: addr
  mov r2, #16
  ldr r0, [r1, r2] // r0: val of pen
  str r0, [r1] // store to apple
  ldr r1, =juice
  .hword 0xde00
  str r0, [r1] // store to juice
  .hword 0xde00
