
a: .word 0x200ffff0
b: .word _st
c: .word 0xaabbccdd

_st:
ldr r0, =c
ldr r0, [r0]
ldrh r0, [r0]
ldrb r0, [r0]
mov r1, #5
blx fn
mov r3, #4
mov r3, #4
mov r3, #4
mov r3, #4
mov r3, #4

.balign 4
fn:
push {r0, lr}
mov r0, #2
blx fn2
mov r0, #3
mov r0, #3
pop {r0, pc}

.balign 4
fn2:
push {r0, lr}
mov r0, #5
pop {r0, pc}







