
.section .data
hello: .asciz "Hello world!"

.section .text
bkpt #0
ldr r0, =hello
bkpt #5




