
.section .data
xd:				.word		0x136 // 310.1
zd:				.word		0

.section .text

initial_sp:        .word    0x20010000
reset_vector:     .word     _start


.global xd, zd