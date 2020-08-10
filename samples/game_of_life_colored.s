
// youtube: https://youtu.be/_9IDZSsLR_g
// Deniz Bashgoren  github.com/denizBasgoren 040180902
// Cem Belentepe    github.com/theCCB 040180255

initial_sp:        .word    0x200FFFFF
reset_vector:     .word     _main

_main:
    bl init     // Calls the init function, which inits the cells to a random state

    .game_loop:
    bl draw     // Draw each call to the screen
    bl update   // Calculate the next state
    //.hword 0xde01 // fps counter
    b .game_loop



/////////////////////////////////////////////////
init:
    ldr r4, cells                        // cells

    // using the seed and random numbers, randomly fill the initial state of screen
    .set_pixel_randomly:
        ldr r0, seed                     // seed
        ldr r1, =#1140671485             // rand1
        ldr r2, =#12820163               // rand2

        mul r0, r1                        // r0 *= r1
        add r0, r2                        // r0 += r2

        ldr r1, =seed                     // r1 = seed
        str r0, [r1]                      // *r1 = r0

        cmp r0, #0                        // if r0 < 0
        ble .cell_is_zero

        // else cell_is_one
        mov r1, #1                      // r1 = 1
        str r1, [r4]                    // *r4 = r1

        b .move_onto_next_cell

        .cell_is_zero:
        mov r1, #0                      // r1 = 0
        str r1, [r4]                    // *r4 = r1

        .move_onto_next_cell:
        add r4, #4

        ldr r1, =0x20003000             // end point of the array
        cmp r4, r1                      // if not finished
        bcc .set_pixel_randomly
    bx lr

.balign 4
cells:            .word     0x20000000
seed:             .word     161600




