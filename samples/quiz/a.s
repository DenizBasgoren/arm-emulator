
_start:
nop
mov r0, #5
blx func1
mov r1, #25
mov r1, r0
b done

func1:
mov r6, lr
add r6, #4
bx r6

done:
mov r7, #1
