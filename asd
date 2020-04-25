mov     r0, =arr
mov     r1, #0
loop1:
    mov     r2, #0
    loop2:
    set_cell(r1, r2, r0)
    add     r0, #1
    add     r2, #1
    jl      loop2, H
add     r1, #1
jl      loop1, W
bx      lr

set_cell:
    push    r0, r1, r2
    mov     r1, #0
    loop1:
        mov     r2, #0
        loop2:
        set_pixel(r1, r2, r0)
        add     r2, #1
        jl      loop2, #10
    add     r1, #1
    jl      loop1, #10
    pop    r0, r1, r2
    bx      lr