////////////////////////////////////////
draw:
	ldr		r0, =#0x20000000		// index -> r0
    mov     r1, #0                  // i
	.each_row_in_cells:
        mov     r2, #0                  // j
        .each_colum_in_cells:
            // draw 5x5 pixel to position r3=r1*5, r4=r2*5
            mov     r5, #5      
            mov     r3, r1
            mul     r3, r5      // start index_row
            mov     r4, r2
            mul     r4, r5      // start index_col
            // (r3, r4) is the global pixel position

            mov     r8, r1      // save r1 and r2 to the r8 and r9
            mov     r9, r2
            
            ldr     r1, [r0]    // r1 is the element in array
            
            b pick_color
            color_set:

            ldr     r5, =0x40010000     // peripheral

            mov     r10, r4             // col_start

            mov     r6, #0              // outer loop variable
            .each_row:
                str     r3, [r5]        // set peripheral row target
                add     r3, #1          // row++
                mov     r4, r10
                
                mov     r7, #0          // inner loop variable
                .each_colum:
                    str     r4, [r5, #0x4]  // set peripheral col target                   
                    str r1, [r5, #0x8]      // write the color to the peripheral colour target

                    add     r4, #1          // col++
                    add     r7, #1          // increment inner loop
                    cmp     r7, #4
                    blt     .each_colum
                
                add     r6, #1          // increment outer loop
                cmp     r6, #4
                blt     .each_row

            mov     r1, r8              // load r1 and r2 from the r8 and r9
            mov     r2, r9

            add     r0, #4
            add     r2, #1
            cmp     r2, #64
            blt     .each_colum_in_cells
        add     r1, #1
        cmp     r1, #48
        blt     .each_row_in_cells

    ldr     r5, =0x40010000     // peripheral
    str     r5, [r5, #0xC]      // refresh the screen
    bx lr





////////////////////////////////////////////////
update:
	ldr		r0, =#0x20000000		// cell
	ldr		r4, =#0x20003000		// next

    mov     r6, #1                  // i = 1
    .check_neighbours_row:
        mov     r7, #1              // j = 1
        .check_neighbours_col:
            mov     r9, r0          // PUSH

            mov     r2, #64         
            mul     r2, r6          
            add     r2, r7          // r2 = 64*r6 + r7 -> index
            mov     r0, #4
            mul     r2, r0          // r2 = 4*(64*r6 + r7) -> RAM addr
            
            mov     r0, r9          // POP
            // r0 start, r2 current pos

            mov     r1, #0                  // neighbours = 0
            
            sub     r2, #200                 
            sub     r2, #60                  // goto top-left
            ldr     r3, [r0, r2]
            add     r1, r3                 // neighbours += *(r0+r2)

            add     r2, #4                  // goto top
            ldr     r3, [r0, r2]
            add     r1, r3   
            
            add     r2, #4                  // goto top-right
            ldr     r3, [r0, r2]
            add     r1, r3  

            add     r2, #248                 // goto left
            ldr     r3, [r0, r2]
            add     r1, r3  
            
            add     r2, #8                  // goto right
            ldr     r3, [r0, r2]
            add     r1, r3  

            add     r2, #248                  // goto bot-left
            ldr     r3, [r0, r2]
            add     r1, r3  

            add     r2, #4                  // goto bottom
            ldr     r3, [r0, r2]
            add     r1, r3   
            
            add     r2, #4                  // goto bot-right
            ldr     r3, [r0, r2]
            add     r1, r3  

            // r1 is neighbours
            sub     r2, #200
            sub     r2, #60
            ldr     r3, [r0, r2]    // current


            // r3 is current cell, r5 is its next state
            // 1-> alive, 0->dead
            
            // if (r3 == 1)
            // {
            //     if (r1 < 2){
            //         r5 = 0
            //     }
            //     else{
            //         if (r1 < 3){
            //             r5 = 1
            //         }
            //         else{
            //             r5 = 0
            //         }
            //     }
            // }
            // else {
            //     if (r1 == 3){
            //         r5 = 1
            //     }
            //     else{
            //         r5 = 0
            //     }
            // }

            cmp     r3, #1
            bne     .dead
            // is alive will be dead
            cmp     r1, #2
            blt     .alive
            cmp     r1, #3
            ble     .else
            .alive:
            mov     r5, #0    // next = 0
            b       .out
            .dead:
            cmp     r1, #3
            bne     .else
            mov     r5, #1
            b       .out
            .else:
            mov     r5, r3
            .out:
            str     r5, [r4, r2]

            add     r7, #1
            cmp     r7, #63
            blt     .check_neighbours_col
        add     r6, #1
        cmp     r6, #47
        blt     .check_neighbours_row



    // Copy from temp buffer to the main cells state space
	ldr		r0, =#0x20003000		// mem1 -> r0
	ldr		r1, =#0x20000000		// mem2 -> r1
    ldr		r2, =#0x20003000        // max of r1

    .copy_mem:
        ldr     r3, [r0]
        str     r3, [r1]
        add     r0, #4
        add     r1, #4
        cmp     r1, r2
        blt     .copy_mem
    
    bx lr




///////////////////////////
// expects r1=should be colored? r3=y, r4=x
///////////////////////////
pick_color:
    cmp r1, #1
    beq yes_make_colorful

    ldr r1, =0xFF000000
    b color_set

    yes_make_colorful:
    push { r0 }

    // r0 holds distance
    add r0, r3, r4
    
    // dist >= 256 ?
    lsr r1, r0, #8
    beq color_green
    
    // dist >= 512 ?
    lsr r1, r1, #1
    beq color_cyan

    color_blue:
    ldr r1, =0xFF0000FF
    b colored

    color_green:
    ldr r1, =0xFF00FF00
    add r1, r1, r0
    b colored

    color_cyan:
    push { r2 }
    neg r2, r0
    lsl r2, r2, #24
    lsr r2, r2, #16
    ldr r1, =0xFF0000FF
    orr r1, r1, r2
    pop { r2 }

    colored:
    pop { r0 }
    b color_set



