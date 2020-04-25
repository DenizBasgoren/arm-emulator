initial_sp:	.word	0x10000
reset_vector: .word _main
// r0 = peripheral base address
// r1 = color
// r2 = y
// r3 = x
// r4 = max x
// r5 = ???
// r6 = 0..255
// r7 = 0..24
_main:	ldr		r0, =0x40010000       //LCD row register
                                      //0x40010004 LCD column register
		                              //0x40010008 LCD color register
		                              //0x4001000C LCD refresh register
		                              //0x40010010 LCD clean register				

		movs	r2, #0                //initialize row counter
		movs	r3, #0	              //initialize column counter		
		ldr     r4, =#320           //max column count	
       // hex 140
	    movs    r6, #0
		movs    r7, #0
		str		r2, [r0]              //update row register with first row count
		str     r3, [r0, #0x4]        //update column register with first column count
paint:	
		str     r1, [r0, #0x8]        //write the color to screen at current row and column using color register
		add     r3, r3, #1            //increment the column counter		
		cmp     r3, r4                //check if we have reached the end of current row
		bne     nc
		movs    r3, #0                //reset the column counter (move to the beginning of the row)
		add     r2, r2, #1            //increment the row counter		
		cmp     r2, #240                //check if we have reached the end of the screen
		bne     nr
		movs    r2, #0                //reset the row counter and column counter (move to the beginning of the screen)		
		movs    r3, #0                
		add     r6, r6, #1		
		cmp     r6, #255
		bne     label
		movs    r6, #0
        add     r7, r7, #8
label:	cmp     r7, #24
		bne     label2
		movs    r6, #0
		movs    r7, #0		
label2:	ldr     r1, =0xff000000       //base color (fully opaque black in ARGB format)
		movs    r5, r6
		lsl     r5, r5, r7
		orr     r1, r5            //change the color by r6
		str     r0, [r0, #0xC]        //refresh the screen
nr:     str     r2, [r0]		      //update the row register
nc:		str     r3, [r0, #0x4]        //update the column register	
		b       paint