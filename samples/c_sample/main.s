	.cpu cortex-m0
	.eabi_attribute 20, 1
	.eabi_attribute 21, 1
	.eabi_attribute 23, 3
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 1
	.eabi_attribute 30, 6
	.eabi_attribute 34, 0
	.eabi_attribute 18, 4
	.file	"main.c"
	.text
	.align	1
	.global	onReset
	.arch armv6s-m
	.syntax unified
	.code	16
	.thumb_func
	.fpu softvfp
	.type	onReset, %function
onReset:
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #16
	add	r7, sp, #0
	movs	r3, #4
	str	r3, [r7, #12]
	movs	r3, #5
	str	r3, [r7, #8]
	ldr	r2, [r7, #12]
	ldr	r3, [r7, #8]
	adds	r3, r2, r3
	str	r3, [r7, #4]
	nop
	mov	sp, r7
	add	sp, sp, #16
	@ sp needed
	pop	{r7, pc}
	.size	onReset, .-onReset
	.ident	"GCC: (Arch Repository) 10.1.0"
