initial_sp:    	.word    0x3FFFFFFF
reset_vector: 	.word 	_main

// cells (current)
rand1: 			.word 	1140671485
rand2: 			.word 	12820163
seed: 			.word 	1557

_main:
	bl init
	.hword	0xde00

	.game_loop:
	bl draw
	bl update
	b .game_loop

/////////////////////////////////////////////////
init:
	ldr r4, =#0x20000000 // for i in cells

	.set_pixel_randomly:
		ldr r1, =seed	// r0 = &seed
		ldr r0, [r1]	// r0 = *r0

		ldr r2, =rand1 	// r1 = &rand1
		ldr r1, [r2]	// r1 = *r1

		ldr r3, =rand2  // r2 = &rand2
		ldr r2, [r3]	// r1 = *r1

		mul r0, r1		// r0 *= r1	
		add r0, r2		// r0 += r2

		ldr r1, =seed	// r1 = &seed
		str r0, [r1]	// *r0 = *r1
		cmp r0, #0		
		ble .cell_is_zero

		// else
		mov r1, #1
		str r1, [r4]
		b .move_onto_next_cell

		.cell_is_zero:
		mov r1, #0
		str r1, [r4]

		.move_onto_next_cell:
		add r4, #1

		ldr r1, =#0x20001518
		cmp r4, r1
		bcc .set_pixel_randomly

	bx lr



////////////////////////////////////////
draw:
	bx lr


update:
	bx lr
