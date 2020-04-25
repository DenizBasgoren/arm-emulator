initial_sp:	.word	0x10000
reset_vector: .word _main
.balign 4
_main:
    mov r0, #0
    .loop:
        add r0, #1
        cmp r0, #10
        bcc .loop

    .hword  0xde00