

.section .data

junk1: .ascii "pen pineapple"
f1: .ascii "~!!~!!~!!~~!~~!~~!~~!~~!"
f2: .ascii "~!!~!!~!!~~!~~!~~!~~!~~!"
f3: .ascii "~!!~!!~!!~~!~~!~~!~~!~~!"
f4: .ascii "!!~!!~!!~!~!!~!!~!!~!!~!"
f5: .ascii "!!~!!~!!~!~!!~!!~!!~!!~!"
f6: .ascii "!!~!!~!!~!~!!~!!~!!~!!~!"
junk2: .ascii "apple pen"

.section .text

initial_sp:        .word    0x200FFFFF
reset_vector:     .word     _start

_start:

// put texture to slot 3
ldr r0, =#0x40000010		// base addr
mov r1, #8					// 8x6 pixel texture
mov r2, #6

strh r1, [r0, #20]			// mov 8 to texture_width
strh r2, [r0, #22]			// mov 6 to texture_height

// r1 and r2 now can be used again

ldr r1, =f1
str r1, [r0, #24]			// mov f1 to texture_data_addr
mov r2, #3 // 3 = rgb 
strb r2, [r0, #28]			//mov rgb to texture_channel
strb r2, [r0, #29]			//mov 3 to selected slot

strb r2, [r0, #2]			// call update_fn( )

// r1 and r2 now can be used again

// print onto screen
mov r1, #0
strh r1, [r0, #40]			// target_x = 0
strh r1, [r0, #42]			// target_y = 0
ldr r2, =#800				// r2: target_w
ldr r3, =#600				// r3: target_h
strh r2, [r0, #44]			// target_w = 800
strh r3, [r0, #46]			// target_h = 600
mov r1, #1					// mode: whole texture, resize (to full screen)
strb r1, [r0, #1]			// call draw_fn( mode )


busy_loop:
bkpt 0
b busy_loop

