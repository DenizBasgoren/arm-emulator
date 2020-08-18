
.section .bss
zd:			.space 4

.section .text

initial_sp:        .word    0x20010000
reset_vector:     .word     _start

xd:				.word		0x44556677 // 853.601
yd:				.word		0x41aabbcc // 21.3417
							// should get 0x468e5297

.global xd, yd, zd

