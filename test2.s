initial_sp:	.word	0x10000
reset_vector: .word _main

_main:	mvn r2, r3
		neg r2, r3
		.hword 56832	
