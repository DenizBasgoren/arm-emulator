initial_sp:	.word	0x10000
reset_vector: .word _main

_main:	ldr		r0, =0x40010000       //LCD row register
                                      //0x40010004 LCD column register
		                              //0x40010008 LCD color register
		                              //0x4001000C LCD refresh register
		                              //0x40010010 LCD clean register				
        ldr     r5, =0x123
		.hword 56832	
