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
	.global	data
	.section	.rodata
	.align	2
.LC0:
	.ascii	"~!!~!!~!!~~!~~!~~!~~!~~!~!!~!!~!!~~!~~!~~!~~!~~!~!!"
	.ascii	"~!!~!!~~!~~!~~!~~!~~!!!~!!~!!~!~!!~!!~!!~!!~!!!~!!~"
	.ascii	"!!~!~!!~!!~!!~!!~!!!~!!~!!~!~!!~!!~!!~!!~!\000"
	.data
	.align	2
	.type	data, %object
	.size	data, 4
data:
	.word	.LC0
	.global	slot
	.bss
	.align	2
	.type	slot, %object
	.size	slot, 4
slot:
	.space	4
	.text
	.align	1
	.global	setColor
	.arch armv6s-m
	.syntax unified
	.code	16
	.thumb_func
	.fpu softvfp
	.type	setColor, %function
setColor:
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #16
	add	r7, sp, #0
	str	r0, [r7, #4]
	ldr	r3, .L2
	str	r3, [r7, #12]
	ldr	r3, [r7, #12]
	ldr	r2, [r7, #4]
	str	r2, [r3]
	nop
	mov	sp, r7
	add	sp, sp, #16
	@ sp needed
	pop	{r7, pc}
.L3:
	.align	2
.L2:
	.word	1073741856
	.size	setColor, .-setColor
	.align	1
	.global	setSrc
	.syntax unified
	.code	16
	.thumb_func
	.fpu softvfp
	.type	setSrc, %function
setSrc:
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r4, r5, r7, lr}
	sub	sp, sp, #16
	add	r7, sp, #0
	movs	r5, r0
	movs	r4, r1
	movs	r0, r2
	movs	r1, r3
	adds	r3, r7, #6
	adds	r2, r5, #0
	strh	r2, [r3]
	adds	r3, r7, #4
	adds	r2, r4, #0
	strh	r2, [r3]
	adds	r3, r7, #2
	adds	r2, r0, #0
	strh	r2, [r3]
	movs	r3, r7
	adds	r2, r1, #0
	strh	r2, [r3]
	ldr	r3, .L5
	str	r3, [r7, #12]
	ldr	r3, [r7, #12]
	adds	r2, r7, #6
	ldrh	r2, [r2]
	strh	r2, [r3]
	ldr	r3, [r7, #12]
	adds	r3, r3, #2
	adds	r2, r7, #4
	ldrh	r2, [r2]
	strh	r2, [r3]
	ldr	r3, [r7, #12]
	adds	r3, r3, #4
	adds	r2, r7, #2
	ldrh	r2, [r2]
	strh	r2, [r3]
	ldr	r3, [r7, #12]
	adds	r3, r3, #6
	movs	r2, r7
	ldrh	r2, [r2]
	strh	r2, [r3]
	nop
	mov	sp, r7
	add	sp, sp, #16
	@ sp needed
	pop	{r4, r5, r7, pc}
.L6:
	.align	2
.L5:
	.word	1073741872
	.size	setSrc, .-setSrc
	.align	1
	.global	setTarget
	.syntax unified
	.code	16
	.thumb_func
	.fpu softvfp
	.type	setTarget, %function
setTarget:
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r4, r5, r7, lr}
	sub	sp, sp, #16
	add	r7, sp, #0
	movs	r5, r0
	movs	r4, r1
	movs	r0, r2
	movs	r1, r3
	adds	r3, r7, #6
	adds	r2, r5, #0
	strh	r2, [r3]
	adds	r3, r7, #4
	adds	r2, r4, #0
	strh	r2, [r3]
	adds	r3, r7, #2
	adds	r2, r0, #0
	strh	r2, [r3]
	movs	r3, r7
	adds	r2, r1, #0
	strh	r2, [r3]
	ldr	r3, .L8
	str	r3, [r7, #12]
	ldr	r3, [r7, #12]
	adds	r2, r7, #6
	ldrh	r2, [r2]
	strh	r2, [r3]
	ldr	r3, [r7, #12]
	adds	r3, r3, #2
	adds	r2, r7, #4
	ldrh	r2, [r2]
	strh	r2, [r3]
	ldr	r3, [r7, #12]
	adds	r3, r3, #4
	adds	r2, r7, #2
	ldrh	r2, [r2]
	strh	r2, [r3]
	ldr	r3, [r7, #12]
	adds	r3, r3, #6
	movs	r2, r7
	ldrh	r2, [r2]
	strh	r2, [r3]
	nop
	mov	sp, r7
	add	sp, sp, #16
	@ sp needed
	pop	{r4, r5, r7, pc}
.L9:
	.align	2
.L8:
	.word	1073741880
	.size	setTarget, .-setTarget
	.align	1
	.global	loadTexture
	.syntax unified
	.code	16
	.thumb_func
	.fpu softvfp
	.type	loadTexture, %function
loadTexture:
	@ args = 0, pretend = 0, frame = 32
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #32
	add	r7, sp, #0
	str	r0, [r7, #12]
	str	r1, [r7, #8]
	str	r2, [r7, #4]
	ldr	r3, .L11
	str	r3, [r7, #28]
	ldr	r3, [r7, #8]
	sxth	r2, r3
	ldr	r3, [r7, #28]
	strh	r2, [r3]
	ldr	r3, [r7, #28]
	adds	r3, r3, #2
	ldr	r2, [r7, #4]
	sxth	r2, r2
	strh	r2, [r3]
	ldr	r3, .L11+4
	str	r3, [r7, #24]
	ldr	r2, [r7, #12]
	ldr	r3, [r7, #24]
	str	r2, [r3]
	ldr	r3, .L11+8
	str	r3, [r7, #20]
	ldr	r3, [r7, #20]
	movs	r2, #3
	strb	r2, [r3]
	nop
	mov	sp, r7
	add	sp, sp, #32
	@ sp needed
	pop	{r7, pc}
.L12:
	.align	2
.L11:
	.word	1073741860
	.word	1073741864
	.word	1073741868
	.size	loadTexture, .-loadTexture
	.align	1
	.global	_start
	.syntax unified
	.code	16
	.thumb_func
	.fpu softvfp
	.type	_start, %function
_start:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #8
	add	r7, sp, #0
	ldr	r3, .L18
	ldr	r3, [r3]
	movs	r2, #6
	movs	r1, #8
	movs	r0, r3
	bl	loadTexture
	movs	r3, #6
	movs	r2, #1
	movs	r1, #0
	movs	r0, #0
	bl	setSrc
	movs	r3, #150
	lsls	r3, r3, #2
	movs	r2, #50
	movs	r1, #0
	movs	r0, #0
	bl	setTarget
	movs	r3, #0
	str	r3, [r7, #4]
.L17:
	ldr	r3, .L18+4
	movs	r2, #0
	strb	r2, [r3]
	ldr	r3, [r7, #4]
	asrs	r3, r3, #6
	sxth	r0, r3
	movs	r3, #6
	movs	r2, #1
	movs	r1, #0
	bl	setSrc
	ldr	r3, [r7, #4]
	sxth	r0, r3
	movs	r3, #150
	lsls	r3, r3, #2
	movs	r2, #50
	movs	r1, #0
	bl	setTarget
	ldr	r3, .L18+8
	movs	r2, #3
	strb	r2, [r3]
	movs	r3, #0
	str	r3, [r7]
	b	.L14
.L15:
	ldr	r3, [r7]
	adds	r3, r3, #1
	str	r3, [r7]
.L14:
	ldr	r2, [r7]
	movs	r3, #128
	lsls	r3, r3, #10
	cmp	r2, r3
	blt	.L15
	ldr	r3, [r7, #4]
	adds	r3, r3, #1
	ldr	r2, .L18+12
	ands	r3, r2
	bpl	.L16
	subs	r3, r3, #1
	ldr	r2, .L18+16
	orrs	r3, r2
	adds	r3, r3, #1
.L16:
	str	r3, [r7, #4]
	b	.L17
.L19:
	.align	2
.L18:
	.word	data
	.word	1073741840
	.word	1073741841
	.word	-2147483137
	.word	-512
	.size	_start, .-_start
	.ident	"GCC: (Arch Repository) 10.1.0"
