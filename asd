    ldr		r0, =#0x20000000		// cell
	ldr		r4, =#0x20005460		// next
	ldr		r7, =#0x20005460		// next
    add     r0, #33
    add     r4, #33
    sub     r7, #33
    .check_neighbours:
        mov     r1, #0                  // neighbours = 0
        mov     r2, r0                  
        
        sub     r2, #33                 // goto top-left
        ldr     r3, [r2]
        add     r1, r2

        add     r2, #1                  // goto top
        ldr     r3, [r2]
        add     r1, r2   
        
        add     r2, #1                  // goto top-right
        ldr     r3, [r2]
        add     r1, r2  

        add     r2, #30                  // goto left
        ldr     r3, [r2]
        add     r1, r2  
        
        add     r2, #2                  // goto right
        ldr     r3, [r2]
        add     r1, r2  

        add     r2, #30                  // goto bot-left
        ldr     r3, [r2]
        add     r1, r2  

        add     r2, #1                  // goto bottom
        ldr     r3, [r2]
        add     r1, r2   
        
        add     r2, #1                  // goto bot-right
        ldr     r3, [r2]
        add     r1, r2  

        // r1 is neighbours
        ldr     r2, [r0]    // current
        cmp     r2, #1
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
        mov     r5, r2
        .out:
        str     r4, [r5]

        add     r0, #4
        add     r4, #4
        cmp     r0, r7
        blt     .check_neighbours