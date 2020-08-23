
.section .text

_start:
mov r0, #1
ldr lr, =userspace
bx lr

mov r1, #2

userspace:
mov r1, #1
bkpt 1
.loop:
b loop







