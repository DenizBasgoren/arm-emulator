

initsp: .word 0x20000100
initpc: .word _start
junk: .ascii "pikotaro"

_start:

ldr r0, =0xaabbccdd
ldr r1, =0x11223344
ldr r0, =0xaabbccdd
nop
ldr r1, =0x11223344
ldr r0, =0xaabbccdd
ldr r1, =0x11223344
nop
ldr r0, =0xaabbccdd
ldr r1, =0x11223344
ldr r0, =0xaabbccdd
ldr r1, =0x11223344
ldr r2, =junk


