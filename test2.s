initial_sp:        .word    0x3FFFFFFF
reset_vector:     .word     _main

_main:
    bl init
    .hword 0xde00

    .game_loop:
    bl draw
    bl update
    b .game_loop

/////////////////////////////////////////////////
init:
    ldr r4, cells                        // cells

    .set_pixel_randomly:
        //.hword 0xde00
        ldr r0, seed                    // seed
        ldr r1, rand1                    // rand1
        ldr r2, rand2                    // rand2

        mul r0, r1                        // r0 *= r1
        add r0, r2                        // r0 += r2

        ldr r1, =seed                    // seed = r0
        str r0, [r1]

        cmp r0, #0                        // if r0 < 0
        ble .cell_is_zero

        // else cell_is_one
        mov r1, #1
        str r1, [r4]

        b .move_onto_next_cell

        .cell_is_zero:
        mov r1, #0
        str r1, [r4]

        .move_onto_next_cell:
        add r4, #1

        ldr r1, buffer
        cmp r4, r1
        bcc .set_pixel_randomly

    bx lr



// cells (current)
.balign 4
cells:            .word    0x20000000
buffer:           .word    0x20001518
rand1:            .word     1140671485
rand2:            .word     12820163
seed:             .word     1557


////////////////////////////////////////
draw:
	mov		r0, =#0x1FFFFFFF		// index -> r0
	.nextCell:
	add		r0, #1
	



    bx lr


update:
    bx lr