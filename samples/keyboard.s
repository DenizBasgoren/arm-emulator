initial_sp:	.word	0x201FFFFC
reset_vector: .word _main
_main:	ldr		r0, =0x40010000       //LCD row register
                                      //0x40010004 LCD column register
		                              //0x40010008 LCD color register
		                              //0x4001000C LCD refresh register
		                              //0x40010010 LCD clean register
									  //0x40010020 Keyboard status register
		
		ldr     r1, =0xffff0000       //base color (fully opaque red in ARGB format)
		ldr     r4, =0xff000000       //base color (fully opaque black in ARGB format)
		movs    r3, #50
		movs	r5, #0
repeat:	ldr		r6, [r0, #0x20]		  //read keyboard status register
		movs    r2, #0x10
		str     r3, [r0]
		str		r5, [r0, #0x4]
		add     r5, r5, #1            //increment column index
		cmp     r5, #100
		beq     clear
		and     r6, r6, r2
		cmp     r6, #0
		beq     clear		
paint:	str     r1, [r0, #0x8]        //write the color to screen at current row and column using color register
		b       refresh
clear:	str		r4, [r0, #0x8]
		movs    r5, #0				  //clear col index
		str		r1, [r0, #0x10]       //clear screen
refresh:str		r1, [r0, #0xC]
		b		repeat
		
