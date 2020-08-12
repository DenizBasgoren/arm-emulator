
	
initial_sp:        .word    0x200FFFFe
reset_vector:     .word     _start

.global _start

_start:

	
	//nop
	//rsbs	r2, r2, #0
	
	//strb r1, [r2, #5]
	//ldr r0, =#0xaabbccdd
	//revsh r1, r0
	ldr r3, =#0x20304050
	mov r1, #1
	mov r2, #2
	stmia r3, {r1, r2}


	bkpt