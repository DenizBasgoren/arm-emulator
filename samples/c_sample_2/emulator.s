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
	.file	"emulator.c"
	.text
	.global	rom
	.bss
	.align	2
	.type	rom, %object
	.size	rom, 2097152
rom:
	.space	2097152
	.global	ram
	.align	2
	.type	ram, %object
	.size	ram, 1048576
ram:
	.space	1048576
	.global	cpu
	.align	2
	.type	cpu, %object
	.size	cpu, 68
cpu:
	.space	68
	.global	lastTime
	.align	2
	.type	lastTime, %object
	.size	lastTime, 4
lastTime:
	.space	4
	.global	n_inst_after_fps
	.align	2
	.type	n_inst_after_fps, %object
	.size	n_inst_after_fps, 4
n_inst_after_fps:
	.space	4
	.section	.rodata
	.align	2
.LC0:
	.ascii	"Usage: emulator path/to/arm_assembly.s [, -debug ]\000"
	.align	2
.LC8:
	.ascii	"-debug\000"
	.text
	.align	1
	.global	main
	.arch armv6s-m
	.syntax unified
	.code	16
	.thumb_func
	.fpu softvfp
	.type	main, %function
main:
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #16
	add	r7, sp, #0
	str	r0, [r7, #4]
	str	r1, [r7]
	ldr	r3, [r7, #4]
	cmp	r3, #1
	bgt	.L2
	ldr	r3, .L12
	movs	r0, r3
	bl	puts
	movs	r3, #1
	b	.L3
.L2:
	movs	r3, #128
	lsls	r2, r3, #14
	ldr	r3, .L12+4
	movs	r1, #255
	movs	r0, r3
	bl	memset
	movs	r3, #128
	lsls	r2, r3, #13
	ldr	r3, .L12+8
	movs	r1, #255
	movs	r0, r3
	bl	memset
	bl	system_init
	ldr	r3, [r7]
	adds	r3, r3, #4
	ldr	r3, [r3]
	ldr	r2, .L12+8
	ldr	r1, .L12+4
	movs	r0, r3
	bl	load_program
	subs	r3, r0, #0
	bge	.L4
	movs	r3, #1
	b	.L3
.L4:
	ldr	r3, .L12+12
	movs	r1, r3
	movs	r0, #2
	bl	signal
	ldr	r3, .L12+16
	movs	r2, #0
	str	r2, [r3, #64]
	ldr	r3, .L12+16
	movs	r2, #1
	rsbs	r2, r2, #0
	str	r2, [r3, #56]
	ldr	r3, .L12+20
	movs	r1, #0
	movs	r0, r3
	bl	load_from_memory
	ldr	r3, .L12+24
	movs	r1, #4
	movs	r0, r3
	bl	load_from_memory
	ldr	r3, .L12+16
	ldr	r3, [r3, #60]
	adds	r2, r3, #2
	ldr	r3, .L12+16
	str	r2, [r3, #60]
	ldr	r3, [r7, #4]
	cmp	r3, #3
	bne	.L5
	ldr	r3, [r7]
	adds	r3, r3, #8
	ldr	r3, [r3]
	ldr	r2, .L12+28
	movs	r1, r2
	movs	r0, r3
	bl	strcmp
	subs	r3, r0, #0
	bne	.L5
	movs	r3, #1
	b	.L6
.L5:
	movs	r3, #0
.L6:
	str	r3, [r7, #12]
.L9:
	ldr	r3, [r7, #12]
	movs	r0, r3
	bl	execute_next
	subs	r3, r0, #0
	bne	.L11
	b	.L9
.L11:
	nop
	bl	system_deinit
	movs	r3, #0
.L3:
	movs	r0, r3
	mov	sp, r7
	add	sp, sp, #16
	@ sp needed
	pop	{r7, pc}
.L13:
	.align	2
.L12:
	.word	.LC0
	.word	rom
	.word	ram
	.word	sigint_handler
	.word	cpu
	.word	cpu+52
	.word	cpu+60
	.word	.LC8
	.size	main, .-main
	.align	1
	.global	update_nz_flags
	.syntax unified
	.code	16
	.thumb_func
	.fpu softvfp
	.type	update_nz_flags, %function
update_nz_flags:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #8
	add	r7, sp, #0
	str	r0, [r7, #4]
	ldr	r3, [r7, #4]
	cmp	r3, #0
	bne	.L15
	ldr	r3, .L20
	ldr	r3, [r3, #64]
	movs	r2, #128
	lsls	r2, r2, #23
	orrs	r2, r3
	ldr	r3, .L20
	str	r2, [r3, #64]
	b	.L16
.L15:
	ldr	r3, .L20
	ldr	r3, [r3, #64]
	ldr	r2, .L20+4
	ands	r2, r3
	ldr	r3, .L20
	str	r2, [r3, #64]
.L16:
	ldr	r3, [r7, #4]
	cmp	r3, #0
	bge	.L17
	ldr	r3, .L20
	ldr	r3, [r3, #64]
	movs	r2, #128
	lsls	r2, r2, #24
	orrs	r2, r3
	ldr	r3, .L20
	str	r2, [r3, #64]
	b	.L19
.L17:
	ldr	r3, .L20
	ldr	r3, [r3, #64]
	lsls	r3, r3, #1
	lsrs	r2, r3, #1
	ldr	r3, .L20
	str	r2, [r3, #64]
.L19:
	nop
	mov	sp, r7
	add	sp, sp, #8
	@ sp needed
	pop	{r7, pc}
.L21:
	.align	2
.L20:
	.word	cpu
	.word	-1073741825
	.size	update_nz_flags, .-update_nz_flags
	.align	1
	.global	update_vc_flags_in_addition
	.syntax unified
	.code	16
	.thumb_func
	.fpu softvfp
	.type	update_vc_flags_in_addition, %function
update_vc_flags_in_addition:
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #16
	add	r7, sp, #0
	str	r0, [r7, #12]
	str	r1, [r7, #8]
	str	r2, [r7, #4]
	ldr	r3, [r7, #12]
	cmp	r3, #0
	ble	.L23
	ldr	r3, [r7, #8]
	cmp	r3, #0
	ble	.L23
	ldr	r3, [r7, #4]
	cmp	r3, #0
	bge	.L23
	ldr	r3, .L29
	ldr	r3, [r3, #64]
	movs	r2, #128
	lsls	r2, r2, #21
	orrs	r2, r3
	ldr	r3, .L29
	str	r2, [r3, #64]
	b	.L24
.L23:
	ldr	r3, [r7, #12]
	cmp	r3, #0
	bge	.L25
	ldr	r3, [r7, #8]
	cmp	r3, #0
	bge	.L25
	ldr	r3, [r7, #4]
	cmp	r3, #0
	ble	.L25
	ldr	r3, .L29
	ldr	r3, [r3, #64]
	movs	r2, #128
	lsls	r2, r2, #21
	orrs	r2, r3
	ldr	r3, .L29
	str	r2, [r3, #64]
	b	.L24
.L25:
	ldr	r3, .L29
	ldr	r3, [r3, #64]
	ldr	r2, .L29+4
	ands	r2, r3
	ldr	r3, .L29
	str	r2, [r3, #64]
.L24:
	ldr	r3, [r7, #12]
	mvns	r2, r3
	ldr	r3, [r7, #8]
	cmp	r2, r3
	bcs	.L26
	ldr	r3, .L29
	ldr	r3, [r3, #64]
	movs	r2, #128
	lsls	r2, r2, #22
	orrs	r2, r3
	ldr	r3, .L29
	str	r2, [r3, #64]
	b	.L28
.L26:
	ldr	r3, .L29
	ldr	r3, [r3, #64]
	ldr	r2, .L29+8
	ands	r2, r3
	ldr	r3, .L29
	str	r2, [r3, #64]
.L28:
	nop
	mov	sp, r7
	add	sp, sp, #16
	@ sp needed
	pop	{r7, pc}
.L30:
	.align	2
.L29:
	.word	cpu
	.word	-268435457
	.word	-536870913
	.size	update_vc_flags_in_addition, .-update_vc_flags_in_addition
	.align	1
	.global	update_vc_flags_in_subtraction
	.syntax unified
	.code	16
	.thumb_func
	.fpu softvfp
	.type	update_vc_flags_in_subtraction, %function
update_vc_flags_in_subtraction:
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #16
	add	r7, sp, #0
	str	r0, [r7, #12]
	str	r1, [r7, #8]
	str	r2, [r7, #4]
	ldr	r3, [r7, #12]
	cmp	r3, #0
	bge	.L32
	ldr	r3, [r7, #8]
	cmp	r3, #0
	ble	.L32
	ldr	r3, [r7, #4]
	cmp	r3, #0
	ble	.L32
	ldr	r3, .L38
	ldr	r3, [r3, #64]
	movs	r2, #128
	lsls	r2, r2, #21
	orrs	r2, r3
	ldr	r3, .L38
	str	r2, [r3, #64]
	b	.L33
.L32:
	ldr	r3, [r7, #12]
	cmp	r3, #0
	ble	.L34
	ldr	r3, [r7, #8]
	cmp	r3, #0
	bge	.L34
	ldr	r3, [r7, #4]
	cmp	r3, #0
	bge	.L34
	ldr	r3, .L38
	ldr	r3, [r3, #64]
	movs	r2, #128
	lsls	r2, r2, #21
	orrs	r2, r3
	ldr	r3, .L38
	str	r2, [r3, #64]
	b	.L33
.L34:
	ldr	r3, .L38
	ldr	r3, [r3, #64]
	ldr	r2, .L38+4
	ands	r2, r3
	ldr	r3, .L38
	str	r2, [r3, #64]
.L33:
	ldr	r2, [r7, #12]
	ldr	r3, [r7, #8]
	subs	r3, r2, r3
	bpl	.L35
	ldr	r3, .L38
	ldr	r3, [r3, #64]
	ldr	r2, .L38+8
	ands	r2, r3
	ldr	r3, .L38
	str	r2, [r3, #64]
	b	.L37
.L35:
	ldr	r3, .L38
	ldr	r3, [r3, #64]
	movs	r2, #128
	lsls	r2, r2, #22
	orrs	r2, r3
	ldr	r3, .L38
	str	r2, [r3, #64]
.L37:
	nop
	mov	sp, r7
	add	sp, sp, #16
	@ sp needed
	pop	{r7, pc}
.L39:
	.align	2
.L38:
	.word	cpu
	.word	-268435457
	.word	-536870913
	.size	update_vc_flags_in_subtraction, .-update_vc_flags_in_subtraction
	.section	.rodata
	.align	2
.LC13:
	.ascii	"\012Termination\000"
	.text
	.align	1
	.global	sigint_handler
	.syntax unified
	.code	16
	.thumb_func
	.fpu softvfp
	.type	sigint_handler, %function
sigint_handler:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	add	r7, sp, #0
	ldr	r3, .L41
	movs	r0, r3
	bl	puts
	movs	r0, #0
	bl	exit
.L42:
	.align	2
.L41:
	.word	.LC13
	.size	sigint_handler, .-sigint_handler
	.align	1
	.global	store_to_memory
	.syntax unified
	.code	16
	.thumb_func
	.fpu softvfp
	.type	store_to_memory, %function
store_to_memory:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #8
	add	r7, sp, #0
	str	r0, [r7, #4]
	str	r1, [r7]
	ldr	r3, [r7]
	movs	r2, #3
	bics	r3, r2
	str	r3, [r7]
	ldr	r2, [r7]
	movs	r3, #128
	lsls	r3, r3, #22
	cmp	r2, r3
	bcs	.L44
	ldr	r2, [r7]
	ldr	r3, .L48
	adds	r3, r2, r3
	ldr	r2, [r7, #4]
	str	r2, [r3]
	b	.L47
.L44:
	ldr	r2, [r7]
	movs	r3, #128
	lsls	r3, r3, #22
	cmp	r2, r3
	bcc	.L46
	ldr	r2, [r7]
	movs	r3, #128
	lsls	r3, r3, #23
	cmp	r2, r3
	bcs	.L46
	ldr	r3, [r7]
	movs	r2, #224
	lsls	r2, r2, #24
	adds	r2, r3, r2
	ldr	r3, .L48+4
	adds	r3, r2, r3
	ldr	r2, [r7, #4]
	str	r2, [r3]
	b	.L47
.L46:
	ldr	r2, [r7]
	movs	r3, #128
	lsls	r3, r3, #23
	cmp	r2, r3
	bcc	.L47
	ldr	r2, [r7]
	movs	r3, #192
	lsls	r3, r3, #23
	cmp	r2, r3
	bcs	.L47
	ldr	r2, [r7, #4]
	ldr	r3, [r7]
	movs	r1, r2
	movs	r0, r3
	bl	peripheral_write
.L47:
	nop
	mov	sp, r7
	add	sp, sp, #8
	@ sp needed
	pop	{r7, pc}
.L49:
	.align	2
.L48:
	.word	rom
	.word	ram
	.size	store_to_memory, .-store_to_memory
	.align	1
	.global	load_from_memory
	.syntax unified
	.code	16
	.thumb_func
	.fpu softvfp
	.type	load_from_memory, %function
load_from_memory:
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #16
	add	r7, sp, #0
	str	r0, [r7, #4]
	str	r1, [r7]
	ldr	r3, [r7]
	movs	r2, #3
	bics	r3, r2
	str	r3, [r7]
	ldr	r2, [r7]
	movs	r3, #128
	lsls	r3, r3, #22
	cmp	r2, r3
	bcs	.L51
	ldr	r3, [r7]
	str	r3, [r7, #12]
	ldr	r2, [r7, #12]
	ldr	r3, .L55
	adds	r3, r2, r3
	ldr	r2, [r3]
	ldr	r3, [r7, #4]
	str	r2, [r3]
	b	.L54
.L51:
	ldr	r2, [r7]
	movs	r3, #128
	lsls	r3, r3, #22
	cmp	r2, r3
	bcc	.L53
	ldr	r2, [r7]
	movs	r3, #128
	lsls	r3, r3, #23
	cmp	r2, r3
	bcs	.L53
	ldr	r3, [r7]
	movs	r2, #224
	lsls	r2, r2, #24
	mov	ip, r2
	add	r3, r3, ip
	str	r3, [r7, #12]
	ldr	r2, [r7, #12]
	ldr	r3, .L55+4
	adds	r3, r2, r3
	ldr	r2, [r3]
	ldr	r3, [r7, #4]
	str	r2, [r3]
	b	.L54
.L53:
	ldr	r2, [r7]
	movs	r3, #128
	lsls	r3, r3, #23
	cmp	r2, r3
	bcc	.L54
	ldr	r2, [r7]
	movs	r3, #192
	lsls	r3, r3, #23
	cmp	r2, r3
	bcs	.L54
	ldr	r2, [r7, #4]
	ldr	r3, [r7]
	movs	r1, r2
	movs	r0, r3
	bl	peripheral_read
.L54:
	nop
	mov	sp, r7
	add	sp, sp, #16
	@ sp needed
	pop	{r7, pc}
.L56:
	.align	2
.L55:
	.word	rom
	.word	ram
	.size	load_from_memory, .-load_from_memory
	.section	.rodata
	.align	2
.LC21:
	.ascii	"\012\012Instruction 0x%08X 0x%04X\012\000"
	.global	__aeabi_ui2d
	.global	__aeabi_ddiv
	.align	2
.LC25:
	.ascii	"FPS: %f\012\000"
	.align	2
.LC30:
	.ascii	"BLX: previous instruction is not a branch prefix in"
	.ascii	"struction 0x%08X  0x%04X\012\000"
	.align	2
.LC32:
	.ascii	"invalid instruction 0x%08X 0x%04X\012\000"
	.text
	.align	1
	.global	execute_next
	.syntax unified
	.code	16
	.thumb_func
	.fpu softvfp
	.type	execute_next, %function
execute_next:
	@ args = 0, pretend = 0, frame = 712
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r4, r5, r6, r7, lr}
	ldr	r4, .L194
	add	sp, sp, r4
	add	r7, sp, #0
	str	r0, [r7, #4]
	ldr	r3, .L194+4
	ldr	r3, [r3, #60]
	subs	r3, r3, #2
	ldr	r2, .L194+8
	ldrb	r3, [r2, r3]
	sxth	r2, r3
	ldr	r3, .L194+4
	ldr	r3, [r3, #60]
	subs	r3, r3, #1
	ldr	r1, .L194+8
	ldrb	r3, [r1, r3]
	lsls	r3, r3, #8
	sxth	r3, r3
	orrs	r3, r2
	sxth	r2, r3
	ldr	r0, .L194+12
	adds	r3, r7, r0
	strh	r2, [r3]
	ldr	r3, .L194+4
	ldr	r3, [r3, #60]
	adds	r2, r3, #2
	ldr	r3, .L194+4
	str	r2, [r3, #60]
	ldr	r3, [r7, #4]
	cmp	r3, #0
	beq	.L58
	ldr	r3, .L194+4
	ldr	r3, [r3, #60]
	subs	r1, r3, #4
	adds	r3, r7, r0
	ldrh	r2, [r3]
	ldr	r3, .L194+16
	movs	r0, r3
	bl	printf
	bl	debug_dialog
.L58:
	ldr	r3, .L194+12
	adds	r3, r7, r3
	ldrh	r2, [r3]
	movs	r3, #222
	lsls	r3, r3, #8
	cmp	r2, r3
	bne	.L59
	bl	debug_dialog
	movs	r3, #0
	bl	.L60	@ far jump
.L59:
	ldr	r3, .L194+12
	adds	r3, r7, r3
	ldrh	r3, [r3]
	ldr	r2, .L194+20
	cmp	r3, r2
	bne	.L61
	ldr	r3, .L194+24
	ldr	r3, [r3]
	adds	r2, r3, #1
	ldr	r3, .L194+24
	str	r2, [r3]
	ldr	r3, .L194+24
	ldr	r3, [r3]
	cmp	r3, #59
	bls	.L62
	bl	clock
	movs	r3, r0
	str	r3, [r7, #20]
	ldr	r3, .L194+28
	ldr	r3, [r3]
	ldr	r2, [r7, #20]
	subs	r3, r2, r3
	movs	r0, r3
	bl	__aeabi_ui2d
	movs	r2, #0
	ldr	r3, .L194+32
	bl	__aeabi_ddiv
	movs	r2, r0
	movs	r3, r1
	str	r2, [r7, #8]
	str	r3, [r7, #12]
	ldr	r3, .L194+28
	ldr	r2, [r7, #20]
	str	r2, [r3]
	ldr	r2, [r7, #8]
	ldr	r3, [r7, #12]
	movs	r0, #0
	ldr	r1, .L194+36
	bl	__aeabi_ddiv
	movs	r2, r0
	movs	r3, r1
	ldr	r1, .L194+40
	movs	r0, r1
	bl	printf
	ldr	r3, .L194+24
	movs	r2, #0
	str	r2, [r3]
.L62:
	movs	r3, #0
	bl	.L60	@ far jump
.L61:
	ldr	r0, .L194+12
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #11
	uxth	r3, r3
	movs	r2, r3
	movs	r3, #31
	ands	r3, r2
	beq	.LCB720
	b	.L63	@long jump
.LCB720:
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #6
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r3, .L194+44
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #31
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #3
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r3, .L194+48
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r0
	ldrh	r3, [r3]
	uxtb	r2, r3
	ldr	r3, .L194+52
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	ldr	r3, .L194+48
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	ldr	r3, .L194+4
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	str	r3, [r7, #32]
	ldr	r3, .L194+44
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r3, [r3]
	movs	r2, #31
	subs	r3, r2, r3
	ldr	r2, [r7, #32]
	lsrs	r2, r2, r3
	movs	r3, r2
	movs	r2, r3
	movs	r3, #1
	ands	r3, r2
	str	r3, [r7, #28]
	ldr	r3, .L194+44
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r3, [r3]
	ldr	r2, [r7, #32]
	lsls	r2, r2, r3
	movs	r3, r2
	str	r3, [r7, #24]
	ldr	r3, .L194+52
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	ldr	r1, [r7, #24]
	ldr	r3, .L194+4
	lsls	r2, r2, #2
	str	r1, [r2, r3]
	ldr	r3, [r7, #24]
	movs	r0, r3
	bl	update_nz_flags
	ldr	r3, .L194+44
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r3, [r3]
	cmp	r3, #0
	beq	.L64
	ldr	r3, [r7, #28]
	cmp	r3, #0
	beq	.L65
	ldr	r3, .L194+4
	ldr	r3, [r3, #64]
	movs	r2, #128
	lsls	r2, r2, #22
	orrs	r2, r3
	ldr	r3, .L194+4
	str	r2, [r3, #64]
	b	.L64
.L65:
	ldr	r3, .L194+4
	ldr	r3, [r3, #64]
	ldr	r2, .L194+56
	ands	r2, r3
	ldr	r3, .L194+4
	str	r2, [r3, #64]
.L64:
	movs	r3, #0
	bl	.L60	@ far jump
.L63:
	ldr	r0, .L194+12
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #11
	uxth	r3, r3
	movs	r2, r3
	movs	r3, #31
	ands	r3, r2
	cmp	r3, #1
	beq	.LCB861
	b	.L66	@long jump
.LCB861:
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #6
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r3, .L194+60
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #31
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #3
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r3, .L194+64
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r0
	ldrh	r3, [r3]
	uxtb	r2, r3
	ldr	r3, .L194+68
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	ldr	r3, .L194+64
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	ldr	r3, .L194+4
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	str	r3, [r7, #48]
	ldr	r3, .L194+60
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r3, [r3]
	cmp	r3, #0
	beq	.L67
	ldr	r3, .L194+60
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r3, [r3]
	subs	r3, r3, #1
	ldr	r2, [r7, #48]
	lsrs	r2, r2, r3
	movs	r3, r2
	movs	r2, r3
	movs	r3, #1
	ands	r3, r2
	str	r3, [r7, #44]
	ldr	r3, [r7, #44]
	cmp	r3, #0
	beq	.L68
	ldr	r3, .L194+4
	ldr	r3, [r3, #64]
	movs	r2, #128
	lsls	r2, r2, #22
	orrs	r2, r3
	ldr	r3, .L194+4
	str	r2, [r3, #64]
	b	.L67
.L68:
	ldr	r3, .L194+4
	ldr	r3, [r3, #64]
	ldr	r2, .L194+56
	ands	r2, r3
	ldr	r3, .L194+4
	str	r2, [r3, #64]
.L67:
	ldr	r3, .L194+60
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r3, [r3]
	ldr	r2, [r7, #48]
	lsrs	r2, r2, r3
	movs	r3, r2
	str	r3, [r7, #40]
	ldr	r3, .L194+68
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	ldr	r1, [r7, #40]
	ldr	r3, .L194+4
	lsls	r2, r2, #2
	str	r1, [r2, r3]
	ldr	r3, [r7, #40]
	movs	r0, r3
	bl	update_nz_flags
	movs	r3, #0
	bl	.L60	@ far jump
.L195:
	.align	2
.L194:
	.word	-716
	.word	cpu
	.word	rom
	.word	678
	.word	.LC21
	.word	56833
	.word	n_inst_after_fps
	.word	lastTime
	.word	1079574528
	.word	1078853632
	.word	.LC25
	.word	-673
	.word	-674
	.word	-675
	.word	-536870913
	.word	-657
	.word	-658
	.word	-659
.L66:
	ldr	r0, .L196
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #11
	uxth	r3, r3
	movs	r2, r3
	movs	r3, #31
	ands	r3, r2
	cmp	r3, #2
	beq	.LCB1024
	b	.L69	@long jump
.LCB1024:
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #6
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r3, .L196+4
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #31
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #3
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r3, .L196+8
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r0
	ldrh	r3, [r3]
	uxtb	r2, r3
	ldr	r3, .L196+12
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	ldr	r3, .L196+8
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	ldr	r3, .L196+16
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	str	r3, [r7, #64]
	ldr	r3, .L196+4
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r3, [r3]
	movs	r2, #31
	subs	r3, r2, r3
	ldr	r2, [r7, #64]
	asrs	r2, r2, r3
	movs	r3, r2
	movs	r2, #1
	ands	r3, r2
	str	r3, [r7, #60]
	ldr	r3, .L196+4
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r3, [r3]
	ldr	r2, [r7, #64]
	asrs	r2, r2, r3
	movs	r3, r2
	str	r3, [r7, #56]
	ldr	r3, .L196+12
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	ldr	r3, .L196+16
	lsls	r2, r2, #2
	ldr	r1, [r7, #56]
	str	r1, [r2, r3]
	ldr	r3, [r7, #56]
	movs	r0, r3
	bl	update_nz_flags
	ldr	r3, .L196+4
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r3, [r3]
	cmp	r3, #0
	beq	.L70
	ldr	r3, [r7, #60]
	cmp	r3, #0
	beq	.L71
	ldr	r3, .L196+16
	ldr	r3, [r3, #64]
	movs	r2, #128
	lsls	r2, r2, #22
	orrs	r2, r3
	ldr	r3, .L196+16
	str	r2, [r3, #64]
	b	.L70
.L71:
	ldr	r3, .L196+16
	ldr	r3, [r3, #64]
	ldr	r2, .L196+20
	ands	r2, r3
	ldr	r3, .L196+16
	str	r2, [r3, #64]
.L70:
	movs	r3, #0
	bl	.L60	@ far jump
.L69:
	ldr	r0, .L196
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #9
	uxth	r3, r3
	movs	r2, r3
	movs	r3, #127
	ands	r3, r2
	cmp	r3, #12
	bne	.L72
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #6
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r3, .L196+24
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #3
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r3, .L196+28
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r0
	ldrh	r3, [r3]
	uxtb	r2, r3
	ldr	r3, .L196+32
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	ldr	r3, .L196+28
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	ldr	r3, .L196+16
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	str	r3, [r7, #80]
	ldr	r3, .L196+24
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	ldr	r3, .L196+16
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	str	r3, [r7, #76]
	ldr	r2, [r7, #80]
	ldr	r3, [r7, #76]
	adds	r3, r2, r3
	str	r3, [r7, #72]
	ldr	r3, .L196+32
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	ldr	r1, [r7, #72]
	ldr	r3, .L196+16
	lsls	r2, r2, #2
	str	r1, [r2, r3]
	ldr	r3, [r7, #72]
	movs	r0, r3
	bl	update_nz_flags
	ldr	r3, [r7, #80]
	ldr	r1, [r7, #76]
	ldr	r2, [r7, #72]
	movs	r0, r3
	bl	update_vc_flags_in_addition
	movs	r3, #0
	bl	.L60	@ far jump
.L72:
	ldr	r0, .L196
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #9
	uxth	r3, r3
	movs	r2, r3
	movs	r3, #127
	ands	r3, r2
	cmp	r3, #13
	bne	.L73
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #6
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r3, .L196+36
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #3
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r3, .L196+40
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r0
	ldrh	r3, [r3]
	uxtb	r2, r3
	ldr	r3, .L196+44
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	ldr	r3, .L196+40
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	ldr	r3, .L196+16
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	str	r3, [r7, #96]
	ldr	r3, .L196+36
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	ldr	r3, .L196+16
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	str	r3, [r7, #92]
	ldr	r2, [r7, #96]
	ldr	r3, [r7, #92]
	subs	r3, r2, r3
	str	r3, [r7, #88]
	ldr	r3, .L196+44
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	ldr	r1, [r7, #88]
	ldr	r3, .L196+16
	lsls	r2, r2, #2
	str	r1, [r2, r3]
	ldr	r3, [r7, #88]
	movs	r0, r3
	bl	update_nz_flags
	ldr	r3, [r7, #96]
	ldr	r1, [r7, #92]
	ldr	r2, [r7, #88]
	movs	r0, r3
	bl	update_vc_flags_in_subtraction
	movs	r3, #0
	bl	.L60	@ far jump
.L73:
	ldr	r0, .L196
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #9
	uxth	r3, r3
	movs	r2, r3
	movs	r3, #127
	ands	r3, r2
	cmp	r3, #14
	bne	.L74
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #6
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r3, .L196+48
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #3
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r3, .L196+52
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r0
	ldrh	r3, [r3]
	uxtb	r2, r3
	ldr	r3, .L196+56
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	ldr	r3, .L196+52
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	ldr	r3, .L196+16
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	str	r3, [r7, #108]
	ldr	r3, .L196+48
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r3, [r3]
	ldr	r2, [r7, #108]
	adds	r3, r2, r3
	str	r3, [r7, #104]
	ldr	r3, .L196+56
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	ldr	r1, [r7, #104]
	ldr	r3, .L196+16
	lsls	r2, r2, #2
	str	r1, [r2, r3]
	ldr	r3, [r7, #104]
	movs	r0, r3
	bl	update_nz_flags
	ldr	r0, [r7, #108]
	ldr	r3, .L196+48
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r3, [r3]
	ldr	r2, [r7, #104]
	movs	r1, r3
	bl	update_vc_flags_in_addition
	movs	r3, #0
	bl	.L60	@ far jump
.L197:
	.align	2
.L196:
	.word	678
	.word	-641
	.word	-642
	.word	-643
	.word	cpu
	.word	-536870913
	.word	-625
	.word	-626
	.word	-627
	.word	-609
	.word	-610
	.word	-611
	.word	-597
	.word	-598
	.word	-599
.L74:
	ldr	r0, .L198
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #9
	uxth	r3, r3
	movs	r2, r3
	movs	r3, #127
	ands	r3, r2
	cmp	r3, #15
	bne	.L75
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #6
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r3, .L198+4
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #3
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r3, .L198+8
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r0
	ldrh	r3, [r3]
	uxtb	r2, r3
	ldr	r3, .L198+12
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	ldr	r3, .L198+8
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	ldr	r3, .L198+16
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	str	r3, [r7, #120]
	ldr	r3, .L198+4
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r3, [r3]
	ldr	r2, [r7, #120]
	subs	r3, r2, r3
	str	r3, [r7, #116]
	ldr	r3, .L198+12
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	ldr	r1, [r7, #116]
	ldr	r3, .L198+16
	lsls	r2, r2, #2
	str	r1, [r2, r3]
	ldr	r3, [r7, #116]
	movs	r0, r3
	bl	update_nz_flags
	ldr	r0, [r7, #120]
	ldr	r3, .L198+4
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r3, [r3]
	ldr	r2, [r7, #116]
	movs	r1, r3
	bl	update_vc_flags_in_subtraction
	movs	r3, #0
	bl	.L60	@ far jump
.L75:
	ldr	r0, .L198
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #11
	uxth	r3, r3
	movs	r2, r3
	movs	r3, #31
	ands	r3, r2
	cmp	r3, #4
	bne	.L76
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #8
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r3, .L198+20
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	ldr	r3, .L198+24
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	adds	r2, r7, r0
	ldrh	r2, [r2]
	strb	r2, [r3]
	ldr	r3, .L198+20
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	ldr	r3, .L198+24
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r1, [r3]
	ldr	r3, .L198+16
	lsls	r2, r2, #2
	str	r1, [r2, r3]
	ldr	r3, .L198+20
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	ldr	r3, .L198+16
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r0, r3
	bl	update_nz_flags
	movs	r3, #0
	bl	.L60	@ far jump
.L76:
	ldr	r0, .L198
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #11
	uxth	r3, r3
	movs	r2, r3
	movs	r3, #31
	ands	r3, r2
	cmp	r3, #5
	bne	.L77
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #8
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r3, .L198+28
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	ldr	r3, .L198+32
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	adds	r2, r7, r0
	ldrh	r2, [r2]
	strb	r2, [r3]
	ldr	r3, .L198+28
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	ldr	r3, .L198+16
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r4, #136
	adds	r2, r7, r4
	str	r3, [r2]
	ldr	r3, .L198+32
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r3, [r3]
	adds	r2, r7, r4
	ldr	r2, [r2]
	subs	r3, r2, r3
	movs	r5, #132
	adds	r2, r7, r5
	str	r3, [r2]
	adds	r3, r7, r5
	ldr	r3, [r3]
	movs	r0, r3
	bl	update_nz_flags
	adds	r3, r7, r4
	ldr	r0, [r3]
	ldr	r3, .L198+32
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r3, [r3]
	adds	r2, r7, r5
	ldr	r2, [r2]
	movs	r1, r3
	bl	update_vc_flags_in_subtraction
	movs	r3, #0
	bl	.L60	@ far jump
.L77:
	ldr	r0, .L198
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #11
	uxth	r3, r3
	movs	r2, r3
	movs	r3, #31
	ands	r3, r2
	cmp	r3, #6
	bne	.L78
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #8
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r3, .L198+36
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	ldr	r3, .L198+40
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	adds	r2, r7, r0
	ldrh	r2, [r2]
	strb	r2, [r3]
	ldr	r3, .L198+36
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	ldr	r3, .L198+16
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r5, #148
	adds	r2, r7, r5
	str	r3, [r2]
	ldr	r3, .L198+40
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r3, [r3]
	adds	r2, r7, r5
	ldr	r2, [r2]
	adds	r3, r2, r3
	movs	r4, #144
	adds	r2, r7, r4
	str	r3, [r2]
	ldr	r3, .L198+36
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	adds	r3, r7, r4
	ldr	r1, [r3]
	ldr	r3, .L198+16
	lsls	r2, r2, #2
	str	r1, [r2, r3]
	adds	r3, r7, r4
	ldr	r3, [r3]
	movs	r0, r3
	bl	update_nz_flags
	adds	r3, r7, r5
	ldr	r0, [r3]
	ldr	r3, .L198+40
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r3, [r3]
	adds	r2, r7, r4
	ldr	r2, [r2]
	movs	r1, r3
	bl	update_vc_flags_in_addition
	movs	r3, #0
	bl	.L60	@ far jump
.L78:
	ldr	r0, .L198
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #11
	uxth	r3, r3
	movs	r2, r3
	movs	r3, #31
	ands	r3, r2
	cmp	r3, #7
	bne	.L79
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #8
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r3, .L198+44
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	ldr	r3, .L198+48
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	adds	r2, r7, r0
	ldrh	r2, [r2]
	strb	r2, [r3]
	ldr	r3, .L198+44
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	ldr	r3, .L198+16
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r5, #160
	adds	r2, r7, r5
	str	r3, [r2]
	ldr	r3, .L198+48
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r3, [r3]
	adds	r2, r7, r5
	ldr	r2, [r2]
	subs	r3, r2, r3
	movs	r4, #156
	adds	r2, r7, r4
	str	r3, [r2]
	ldr	r3, .L198+44
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	adds	r3, r7, r4
	ldr	r1, [r3]
	ldr	r3, .L198+16
	lsls	r2, r2, #2
	str	r1, [r2, r3]
	adds	r3, r7, r4
	ldr	r3, [r3]
	movs	r0, r3
	bl	update_nz_flags
	adds	r3, r7, r5
	ldr	r0, [r3]
	ldr	r3, .L198+48
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r3, [r3]
	adds	r2, r7, r4
	ldr	r2, [r2]
	movs	r1, r3
	bl	update_vc_flags_in_subtraction
	movs	r3, #0
	bl	.L60	@ far jump
.L199:
	.align	2
.L198:
	.word	678
	.word	-583
	.word	-584
	.word	-585
	.word	cpu
	.word	-581
	.word	-582
	.word	-569
	.word	-570
	.word	-557
	.word	-558
	.word	-545
	.word	-546
.L79:
	ldr	r0, .L200
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #6
	uxth	r3, r3
	lsls	r3, r3, #22
	lsrs	r2, r3, #22
	movs	r3, #128
	lsls	r3, r3, #1
	cmp	r2, r3
	bne	.L80
	adds	r3, r7, r0
	ldrh	r3, [r3]
	uxtb	r2, r3
	ldr	r3, .L200+4
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #3
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r3, .L200+8
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	ldr	r3, .L200+4
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	ldr	r3, .L200+12
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r1, #176
	adds	r2, r7, r1
	str	r3, [r2]
	ldr	r3, .L200+8
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	ldr	r3, .L200+12
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r2, #172
	adds	r0, r7, r2
	str	r3, [r0]
	adds	r3, r7, r1
	ldr	r3, [r3]
	adds	r2, r7, r2
	ldr	r2, [r2]
	ands	r3, r2
	movs	r1, #168
	adds	r2, r7, r1
	str	r3, [r2]
	ldr	r3, .L200+4
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	movs	r0, r1
	adds	r3, r7, r1
	ldr	r1, [r3]
	ldr	r3, .L200+12
	lsls	r2, r2, #2
	str	r1, [r2, r3]
	adds	r3, r7, r0
	ldr	r3, [r3]
	movs	r0, r3
	bl	update_nz_flags
	movs	r3, #0
	bl	.L60	@ far jump
.L80:
	ldr	r0, .L200
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #6
	uxth	r3, r3
	lsls	r3, r3, #22
	lsrs	r2, r3, #22
	movs	r3, #2
	adds	r3, r3, #255
	cmp	r2, r3
	bne	.L81
	adds	r3, r7, r0
	ldrh	r3, [r3]
	uxtb	r2, r3
	ldr	r3, .L200+16
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #3
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r3, .L200+20
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	ldr	r3, .L200+16
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	ldr	r3, .L200+12
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r1, #192
	adds	r2, r7, r1
	str	r3, [r2]
	ldr	r3, .L200+20
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	ldr	r3, .L200+12
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r0, #188
	adds	r2, r7, r0
	str	r3, [r2]
	adds	r3, r7, r1
	ldr	r2, [r3]
	adds	r3, r7, r0
	ldr	r3, [r3]
	eors	r3, r2
	movs	r1, #184
	adds	r2, r7, r1
	str	r3, [r2]
	ldr	r3, .L200+16
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	movs	r0, r1
	adds	r3, r7, r1
	ldr	r1, [r3]
	ldr	r3, .L200+12
	lsls	r2, r2, #2
	str	r1, [r2, r3]
	adds	r3, r7, r0
	ldr	r3, [r3]
	movs	r0, r3
	bl	update_nz_flags
	movs	r3, #0
	bl	.L60	@ far jump
.L81:
	ldr	r0, .L200
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #6
	uxth	r3, r3
	lsls	r3, r3, #22
	lsrs	r2, r3, #22
	movs	r3, #129
	lsls	r3, r3, #1
	cmp	r2, r3
	bne	.L82
	adds	r3, r7, r0
	ldrh	r3, [r3]
	uxtb	r2, r3
	ldr	r3, .L200+24
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #3
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r3, .L200+28
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	ldr	r3, .L200+24
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	ldr	r3, .L200+12
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r0, #212
	adds	r2, r7, r0
	str	r3, [r2]
	ldr	r3, .L200+28
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	ldr	r3, .L200+12
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r2, r3
	movs	r3, #255
	ands	r3, r2
	movs	r4, #208
	adds	r2, r7, r4
	str	r3, [r2]
	adds	r3, r7, r0
	ldr	r2, [r3]
	adds	r3, r7, r4
	ldr	r3, [r3]
	lsls	r2, r2, r3
	movs	r3, r2
	movs	r5, #204
	adds	r2, r7, r5
	str	r3, [r2]
	ldr	r3, .L200+24
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	adds	r3, r7, r5
	ldr	r1, [r3]
	ldr	r3, .L200+12
	lsls	r2, r2, #2
	str	r1, [r2, r3]
	adds	r3, r7, r4
	ldr	r3, [r3]
	movs	r2, #31
	subs	r3, r2, r3
	adds	r2, r7, r0
	ldr	r2, [r2]
	lsrs	r2, r2, r3
	movs	r3, r2
	movs	r2, r3
	movs	r3, #1
	ands	r3, r2
	movs	r6, #200
	adds	r2, r7, r6
	str	r3, [r2]
	adds	r3, r7, r5
	ldr	r3, [r3]
	movs	r0, r3
	bl	update_nz_flags
	adds	r3, r7, r4
	ldr	r3, [r3]
	cmp	r3, #0
	beq	.L83
	adds	r3, r7, r6
	ldr	r3, [r3]
	cmp	r3, #0
	beq	.L84
	ldr	r3, .L200+12
	ldr	r3, [r3, #64]
	movs	r2, #128
	lsls	r2, r2, #22
	orrs	r2, r3
	ldr	r3, .L200+12
	str	r2, [r3, #64]
	b	.L83
.L84:
	ldr	r3, .L200+12
	ldr	r3, [r3, #64]
	ldr	r2, .L200+32
	ands	r2, r3
	ldr	r3, .L200+12
	str	r2, [r3, #64]
.L83:
	movs	r3, #0
	bl	.L60	@ far jump
.L82:
	ldr	r0, .L200
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #6
	uxth	r3, r3
	lsls	r3, r3, #22
	lsrs	r2, r3, #22
	movs	r3, #4
	adds	r3, r3, #255
	cmp	r2, r3
	beq	.LCB2318
	b	.L85	@long jump
.LCB2318:
	adds	r3, r7, r0
	ldrh	r3, [r3]
	uxtb	r2, r3
	ldr	r3, .L200+36
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #3
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r3, .L200+40
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	ldr	r3, .L200+36
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	ldr	r3, .L200+12
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r0, #232
	adds	r2, r7, r0
	str	r3, [r2]
	ldr	r3, .L200+40
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	ldr	r3, .L200+12
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r2, r3
	movs	r3, #255
	ands	r3, r2
	movs	r4, #228
	adds	r2, r7, r4
	str	r3, [r2]
	adds	r3, r7, r0
	ldr	r2, [r3]
	adds	r3, r7, r4
	ldr	r3, [r3]
	lsrs	r2, r2, r3
	movs	r3, r2
	movs	r5, #224
	adds	r2, r7, r5
	str	r3, [r2]
	ldr	r3, .L200+36
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	adds	r3, r7, r5
	ldr	r1, [r3]
	ldr	r3, .L200+12
	lsls	r2, r2, #2
	str	r1, [r2, r3]
	adds	r3, r7, r4
	ldr	r3, [r3]
	subs	r3, r3, #1
	adds	r2, r7, r0
	ldr	r2, [r2]
	lsrs	r2, r2, r3
	movs	r3, r2
	movs	r2, r3
	movs	r3, #1
	ands	r3, r2
	movs	r6, #220
	adds	r2, r7, r6
	str	r3, [r2]
	adds	r3, r7, r5
	ldr	r3, [r3]
	movs	r0, r3
	bl	update_nz_flags
	adds	r3, r7, r4
	ldr	r3, [r3]
	cmp	r3, #0
	beq	.L86
	adds	r3, r7, r6
	ldr	r3, [r3]
	cmp	r3, #0
	beq	.L87
	ldr	r3, .L200+12
	ldr	r3, [r3, #64]
	movs	r2, #128
	lsls	r2, r2, #22
	orrs	r2, r3
	ldr	r3, .L200+12
	str	r2, [r3, #64]
	b	.L86
.L87:
	ldr	r3, .L200+12
	ldr	r3, [r3, #64]
	ldr	r2, .L200+32
	ands	r2, r3
	ldr	r3, .L200+12
	str	r2, [r3, #64]
.L86:
	movs	r3, #0
	bl	.L60	@ far jump
.L201:
	.align	2
.L200:
	.word	678
	.word	-529
	.word	-530
	.word	cpu
	.word	-513
	.word	-514
	.word	-493
	.word	-494
	.word	-536870913
	.word	-473
	.word	-474
.L85:
	ldr	r0, .L202
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #6
	uxth	r3, r3
	lsls	r3, r3, #22
	lsrs	r2, r3, #22
	movs	r3, #130
	lsls	r3, r3, #1
	cmp	r2, r3
	bne	.L88
	adds	r3, r7, r0
	ldrh	r3, [r3]
	uxtb	r2, r3
	ldr	r3, .L202+4
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #3
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r3, .L202+8
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	ldr	r3, .L202+4
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	ldr	r3, .L202+12
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r5, #252
	adds	r2, r7, r5
	str	r3, [r2]
	ldr	r3, .L202+8
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	ldr	r3, .L202+12
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r2, #255
	ands	r3, r2
	movs	r4, #248
	adds	r2, r7, r4
	str	r3, [r2]
	adds	r3, r7, r5
	ldr	r2, [r3]
	adds	r3, r7, r4
	ldr	r3, [r3]
	asrs	r2, r2, r3
	movs	r3, r2
	movs	r1, #244
	adds	r2, r7, r1
	str	r3, [r2]
	ldr	r3, .L202+4
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	ldr	r3, .L202+12
	lsls	r2, r2, #2
	movs	r0, r1
	adds	r1, r7, r1
	ldr	r1, [r1]
	str	r1, [r2, r3]
	adds	r3, r7, r0
	ldr	r3, [r3]
	movs	r0, r3
	bl	update_nz_flags
	adds	r3, r7, r4
	ldr	r3, [r3]
	subs	r3, r3, #1
	adds	r2, r7, r5
	ldr	r2, [r2]
	asrs	r2, r2, r3
	movs	r3, r2
	movs	r2, #1
	ands	r3, r2
	movs	r2, #240
	adds	r1, r7, r2
	str	r3, [r1]
	adds	r3, r7, r4
	ldr	r3, [r3]
	cmp	r3, #0
	ble	.L89
	adds	r3, r7, r2
	ldr	r3, [r3]
	cmp	r3, #0
	beq	.L90
	ldr	r3, .L202+12
	ldr	r3, [r3, #64]
	movs	r2, #128
	lsls	r2, r2, #22
	orrs	r2, r3
	ldr	r3, .L202+12
	str	r2, [r3, #64]
	b	.L89
.L90:
	ldr	r3, .L202+12
	ldr	r3, [r3, #64]
	ldr	r2, .L202+16
	ands	r2, r3
	ldr	r3, .L202+12
	str	r2, [r3, #64]
.L89:
	movs	r3, #0
	bl	.L60	@ far jump
.L88:
	ldr	r0, .L202
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #6
	uxth	r3, r3
	lsls	r3, r3, #22
	lsrs	r2, r3, #22
	movs	r3, #6
	adds	r3, r3, #255
	cmp	r2, r3
	bne	.L91
	adds	r3, r7, r0
	ldrh	r3, [r3]
	uxtb	r2, r3
	ldr	r3, .L202+20
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #3
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r3, .L202+24
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	ldr	r3, .L202+20
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	ldr	r3, .L202+12
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r4, #136
	lsls	r4, r4, #1
	adds	r2, r7, r4
	str	r3, [r2]
	ldr	r3, .L202+24
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	ldr	r3, .L202+12
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r5, #134
	lsls	r5, r5, #1
	adds	r2, r7, r5
	str	r3, [r2]
	ldr	r3, .L202+12
	ldr	r3, [r3, #64]
	asrs	r3, r3, #29
	movs	r2, #1
	ands	r3, r2
	movs	r6, #132
	lsls	r6, r6, #1
	adds	r2, r7, r6
	str	r3, [r2]
	adds	r3, r7, r4
	ldr	r2, [r3]
	adds	r3, r7, r5
	ldr	r3, [r3]
	adds	r2, r2, r3
	adds	r3, r7, r6
	ldr	r3, [r3]
	adds	r3, r2, r3
	adds	r2, r7, #5
	adds	r2, r2, #255
	str	r3, [r2]
	ldr	r3, .L202+20
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	adds	r3, r7, #5
	adds	r3, r3, #255
	ldr	r1, [r3]
	ldr	r3, .L202+12
	lsls	r2, r2, #2
	str	r1, [r2, r3]
	adds	r3, r7, #5
	adds	r3, r3, #255
	ldr	r3, [r3]
	movs	r0, r3
	bl	update_nz_flags
	adds	r3, r7, r4
	ldr	r0, [r3]
	adds	r3, r7, r6
	ldr	r2, [r3]
	adds	r3, r7, r5
	ldr	r3, [r3]
	adds	r3, r2, r3
	movs	r1, r3
	adds	r3, r7, #5
	adds	r3, r3, #255
	ldr	r3, [r3]
	movs	r2, r3
	bl	update_vc_flags_in_addition
	movs	r3, #0
	bl	.L60	@ far jump
.L91:
	ldr	r0, .L202
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #6
	uxth	r3, r3
	lsls	r3, r3, #22
	lsrs	r2, r3, #22
	movs	r3, #131
	lsls	r3, r3, #1
	cmp	r2, r3
	beq	.LCB2754
	b	.L92	@long jump
.LCB2754:
	adds	r3, r7, r0
	ldrh	r3, [r3]
	uxtb	r2, r3
	ldr	r3, .L202+28
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #3
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r3, .L202+32
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	ldr	r3, .L202+28
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	ldr	r3, .L202+12
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r5, #146
	lsls	r5, r5, #1
	adds	r2, r7, r5
	str	r3, [r2]
	ldr	r3, .L202+32
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	ldr	r3, .L202+12
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r6, #144
	lsls	r6, r6, #1
	adds	r2, r7, r6
	str	r3, [r2]
	ldr	r3, .L202+12
	ldr	r3, [r3, #64]
	asrs	r3, r3, #29
	movs	r2, #1
	ands	r3, r2
	movs	r1, #142
	lsls	r1, r1, #1
	adds	r2, r7, r1
	str	r3, [r2]
	adds	r3, r7, r5
	ldr	r2, [r3]
	adds	r3, r7, r6
	ldr	r3, [r3]
	subs	r2, r2, r3
	adds	r3, r7, r1
	ldr	r3, [r3]
	subs	r3, r2, r3
	movs	r4, #140
	lsls	r4, r4, #1
	adds	r2, r7, r4
	str	r3, [r2]
	ldr	r3, .L202+28
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	adds	r3, r7, r4
	ldr	r1, [r3]
	ldr	r3, .L202+12
	lsls	r2, r2, #2
	str	r1, [r2, r3]
	adds	r3, r7, r4
	ldr	r3, [r3]
	movs	r0, r3
	bl	update_nz_flags
	adds	r3, r7, r5
	ldr	r0, [r3]
	movs	r1, #142
	lsls	r1, r1, #1
	adds	r3, r7, r1
	ldr	r2, [r3]
	adds	r3, r7, r6
	ldr	r3, [r3]
	adds	r3, r2, r3
	movs	r1, r3
	adds	r3, r7, r4
	ldr	r3, [r3]
	movs	r2, r3
	bl	update_vc_flags_in_subtraction
	movs	r3, #0
	bl	.L60	@ far jump
.L203:
	.align	2
.L202:
	.word	678
	.word	-453
	.word	-454
	.word	cpu
	.word	-536870913
	.word	-433
	.word	-434
	.word	-413
	.word	-414
.L92:
	ldr	r0, .L204
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #6
	uxth	r3, r3
	lsls	r3, r3, #22
	lsrs	r2, r3, #22
	movs	r3, #8
	adds	r3, r3, #255
	cmp	r2, r3
	beq	.LCB2902
	b	.L93	@long jump
.LCB2902:
	adds	r3, r7, r0
	ldrh	r3, [r3]
	uxtb	r2, r3
	ldr	r3, .L204+4
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #3
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r3, .L204+8
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	ldr	r3, .L204+4
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	ldr	r3, .L204+12
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r5, #156
	lsls	r5, r5, #1
	adds	r2, r7, r5
	str	r3, [r2]
	ldr	r3, .L204+8
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	ldr	r3, .L204+12
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r2, r3
	movs	r3, #31
	ands	r3, r2
	movs	r4, #154
	lsls	r4, r4, #1
	adds	r2, r7, r4
	str	r3, [r2]
	adds	r3, r7, r5
	ldr	r2, [r3]
	adds	r3, r7, r4
	ldr	r3, [r3]
	rors	r2, r2, r3
	movs	r3, r2
	movs	r1, #152
	lsls	r1, r1, #1
	adds	r2, r7, r1
	str	r3, [r2]
	ldr	r3, .L204+4
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	movs	r0, r1
	adds	r3, r7, r1
	ldr	r1, [r3]
	ldr	r3, .L204+12
	lsls	r2, r2, #2
	str	r1, [r2, r3]
	adds	r3, r7, r0
	ldr	r3, [r3]
	movs	r0, r3
	bl	update_nz_flags
	adds	r3, r7, r4
	ldr	r3, [r3]
	subs	r3, r3, #1
	adds	r2, r7, r5
	ldr	r2, [r2]
	lsrs	r2, r2, r3
	movs	r3, r2
	movs	r2, r3
	movs	r3, #1
	ands	r3, r2
	movs	r2, #150
	lsls	r2, r2, #1
	adds	r1, r7, r2
	str	r3, [r1]
	adds	r3, r7, r4
	ldr	r3, [r3]
	cmp	r3, #0
	beq	.L94
	adds	r3, r7, r2
	ldr	r3, [r3]
	cmp	r3, #0
	beq	.L95
	ldr	r3, .L204+12
	ldr	r3, [r3, #64]
	movs	r2, #128
	lsls	r2, r2, #22
	orrs	r2, r3
	ldr	r3, .L204+12
	str	r2, [r3, #64]
	b	.L94
.L95:
	ldr	r3, .L204+12
	ldr	r3, [r3, #64]
	ldr	r2, .L204+16
	ands	r2, r3
	ldr	r3, .L204+12
	str	r2, [r3, #64]
.L94:
	movs	r3, #0
	bl	.L60	@ far jump
.L93:
	ldr	r0, .L204
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #6
	uxth	r3, r3
	lsls	r3, r3, #22
	lsrs	r2, r3, #22
	movs	r3, #132
	lsls	r3, r3, #1
	cmp	r2, r3
	bne	.L96
	adds	r3, r7, r0
	ldrh	r3, [r3]
	uxtb	r2, r3
	ldr	r3, .L204+20
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #3
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r3, .L204+24
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	ldr	r3, .L204+20
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	ldr	r3, .L204+12
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r1, #164
	lsls	r1, r1, #1
	adds	r2, r7, r1
	str	r3, [r2]
	ldr	r3, .L204+24
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	ldr	r3, .L204+12
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r2, #162
	lsls	r2, r2, #1
	adds	r0, r7, r2
	str	r3, [r0]
	adds	r3, r7, r1
	ldr	r3, [r3]
	adds	r2, r7, r2
	ldr	r2, [r2]
	ands	r3, r2
	movs	r2, #160
	lsls	r2, r2, #1
	adds	r1, r7, r2
	str	r3, [r1]
	adds	r3, r7, r2
	ldr	r3, [r3]
	movs	r0, r3
	bl	update_nz_flags
	movs	r3, #0
	bl	.L60	@ far jump
.L96:
	ldr	r0, .L204
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #6
	uxth	r3, r3
	lsls	r3, r3, #22
	lsrs	r2, r3, #22
	movs	r3, #10
	adds	r3, r3, #255
	cmp	r2, r3
	bne	.L97
	adds	r3, r7, r0
	ldrh	r3, [r3]
	uxtb	r2, r3
	ldr	r3, .L204+28
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #3
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r3, .L204+32
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	ldr	r3, .L204+32
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	ldr	r3, .L204+12
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r2, #170
	lsls	r2, r2, #1
	adds	r1, r7, r2
	str	r3, [r1]
	adds	r3, r7, r2
	ldr	r3, [r3]
	rsbs	r3, r3, #0
	movs	r1, #168
	lsls	r1, r1, #1
	adds	r2, r7, r1
	str	r3, [r2]
	ldr	r3, .L204+28
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	movs	r0, r1
	adds	r3, r7, r1
	ldr	r1, [r3]
	ldr	r3, .L204+12
	lsls	r2, r2, #2
	str	r1, [r2, r3]
	adds	r3, r7, r0
	ldr	r3, [r3]
	movs	r0, r3
	bl	update_nz_flags
	movs	r3, #0
	bl	.L60	@ far jump
.L97:
	ldr	r0, .L204
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #6
	uxth	r3, r3
	lsls	r3, r3, #22
	lsrs	r2, r3, #22
	movs	r3, #133
	lsls	r3, r3, #1
	cmp	r2, r3
	bne	.L98
	adds	r3, r7, r0
	ldrh	r3, [r3]
	uxtb	r2, r3
	ldr	r3, .L204+36
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #3
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r3, .L204+40
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	ldr	r3, .L204+36
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	ldr	r3, .L204+12
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r4, #178
	lsls	r4, r4, #1
	adds	r2, r7, r4
	str	r3, [r2]
	ldr	r3, .L204+40
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	ldr	r3, .L204+12
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r5, #176
	lsls	r5, r5, #1
	adds	r2, r7, r5
	str	r3, [r2]
	adds	r3, r7, r4
	ldr	r2, [r3]
	adds	r3, r7, r5
	ldr	r3, [r3]
	subs	r3, r2, r3
	movs	r6, #174
	lsls	r6, r6, #1
	adds	r2, r7, r6
	str	r3, [r2]
	adds	r3, r7, r6
	ldr	r3, [r3]
	movs	r0, r3
	bl	update_nz_flags
	adds	r3, r7, r4
	ldr	r3, [r3]
	adds	r2, r7, r5
	ldr	r1, [r2]
	adds	r2, r7, r6
	ldr	r2, [r2]
	movs	r0, r3
	bl	update_vc_flags_in_subtraction
	movs	r3, #0
	bl	.L60	@ far jump
.L98:
	ldr	r0, .L204
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #6
	uxth	r3, r3
	lsls	r3, r3, #22
	lsrs	r2, r3, #22
	movs	r3, #12
	adds	r3, r3, #255
	cmp	r2, r3
	bne	.L99
	adds	r3, r7, r0
	ldrh	r3, [r3]
	uxtb	r2, r3
	ldr	r3, .L204+44
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #3
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r3, .L204+48
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	ldr	r3, .L204+44
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	ldr	r3, .L204+12
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r4, #186
	lsls	r4, r4, #1
	adds	r2, r7, r4
	str	r3, [r2]
	ldr	r3, .L204+48
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	ldr	r3, .L204+12
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r5, #184
	lsls	r5, r5, #1
	adds	r2, r7, r5
	str	r3, [r2]
	adds	r3, r7, r4
	ldr	r2, [r3]
	adds	r3, r7, r5
	ldr	r3, [r3]
	adds	r3, r2, r3
	movs	r6, #182
	lsls	r6, r6, #1
	adds	r2, r7, r6
	str	r3, [r2]
	adds	r3, r7, r6
	ldr	r3, [r3]
	movs	r0, r3
	bl	update_nz_flags
	adds	r3, r7, r4
	ldr	r3, [r3]
	adds	r2, r7, r5
	ldr	r1, [r2]
	adds	r2, r7, r6
	ldr	r2, [r2]
	movs	r0, r3
	bl	update_vc_flags_in_addition
	movs	r3, #0
	bl	.L60	@ far jump
.L205:
	.align	2
.L204:
	.word	678
	.word	-393
	.word	-394
	.word	cpu
	.word	-536870913
	.word	-377
	.word	-378
	.word	-365
	.word	-366
	.word	-349
	.word	-350
	.word	-333
	.word	-334
.L99:
	ldr	r0, .L206
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #6
	uxth	r3, r3
	lsls	r3, r3, #22
	lsrs	r2, r3, #22
	movs	r3, #134
	lsls	r3, r3, #1
	cmp	r2, r3
	bne	.L100
	adds	r3, r7, r0
	ldrh	r3, [r3]
	uxtb	r2, r3
	ldr	r3, .L206+4
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #3
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r3, .L206+8
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	ldr	r3, .L206+4
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	ldr	r3, .L206+12
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r1, #194
	lsls	r1, r1, #1
	adds	r2, r7, r1
	str	r3, [r2]
	ldr	r3, .L206+8
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	ldr	r3, .L206+12
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r0, #192
	lsls	r0, r0, #1
	adds	r2, r7, r0
	str	r3, [r2]
	adds	r3, r7, r1
	ldr	r2, [r3]
	adds	r3, r7, r0
	ldr	r3, [r3]
	orrs	r3, r2
	movs	r1, #190
	lsls	r1, r1, #1
	adds	r2, r7, r1
	str	r3, [r2]
	ldr	r3, .L206+4
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	movs	r0, r1
	adds	r3, r7, r1
	ldr	r1, [r3]
	ldr	r3, .L206+12
	lsls	r2, r2, #2
	str	r1, [r2, r3]
	adds	r3, r7, r0
	ldr	r3, [r3]
	movs	r0, r3
	bl	update_nz_flags
	movs	r3, #0
	bl	.L60	@ far jump
.L100:
	ldr	r0, .L206
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #6
	uxth	r3, r3
	lsls	r3, r3, #22
	lsrs	r2, r3, #22
	movs	r3, #14
	adds	r3, r3, #255
	cmp	r2, r3
	bne	.L101
	adds	r3, r7, r0
	ldrh	r3, [r3]
	uxtb	r2, r3
	ldr	r3, .L206+16
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #3
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r3, .L206+20
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	ldr	r3, .L206+16
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	ldr	r3, .L206+12
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r1, #202
	lsls	r1, r1, #1
	adds	r2, r7, r1
	str	r3, [r2]
	ldr	r3, .L206+20
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	ldr	r3, .L206+12
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r2, #200
	lsls	r2, r2, #1
	adds	r0, r7, r2
	str	r3, [r0]
	adds	r3, r7, r1
	ldr	r3, [r3]
	adds	r2, r7, r2
	ldr	r2, [r2]
	muls	r3, r2
	movs	r1, #198
	lsls	r1, r1, #1
	adds	r2, r7, r1
	str	r3, [r2]
	ldr	r3, .L206+16
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	movs	r0, r1
	adds	r3, r7, r1
	ldr	r1, [r3]
	ldr	r3, .L206+12
	lsls	r2, r2, #2
	str	r1, [r2, r3]
	adds	r3, r7, r0
	ldr	r3, [r3]
	movs	r0, r3
	bl	update_nz_flags
	movs	r3, #0
	bl	.L60	@ far jump
.L101:
	ldr	r0, .L206
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #6
	uxth	r3, r3
	lsls	r3, r3, #22
	lsrs	r2, r3, #22
	movs	r3, #135
	lsls	r3, r3, #1
	cmp	r2, r3
	bne	.L102
	adds	r3, r7, r0
	ldrh	r3, [r3]
	uxtb	r2, r3
	ldr	r3, .L206+24
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #3
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r3, .L206+28
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	ldr	r3, .L206+24
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	ldr	r3, .L206+12
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r1, #210
	lsls	r1, r1, #1
	adds	r2, r7, r1
	str	r3, [r2]
	ldr	r3, .L206+28
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	ldr	r3, .L206+12
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r2, #208
	lsls	r2, r2, #1
	adds	r0, r7, r2
	str	r3, [r0]
	adds	r3, r7, r2
	ldr	r3, [r3]
	mvns	r2, r3
	adds	r3, r7, r1
	ldr	r3, [r3]
	ands	r3, r2
	movs	r1, #206
	lsls	r1, r1, #1
	adds	r2, r7, r1
	str	r3, [r2]
	ldr	r3, .L206+24
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	movs	r0, r1
	adds	r3, r7, r1
	ldr	r1, [r3]
	ldr	r3, .L206+12
	lsls	r2, r2, #2
	str	r1, [r2, r3]
	adds	r3, r7, r0
	ldr	r3, [r3]
	movs	r0, r3
	bl	update_nz_flags
	movs	r3, #0
	bl	.L60	@ far jump
.L102:
	ldr	r0, .L206
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #6
	uxth	r3, r3
	lsls	r3, r3, #22
	lsrs	r2, r3, #22
	movs	r3, #16
	adds	r3, r3, #255
	cmp	r2, r3
	bne	.L103
	adds	r3, r7, r0
	ldrh	r3, [r3]
	uxtb	r2, r3
	ldr	r3, .L206+32
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #3
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r3, .L206+36
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	ldr	r3, .L206+36
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	ldr	r3, .L206+12
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r2, #216
	lsls	r2, r2, #1
	adds	r1, r7, r2
	str	r3, [r1]
	adds	r3, r7, r2
	ldr	r3, [r3]
	mvns	r3, r3
	movs	r1, #214
	lsls	r1, r1, #1
	adds	r2, r7, r1
	str	r3, [r2]
	ldr	r3, .L206+32
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	movs	r0, r1
	adds	r3, r7, r1
	ldr	r1, [r3]
	ldr	r3, .L206+12
	lsls	r2, r2, #2
	str	r1, [r2, r3]
	adds	r3, r7, r0
	ldr	r3, [r3]
	movs	r0, r3
	bl	update_nz_flags
	movs	r3, #0
	bl	.L60	@ far jump
.L103:
	ldr	r0, .L206
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #6
	uxth	r3, r3
	lsls	r3, r3, #22
	lsrs	r2, r3, #22
	movs	r3, #140
	lsls	r3, r3, #1
	cmp	r2, r3
	bne	.L104
	adds	r3, r7, r0
	ldrh	r3, [r3]
	uxtb	r2, r3
	ldr	r3, .L206+40
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #3
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r3, .L206+44
	movs	r1, #178
	lsls	r1, r1, #2
	mov	ip, r1
	add	ip, ip, r7
	add	r3, r3, ip
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	ldr	r3, .L206+44
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	ldr	r3, .L206+12
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r1, #220
	lsls	r1, r1, #1
	adds	r2, r7, r1
	str	r3, [r2]
	ldr	r3, .L206+40
	movs	r2, #178
	lsls	r2, r2, #2
	mov	ip, r2
	add	ip, ip, r7
	add	r3, r3, ip
	ldrb	r2, [r3]
	adds	r3, r7, r1
	ldr	r1, [r3]
	ldr	r3, .L206+12
	lsls	r2, r2, #2
	str	r1, [r2, r3]
	movs	r3, #0
	bl	.L60	@ far jump
.L207:
	.align	2
.L206:
	.word	678
	.word	-317
	.word	-318
	.word	cpu
	.word	-301
	.word	-302
	.word	-285
	.word	-286
	.word	-273
	.word	-274
	.word	-265
	.word	-266
.L104:
	ldr	r1, .L208
	adds	r3, r7, r1
	ldrh	r3, [r3]
	lsrs	r3, r3, #6
	uxth	r3, r3
	lsls	r3, r3, #22
	lsrs	r2, r3, #22
	movs	r3, #18
	adds	r3, r3, #255
	cmp	r2, r3
	bne	.L105
	movs	r0, r1
	adds	r3, r7, r1
	ldrh	r3, [r3]
	uxtb	r2, r3
	movs	r4, #204
	adds	r4, r4, #255
	adds	r3, r7, r4
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #3
	uxth	r3, r3
	uxtb	r2, r3
	movs	r5, #229
	lsls	r5, r5, #1
	adds	r3, r7, r5
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	movs	r0, r4
	adds	r3, r7, r0
	ldrb	r2, [r3]
	ldr	r3, .L208+4
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r1, #226
	lsls	r1, r1, #1
	adds	r2, r7, r1
	str	r3, [r2]
	adds	r3, r7, r5
	ldrb	r3, [r3]
	adds	r3, r3, #8
	movs	r2, r3
	ldr	r3, .L208+4
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r4, #224
	lsls	r4, r4, #1
	adds	r2, r7, r4
	str	r3, [r2]
	adds	r3, r7, r1
	ldr	r2, [r3]
	adds	r3, r7, r4
	ldr	r3, [r3]
	adds	r3, r2, r3
	adds	r2, r7, r1
	str	r3, [r2]
	adds	r3, r7, r0
	ldrb	r2, [r3]
	adds	r3, r7, r1
	ldr	r1, [r3]
	ldr	r3, .L208+4
	lsls	r2, r2, #2
	str	r1, [r2, r3]
	movs	r3, #0
	bl	.L60	@ far jump
.L105:
	ldr	r1, .L208
	adds	r3, r7, r1
	ldrh	r3, [r3]
	lsrs	r3, r3, #6
	uxth	r3, r3
	lsls	r3, r3, #22
	lsrs	r2, r3, #22
	movs	r3, #26
	adds	r3, r3, #255
	cmp	r2, r3
	bne	.L106
	movs	r0, r1
	adds	r3, r7, r1
	ldrh	r3, [r3]
	uxtb	r2, r3
	movs	r4, #216
	adds	r4, r4, #255
	adds	r3, r7, r4
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #3
	uxth	r3, r3
	uxtb	r2, r3
	movs	r5, #235
	lsls	r5, r5, #1
	adds	r3, r7, r5
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	movs	r1, r4
	adds	r3, r7, r1
	ldrb	r2, [r3]
	ldr	r3, .L208+4
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r0, #232
	lsls	r0, r0, #1
	adds	r2, r7, r0
	str	r3, [r2]
	adds	r3, r7, r5
	ldrb	r3, [r3]
	adds	r3, r3, #8
	movs	r2, r3
	ldr	r3, .L208+4
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r2, #230
	lsls	r2, r2, #1
	adds	r4, r7, r2
	str	r3, [r4]
	adds	r3, r7, r2
	ldr	r3, [r3]
	adds	r2, r7, r0
	str	r3, [r2]
	adds	r3, r7, r1
	ldrb	r2, [r3]
	adds	r3, r7, r0
	ldr	r1, [r3]
	ldr	r3, .L208+4
	lsls	r2, r2, #2
	str	r1, [r2, r3]
	movs	r3, #0
	bl	.L60	@ far jump
.L106:
	ldr	r1, .L208
	adds	r3, r7, r1
	ldrh	r3, [r3]
	lsrs	r3, r3, #6
	uxth	r3, r3
	lsls	r3, r3, #22
	lsrs	r2, r3, #22
	movs	r3, #137
	lsls	r3, r3, #1
	cmp	r2, r3
	bne	.L107
	movs	r0, r1
	adds	r3, r7, r1
	ldrh	r3, [r3]
	uxtb	r2, r3
	movs	r4, #228
	adds	r4, r4, #255
	adds	r3, r7, r4
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #3
	uxth	r3, r3
	uxtb	r2, r3
	movs	r5, #241
	lsls	r5, r5, #1
	adds	r3, r7, r5
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	movs	r0, r4
	adds	r3, r7, r0
	ldrb	r3, [r3]
	adds	r3, r3, #8
	movs	r2, r3
	ldr	r3, .L208+4
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r1, #238
	lsls	r1, r1, #1
	adds	r2, r7, r1
	str	r3, [r2]
	adds	r3, r7, r5
	ldrb	r2, [r3]
	ldr	r3, .L208+4
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r4, #236
	lsls	r4, r4, #1
	adds	r2, r7, r4
	str	r3, [r2]
	adds	r3, r7, r1
	ldr	r2, [r3]
	adds	r3, r7, r4
	ldr	r3, [r3]
	adds	r3, r2, r3
	adds	r2, r7, r1
	str	r3, [r2]
	adds	r3, r7, r0
	ldrb	r3, [r3]
	adds	r3, r3, #8
	movs	r2, r3
	adds	r3, r7, r1
	ldr	r1, [r3]
	ldr	r3, .L208+4
	lsls	r2, r2, #2
	str	r1, [r2, r3]
	movs	r3, #0
	bl	.L60	@ far jump
.L107:
	ldr	r1, .L208
	adds	r3, r7, r1
	ldrh	r3, [r3]
	lsrs	r3, r3, #6
	uxth	r3, r3
	lsls	r3, r3, #22
	lsrs	r2, r3, #22
	movs	r3, #141
	lsls	r3, r3, #1
	cmp	r2, r3
	bne	.L108
	movs	r0, r1
	adds	r3, r7, r1
	ldrh	r3, [r3]
	uxtb	r2, r3
	movs	r4, #240
	adds	r4, r4, #255
	adds	r3, r7, r4
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #3
	uxth	r3, r3
	uxtb	r2, r3
	movs	r5, #247
	lsls	r5, r5, #1
	adds	r3, r7, r5
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	movs	r1, r4
	adds	r3, r7, r1
	ldrb	r3, [r3]
	adds	r3, r3, #8
	movs	r2, r3
	ldr	r3, .L208+4
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r0, #244
	lsls	r0, r0, #1
	adds	r2, r7, r0
	str	r3, [r2]
	adds	r3, r7, r5
	ldrb	r2, [r3]
	ldr	r3, .L208+4
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r2, #242
	lsls	r2, r2, #1
	adds	r4, r7, r2
	str	r3, [r4]
	adds	r3, r7, r2
	ldr	r3, [r3]
	adds	r2, r7, r0
	str	r3, [r2]
	adds	r3, r7, r1
	ldrb	r3, [r3]
	adds	r3, r3, #8
	movs	r2, r3
	adds	r3, r7, r0
	ldr	r1, [r3]
	ldr	r3, .L208+4
	lsls	r2, r2, #2
	str	r1, [r2, r3]
	movs	r3, #0
	bl	.L60	@ far jump
.L108:
	ldr	r1, .L208
	adds	r3, r7, r1
	ldrh	r3, [r3]
	lsrs	r3, r3, #6
	uxth	r3, r3
	lsls	r3, r3, #22
	lsrs	r2, r3, #22
	movs	r3, #20
	adds	r3, r3, #255
	cmp	r2, r3
	bne	.L109
	movs	r0, r1
	adds	r3, r7, r1
	ldrh	r3, [r3]
	uxtb	r2, r3
	movs	r4, #252
	adds	r4, r4, #255
	adds	r3, r7, r4
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #3
	uxth	r3, r3
	uxtb	r2, r3
	movs	r5, #253
	lsls	r5, r5, #1
	adds	r3, r7, r5
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	movs	r0, r4
	adds	r3, r7, r0
	ldrb	r3, [r3]
	adds	r3, r3, #8
	movs	r2, r3
	ldr	r3, .L208+4
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r1, #250
	lsls	r1, r1, #1
	adds	r2, r7, r1
	str	r3, [r2]
	adds	r3, r7, r5
	ldrb	r3, [r3]
	adds	r3, r3, #8
	movs	r2, r3
	ldr	r3, .L208+4
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r4, #248
	lsls	r4, r4, #1
	adds	r2, r7, r4
	str	r3, [r2]
	adds	r3, r7, r1
	ldr	r2, [r3]
	adds	r3, r7, r4
	ldr	r3, [r3]
	adds	r3, r2, r3
	adds	r2, r7, r1
	str	r3, [r2]
	adds	r3, r7, r0
	ldrb	r3, [r3]
	adds	r3, r3, #8
	movs	r2, r3
	adds	r3, r7, r1
	ldr	r1, [r3]
	ldr	r3, .L208+4
	lsls	r2, r2, #2
	str	r1, [r2, r3]
	movs	r3, #0
	bl	.L60	@ far jump
.L109:
	ldr	r1, .L208
	adds	r3, r7, r1
	ldrh	r3, [r3]
	lsrs	r3, r3, #6
	uxth	r3, r3
	lsls	r3, r3, #22
	lsrs	r2, r3, #22
	movs	r3, #28
	adds	r3, r3, #255
	cmp	r2, r3
	bne	.L110
	movs	r0, r1
	adds	r3, r7, r1
	ldrh	r3, [r3]
	uxtb	r2, r3
	ldr	r4, .L208+8
	adds	r3, r7, r4
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #3
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r5, .L208+12
	adds	r3, r7, r5
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	movs	r1, r4
	adds	r3, r7, r1
	ldrb	r3, [r3]
	adds	r3, r3, #8
	movs	r2, r3
	ldr	r3, .L208+4
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r0, #128
	lsls	r0, r0, #2
	adds	r2, r7, r0
	str	r3, [r2]
	adds	r3, r7, r5
	ldrb	r3, [r3]
	adds	r3, r3, #8
	movs	r2, r3
	ldr	r3, .L208+4
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r2, #254
	lsls	r2, r2, #1
	adds	r4, r7, r2
	str	r3, [r4]
	adds	r3, r7, r2
	ldr	r3, [r3]
	adds	r2, r7, r0
	str	r3, [r2]
	adds	r3, r7, r1
	ldrb	r3, [r3]
	adds	r3, r3, #8
	movs	r2, r3
	adds	r3, r7, r0
	ldr	r1, [r3]
	ldr	r3, .L208+4
	lsls	r2, r2, #2
	str	r1, [r2, r3]
	movs	r3, #0
	bl	.L60	@ far jump
.L209:
	.align	2
.L208:
	.word	678
	.word	cpu
	.word	519
	.word	518
.L110:
	ldr	r1, .L210
	adds	r3, r7, r1
	ldrh	r3, [r3]
	lsrs	r3, r3, #6
	uxth	r3, r3
	lsls	r3, r3, #22
	lsrs	r2, r3, #22
	movs	r3, #22
	adds	r3, r3, #255
	cmp	r2, r3
	bne	.L111
	movs	r0, r1
	adds	r3, r7, r1
	ldrh	r3, [r3]
	uxtb	r2, r3
	ldr	r4, .L210+4
	adds	r3, r7, r4
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #3
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r0, .L210+8
	adds	r3, r7, r0
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r4
	ldrb	r2, [r3]
	ldr	r3, .L210+12
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r4, #132
	lsls	r4, r4, #2
	adds	r2, r7, r4
	str	r3, [r2]
	adds	r3, r7, r0
	ldrb	r3, [r3]
	adds	r3, r3, #8
	movs	r2, r3
	ldr	r3, .L210+12
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r5, #131
	lsls	r5, r5, #2
	adds	r2, r7, r5
	str	r3, [r2]
	adds	r3, r7, r4
	ldr	r2, [r3]
	adds	r3, r7, r5
	ldr	r3, [r3]
	subs	r3, r2, r3
	movs	r6, #130
	lsls	r6, r6, #2
	adds	r2, r7, r6
	str	r3, [r2]
	adds	r3, r7, r6
	ldr	r3, [r3]
	movs	r0, r3
	bl	update_nz_flags
	adds	r3, r7, r4
	ldr	r3, [r3]
	adds	r2, r7, r5
	ldr	r1, [r2]
	adds	r2, r7, r6
	ldr	r2, [r2]
	movs	r0, r3
	bl	update_vc_flags_in_subtraction
	movs	r3, #0
	bl	.L60	@ far jump
.L111:
	ldr	r1, .L210
	adds	r3, r7, r1
	ldrh	r3, [r3]
	lsrs	r3, r3, #6
	uxth	r3, r3
	lsls	r3, r3, #22
	lsrs	r2, r3, #22
	movs	r3, #139
	lsls	r3, r3, #1
	cmp	r2, r3
	bne	.L112
	movs	r0, r1
	adds	r3, r7, r1
	ldrh	r3, [r3]
	uxtb	r2, r3
	ldr	r4, .L210+16
	adds	r3, r7, r4
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #3
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r0, .L210+20
	adds	r3, r7, r0
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r4
	ldrb	r3, [r3]
	adds	r3, r3, #8
	movs	r2, r3
	ldr	r3, .L210+12
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r4, #136
	lsls	r4, r4, #2
	adds	r2, r7, r4
	str	r3, [r2]
	adds	r3, r7, r0
	ldrb	r2, [r3]
	ldr	r3, .L210+12
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r5, #135
	lsls	r5, r5, #2
	adds	r2, r7, r5
	str	r3, [r2]
	adds	r3, r7, r4
	ldr	r2, [r3]
	adds	r3, r7, r5
	ldr	r3, [r3]
	subs	r3, r2, r3
	movs	r6, #134
	lsls	r6, r6, #2
	adds	r2, r7, r6
	str	r3, [r2]
	adds	r3, r7, r6
	ldr	r3, [r3]
	movs	r0, r3
	bl	update_nz_flags
	adds	r3, r7, r4
	ldr	r3, [r3]
	adds	r2, r7, r5
	ldr	r1, [r2]
	adds	r2, r7, r6
	ldr	r2, [r2]
	movs	r0, r3
	bl	update_vc_flags_in_subtraction
	movs	r3, #0
	bl	.L60	@ far jump
.L112:
	ldr	r1, .L210
	adds	r3, r7, r1
	ldrh	r3, [r3]
	lsrs	r3, r3, #6
	uxth	r3, r3
	lsls	r3, r3, #22
	lsrs	r2, r3, #22
	movs	r3, #24
	adds	r3, r3, #255
	cmp	r2, r3
	bne	.L113
	movs	r0, r1
	adds	r3, r7, r1
	ldrh	r3, [r3]
	uxtb	r2, r3
	ldr	r4, .L210+24
	adds	r3, r7, r4
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #3
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r0, .L210+28
	adds	r3, r7, r0
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r4
	ldrb	r3, [r3]
	adds	r3, r3, #8
	movs	r2, r3
	ldr	r3, .L210+12
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r4, #140
	lsls	r4, r4, #2
	adds	r2, r7, r4
	str	r3, [r2]
	adds	r3, r7, r0
	ldrb	r3, [r3]
	adds	r3, r3, #8
	movs	r2, r3
	ldr	r3, .L210+12
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r5, #139
	lsls	r5, r5, #2
	adds	r2, r7, r5
	str	r3, [r2]
	adds	r3, r7, r4
	ldr	r2, [r3]
	adds	r3, r7, r5
	ldr	r3, [r3]
	subs	r3, r2, r3
	movs	r6, #138
	lsls	r6, r6, #2
	adds	r2, r7, r6
	str	r3, [r2]
	adds	r3, r7, r6
	ldr	r3, [r3]
	movs	r0, r3
	bl	update_nz_flags
	adds	r3, r7, r4
	ldr	r3, [r3]
	adds	r2, r7, r5
	ldr	r1, [r2]
	adds	r2, r7, r6
	ldr	r2, [r2]
	movs	r0, r3
	bl	update_vc_flags_in_subtraction
	movs	r3, #0
	bl	.L60	@ far jump
.L113:
	ldr	r2, .L210
	adds	r3, r7, r2
	ldrh	r3, [r3]
	lsrs	r3, r3, #7
	uxth	r3, r3
	lsls	r3, r3, #23
	lsrs	r3, r3, #23
	cmp	r3, #142
	bne	.L114
	adds	r3, r7, r2
	ldrh	r3, [r3]
	lsrs	r3, r3, #3
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r0, .L210+32
	adds	r3, r7, r0
	movs	r1, #15
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r0
	ldrb	r2, [r3]
	ldr	r3, .L210+12
	lsls	r2, r2, #2
	ldr	r2, [r2, r3]
	ldr	r3, .L210+12
	str	r2, [r3, #60]
	movs	r3, #0
	bl	.L60	@ far jump
.L114:
	ldr	r2, .L210
	adds	r3, r7, r2
	ldrh	r3, [r3]
	lsrs	r3, r3, #7
	uxth	r3, r3
	lsls	r3, r3, #23
	lsrs	r3, r3, #23
	cmp	r3, #143
	bne	.L115
	adds	r3, r7, r2
	ldrh	r3, [r3]
	lsrs	r3, r3, #3
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r0, .L210+36
	adds	r3, r7, r0
	movs	r1, #15
	ands	r2, r1
	strb	r2, [r3]
	ldr	r3, .L210+12
	ldr	r3, [r3, #60]
	movs	r1, #142
	lsls	r1, r1, #2
	adds	r2, r7, r1
	str	r3, [r2]
	adds	r3, r7, r0
	ldrb	r2, [r3]
	ldr	r3, .L210+12
	lsls	r2, r2, #2
	ldr	r2, [r2, r3]
	ldr	r3, .L210+12
	str	r2, [r3, #60]
	adds	r3, r7, r1
	ldr	r2, [r3]
	ldr	r3, .L210+12
	str	r2, [r3, #56]
	movs	r3, #0
	bl	.L60	@ far jump
.L115:
	ldr	r0, .L210
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #11
	uxth	r3, r3
	movs	r2, r3
	movs	r3, #31
	ands	r3, r2
	cmp	r3, #9
	bne	.L116
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #8
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r4, .L210+40
	adds	r3, r7, r4
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	ldr	r1, .L210+44
	adds	r3, r7, r1
	adds	r2, r7, r0
	ldrh	r2, [r2]
	strb	r2, [r3]
	adds	r3, r7, r4
	ldrb	r3, [r3]
	lsls	r2, r3, #2
	ldr	r3, .L210+12
	adds	r0, r2, r3
	ldr	r3, .L210+12
	ldr	r2, [r3, #60]
	adds	r3, r7, r1
	ldrb	r3, [r3]
	lsls	r3, r3, #2
	adds	r3, r2, r3
	movs	r1, r3
	bl	load_from_memory
	movs	r3, #0
	bl	.L60	@ far jump
.L116:
	ldr	r0, .L210
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #9
	uxth	r3, r3
	movs	r2, r3
	movs	r3, #127
	ands	r3, r2
	cmp	r3, #40
	bne	.L117
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #6
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r4, .L210+48
	adds	r3, r7, r4
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #3
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r5, .L210+52
	adds	r3, r7, r5
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r0
	ldrh	r3, [r3]
	uxtb	r2, r3
	ldr	r0, .L210+56
	adds	r3, r7, r0
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r4
	ldrb	r2, [r3]
	ldr	r3, .L210+12
	lsls	r2, r2, #2
	ldr	r2, [r2, r3]
	adds	r3, r7, r5
	ldrb	r1, [r3]
	ldr	r3, .L210+12
	lsls	r1, r1, #2
	ldr	r3, [r1, r3]
	adds	r3, r2, r3
	movs	r1, #144
	lsls	r1, r1, #2
	adds	r2, r7, r1
	str	r3, [r2]
	adds	r3, r7, r0
	ldrb	r2, [r3]
	ldr	r3, .L210+12
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r2, r3
	adds	r3, r7, r1
	ldr	r3, [r3]
	movs	r1, r3
	movs	r0, r2
	bl	store_to_memory
	movs	r3, #0
	bl	.L60	@ far jump
.L211:
	.align	2
.L210:
	.word	678
	.word	535
	.word	534
	.word	cpu
	.word	551
	.word	550
	.word	566
	.word	565
	.word	567
	.word	573
	.word	575
	.word	574
	.word	583
	.word	582
	.word	581
.L117:
	ldr	r0, .L212
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #9
	uxth	r3, r3
	movs	r2, r3
	movs	r3, #127
	ands	r3, r2
	cmp	r3, #44
	bne	.L118
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #6
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r4, .L212+4
	adds	r3, r7, r4
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #3
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r5, .L212+8
	adds	r3, r7, r5
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r0
	ldrh	r3, [r3]
	uxtb	r2, r3
	ldr	r0, .L212+12
	adds	r3, r7, r0
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r4
	ldrb	r2, [r3]
	ldr	r3, .L212+16
	lsls	r2, r2, #2
	ldr	r2, [r2, r3]
	adds	r3, r7, r5
	ldrb	r1, [r3]
	ldr	r3, .L212+16
	lsls	r1, r1, #2
	ldr	r3, [r1, r3]
	adds	r3, r2, r3
	movs	r1, #146
	lsls	r1, r1, #2
	adds	r2, r7, r1
	str	r3, [r2]
	adds	r3, r7, r0
	ldrb	r3, [r3]
	lsls	r2, r3, #2
	ldr	r3, .L212+16
	adds	r3, r2, r3
	adds	r2, r7, r1
	ldr	r2, [r2]
	movs	r1, r2
	movs	r0, r3
	bl	load_from_memory
	movs	r3, #0
	bl	.L60	@ far jump
.L118:
	ldr	r0, .L212
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #11
	uxth	r3, r3
	movs	r2, r3
	movs	r3, #31
	ands	r3, r2
	cmp	r3, #12
	bne	.L119
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #6
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r4, .L212+20
	adds	r3, r7, r4
	movs	r1, #31
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #3
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r5, .L212+24
	adds	r3, r7, r5
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r0
	ldrh	r3, [r3]
	uxtb	r2, r3
	ldr	r0, .L212+28
	adds	r3, r7, r0
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r5
	ldrb	r2, [r3]
	ldr	r3, .L212+16
	lsls	r2, r2, #2
	ldr	r2, [r2, r3]
	adds	r3, r7, r4
	ldrb	r3, [r3]
	lsls	r3, r3, #2
	adds	r3, r2, r3
	movs	r1, #148
	lsls	r1, r1, #2
	adds	r2, r7, r1
	str	r3, [r2]
	adds	r3, r7, r0
	ldrb	r2, [r3]
	ldr	r3, .L212+16
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r2, r3
	adds	r3, r7, r1
	ldr	r3, [r3]
	movs	r1, r3
	movs	r0, r2
	bl	store_to_memory
	movs	r3, #0
	bl	.L60	@ far jump
.L119:
	ldr	r0, .L212
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #11
	uxth	r3, r3
	movs	r2, r3
	movs	r3, #31
	ands	r3, r2
	cmp	r3, #13
	bne	.L120
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #6
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r4, .L212+32
	adds	r3, r7, r4
	movs	r1, #31
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #3
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r5, .L212+36
	adds	r3, r7, r5
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r0
	ldrh	r3, [r3]
	uxtb	r2, r3
	ldr	r0, .L212+40
	adds	r3, r7, r0
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r5
	ldrb	r2, [r3]
	ldr	r3, .L212+16
	lsls	r2, r2, #2
	ldr	r2, [r2, r3]
	adds	r3, r7, r4
	ldrb	r3, [r3]
	lsls	r3, r3, #2
	adds	r3, r2, r3
	movs	r1, #150
	lsls	r1, r1, #2
	adds	r2, r7, r1
	str	r3, [r2]
	adds	r3, r7, r0
	ldrb	r3, [r3]
	lsls	r2, r3, #2
	ldr	r3, .L212+16
	adds	r3, r2, r3
	adds	r2, r7, r1
	ldr	r2, [r2]
	movs	r1, r2
	movs	r0, r3
	bl	load_from_memory
	movs	r3, #0
	bl	.L60	@ far jump
.L120:
	ldr	r0, .L212
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #11
	uxth	r3, r3
	movs	r2, r3
	movs	r3, #31
	ands	r3, r2
	cmp	r3, #18
	bne	.L121
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #8
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r4, .L212+44
	adds	r3, r7, r4
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	ldr	r1, .L212+48
	adds	r3, r7, r1
	adds	r2, r7, r0
	ldrh	r2, [r2]
	strb	r2, [r3]
	ldr	r3, .L212+16
	ldr	r2, [r3, #52]
	adds	r3, r7, r1
	ldrb	r3, [r3]
	lsls	r3, r3, #2
	adds	r3, r2, r3
	movs	r1, #152
	lsls	r1, r1, #2
	adds	r2, r7, r1
	str	r3, [r2]
	adds	r3, r7, r4
	ldrb	r2, [r3]
	ldr	r3, .L212+16
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r2, r3
	adds	r3, r7, r1
	ldr	r3, [r3]
	movs	r1, r3
	movs	r0, r2
	bl	store_to_memory
	movs	r3, #0
	bl	.L60	@ far jump
.L121:
	ldr	r0, .L212
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #11
	uxth	r3, r3
	movs	r2, r3
	movs	r3, #31
	ands	r3, r2
	cmp	r3, #19
	bne	.L122
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #8
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r4, .L212+52
	adds	r3, r7, r4
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	ldr	r1, .L212+56
	adds	r3, r7, r1
	adds	r2, r7, r0
	ldrh	r2, [r2]
	strb	r2, [r3]
	ldr	r3, .L212+16
	ldr	r2, [r3, #52]
	adds	r3, r7, r1
	ldrb	r3, [r3]
	lsls	r3, r3, #2
	adds	r3, r2, r3
	movs	r1, #154
	lsls	r1, r1, #2
	adds	r2, r7, r1
	str	r3, [r2]
	adds	r3, r7, r4
	ldrb	r3, [r3]
	lsls	r2, r3, #2
	ldr	r3, .L212+16
	adds	r3, r2, r3
	adds	r2, r7, r1
	ldr	r2, [r2]
	movs	r1, r2
	movs	r0, r3
	bl	load_from_memory
	movs	r3, #0
	bl	.L60	@ far jump
.L122:
	ldr	r4, .L212
	adds	r3, r7, r4
	ldrh	r3, [r3]
	lsrs	r3, r3, #11
	uxth	r3, r3
	movs	r2, r3
	movs	r3, #31
	ands	r3, r2
	cmp	r3, #20
	bne	.L123
	adds	r3, r7, r4
	ldrh	r3, [r3]
	lsrs	r3, r3, #8
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r0, .L212+60
	adds	r3, r7, r0
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	ldr	r1, .L212+64
	adds	r3, r7, r1
	adds	r2, r7, r4
	ldrh	r2, [r2]
	strb	r2, [r3]
	adds	r3, r7, r1
	ldrb	r3, [r3]
	lsls	r3, r3, #2
	movs	r1, #156
	lsls	r1, r1, #2
	adds	r2, r7, r1
	str	r3, [r2]
	ldr	r3, .L212+16
	ldr	r3, [r3, #60]
	movs	r2, r3
	adds	r3, r7, r1
	ldr	r3, [r3]
	adds	r1, r2, r3
	adds	r3, r7, r0
	ldrb	r2, [r3]
	ldr	r3, .L212+16
	lsls	r2, r2, #2
	str	r1, [r2, r3]
	adds	r3, r7, r0
	ldrb	r2, [r3]
	ldr	r3, .L212+16
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	adds	r2, r7, r0
	ldrb	r2, [r2]
	movs	r1, #1
	bics	r3, r1
	movs	r1, r3
	ldr	r3, .L212+16
	lsls	r2, r2, #2
	str	r1, [r2, r3]
	adds	r3, r7, r0
	ldrb	r2, [r3]
	ldr	r3, .L212+16
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	adds	r2, r7, r0
	ldrb	r2, [r2]
	movs	r1, #2
	bics	r3, r1
	movs	r1, r3
	ldr	r3, .L212+16
	lsls	r2, r2, #2
	str	r1, [r2, r3]
	movs	r3, #0
	bl	.L60	@ far jump
.L123:
	ldr	r4, .L212
	adds	r3, r7, r4
	ldrh	r3, [r3]
	lsrs	r3, r3, #11
	uxth	r3, r3
	movs	r2, r3
	movs	r3, #31
	ands	r3, r2
	cmp	r3, #21
	bne	.L124
	adds	r3, r7, r4
	ldrh	r3, [r3]
	lsrs	r3, r3, #8
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r0, .L212+68
	adds	r3, r7, r0
	movs	r1, #7
	ands	r2, r1
	strb	r2, [r3]
	ldr	r1, .L212+72
	adds	r3, r7, r1
	adds	r2, r7, r4
	ldrh	r2, [r2]
	strb	r2, [r3]
	adds	r3, r7, r1
	ldrb	r3, [r3]
	lsls	r3, r3, #2
	movs	r1, #158
	lsls	r1, r1, #2
	adds	r2, r7, r1
	str	r3, [r2]
	ldr	r3, .L212+16
	ldr	r3, [r3, #52]
	movs	r2, r3
	adds	r3, r7, r1
	ldr	r3, [r3]
	adds	r1, r2, r3
	adds	r3, r7, r0
	ldrb	r2, [r3]
	ldr	r3, .L212+16
	lsls	r2, r2, #2
	str	r1, [r2, r3]
	adds	r3, r7, r0
	ldrb	r2, [r3]
	ldr	r3, .L212+16
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	adds	r2, r7, r0
	ldrb	r2, [r2]
	movs	r1, #1
	bics	r3, r1
	movs	r1, r3
	ldr	r3, .L212+16
	lsls	r2, r2, #2
	str	r1, [r2, r3]
	adds	r3, r7, r0
	ldrb	r2, [r3]
	ldr	r3, .L212+16
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	adds	r2, r7, r0
	ldrb	r2, [r2]
	movs	r1, #2
	bics	r3, r1
	movs	r1, r3
	ldr	r3, .L212+16
	lsls	r2, r2, #2
	str	r1, [r2, r3]
	movs	r3, #0
	bl	.L60	@ far jump
.L213:
	.align	2
.L212:
	.word	678
	.word	591
	.word	590
	.word	589
	.word	cpu
	.word	599
	.word	598
	.word	597
	.word	607
	.word	606
	.word	605
	.word	615
	.word	614
	.word	623
	.word	622
	.word	631
	.word	630
	.word	639
	.word	638
.L124:
	ldr	r1, .L214
	adds	r3, r7, r1
	ldrh	r3, [r3]
	lsrs	r3, r3, #7
	uxth	r3, r3
	lsls	r3, r3, #23
	lsrs	r2, r3, #23
	movs	r3, #176
	lsls	r3, r3, #1
	cmp	r2, r3
	bne	.L125
	adds	r3, r7, r1
	ldrh	r3, [r3]
	uxtb	r2, r3
	ldr	r0, .L214+4
	adds	r3, r7, r0
	movs	r1, #127
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r0
	ldrb	r3, [r3]
	lsls	r3, r3, #2
	movs	r1, #160
	lsls	r1, r1, #2
	adds	r2, r7, r1
	str	r3, [r2]
	ldr	r3, .L214+8
	ldr	r3, [r3, #52]
	movs	r2, r3
	adds	r3, r7, r1
	ldr	r3, [r3]
	adds	r3, r2, r3
	movs	r2, r3
	ldr	r3, .L214+8
	str	r2, [r3, #52]
	movs	r3, #0
	bl	.L60	@ far jump
.L125:
	ldr	r1, .L214
	adds	r3, r7, r1
	ldrh	r3, [r3]
	lsrs	r3, r3, #7
	uxth	r3, r3
	lsls	r3, r3, #23
	lsrs	r2, r3, #23
	movs	r3, #98
	adds	r3, r3, #255
	cmp	r2, r3
	bne	.L126
	adds	r3, r7, r1
	ldrh	r3, [r3]
	uxtb	r2, r3
	ldr	r0, .L214+12
	adds	r3, r7, r0
	movs	r1, #127
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r0
	ldrb	r3, [r3]
	lsls	r3, r3, #2
	movs	r1, #162
	lsls	r1, r1, #2
	adds	r2, r7, r1
	str	r3, [r2]
	ldr	r3, .L214+8
	ldr	r3, [r3, #52]
	movs	r2, r3
	adds	r3, r7, r1
	ldr	r3, [r3]
	subs	r3, r2, r3
	movs	r2, r3
	ldr	r3, .L214+8
	str	r2, [r3, #52]
	movs	r3, #0
	bl	.L60	@ far jump
.L126:
	ldr	r0, .L214
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #9
	uxth	r3, r3
	movs	r2, r3
	movs	r3, #127
	ands	r3, r2
	cmp	r3, #90
	bne	.L127
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #8
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r4, .L214+16
	adds	r3, r7, r4
	movs	r1, #1
	ands	r2, r1
	strb	r2, [r3]
	ldr	r3, .L214+20
	adds	r3, r7, r3
	adds	r2, r7, r0
	ldrh	r2, [r2]
	strb	r2, [r3]
	ldr	r3, .L214+8
	ldr	r3, [r3, #52]
	movs	r1, #177
	lsls	r1, r1, #2
	adds	r2, r7, r1
	str	r3, [r2]
	adds	r3, r7, r4
	ldrb	r3, [r3]
	cmp	r3, #1
	bne	.L128
	adds	r3, r7, r1
	ldr	r3, [r3]
	subs	r3, r3, #4
	adds	r2, r7, r1
	str	r3, [r2]
	ldr	r3, .L214+8
	ldr	r3, [r3, #56]
	movs	r2, r3
	adds	r3, r7, r1
	ldr	r3, [r3]
	movs	r1, r3
	movs	r0, r2
	bl	store_to_memory
.L128:
	movs	r3, #7
	movs	r2, #176
	lsls	r2, r2, #2
	adds	r2, r7, r2
	str	r3, [r2]
	b	.L129
.L131:
	ldr	r3, .L214+20
	adds	r3, r7, r3
	ldrb	r2, [r3]
	movs	r0, #176
	lsls	r0, r0, #2
	adds	r3, r7, r0
	ldr	r3, [r3]
	asrs	r2, r2, r3
	movs	r3, r2
	movs	r2, #1
	ands	r3, r2
	beq	.L130
	movs	r1, #177
	lsls	r1, r1, #2
	adds	r3, r7, r1
	ldr	r3, [r3]
	subs	r3, r3, #4
	adds	r2, r7, r1
	str	r3, [r2]
	ldr	r3, .L214+8
	adds	r2, r7, r0
	ldr	r2, [r2]
	lsls	r2, r2, #2
	ldr	r3, [r2, r3]
	movs	r2, r3
	adds	r3, r7, r1
	ldr	r3, [r3]
	movs	r1, r3
	movs	r0, r2
	bl	store_to_memory
.L130:
	movs	r2, #176
	lsls	r2, r2, #2
	adds	r3, r7, r2
	ldr	r3, [r3]
	subs	r3, r3, #1
	adds	r2, r7, r2
	str	r3, [r2]
.L129:
	movs	r3, #176
	lsls	r3, r3, #2
	adds	r3, r7, r3
	ldr	r3, [r3]
	cmp	r3, #0
	bge	.L131
	movs	r3, #177
	lsls	r3, r3, #2
	adds	r3, r7, r3
	ldr	r2, [r3]
	ldr	r3, .L214+8
	str	r2, [r3, #52]
	movs	r3, #0
	b	.L60
.L127:
	ldr	r0, .L214
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #9
	uxth	r3, r3
	movs	r2, r3
	movs	r3, #127
	ands	r3, r2
	cmp	r3, #94
	bne	.L132
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #8
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r3, .L214+24
	adds	r3, r7, r3
	movs	r1, #1
	ands	r2, r1
	strb	r2, [r3]
	movs	r3, #164
	lsls	r3, r3, #2
	adds	r3, r7, r3
	adds	r2, r7, r0
	ldrh	r2, [r2]
	strb	r2, [r3]
	ldr	r3, .L214+8
	ldr	r3, [r3, #52]
	movs	r2, #175
	lsls	r2, r2, #2
	adds	r2, r7, r2
	str	r3, [r2]
	movs	r3, #0
	movs	r2, #174
	lsls	r2, r2, #2
	adds	r2, r7, r2
	str	r3, [r2]
	b	.L133
.L135:
	movs	r3, #164
	lsls	r3, r3, #2
	adds	r3, r7, r3
	ldrb	r2, [r3]
	movs	r1, #174
	lsls	r1, r1, #2
	adds	r3, r7, r1
	ldr	r3, [r3]
	asrs	r2, r2, r3
	movs	r3, r2
	movs	r2, #1
	ands	r3, r2
	beq	.L134
	adds	r3, r7, r1
	ldr	r3, [r3]
	lsls	r2, r3, #2
	ldr	r3, .L214+8
	adds	r3, r2, r3
	movs	r4, #175
	lsls	r4, r4, #2
	adds	r2, r7, r4
	ldr	r2, [r2]
	movs	r1, r2
	movs	r0, r3
	bl	load_from_memory
	movs	r2, r4
	adds	r3, r7, r2
	ldr	r3, [r3]
	adds	r3, r3, #4
	adds	r2, r7, r2
	str	r3, [r2]
.L134:
	movs	r2, #174
	lsls	r2, r2, #2
	adds	r3, r7, r2
	ldr	r3, [r3]
	adds	r3, r3, #1
	adds	r2, r7, r2
	str	r3, [r2]
.L133:
	movs	r3, #174
	lsls	r3, r3, #2
	adds	r3, r7, r3
	ldr	r3, [r3]
	cmp	r3, #7
	ble	.L135
	ldr	r3, .L214+24
	adds	r3, r7, r3
	ldrb	r3, [r3]
	cmp	r3, #1
	bne	.L136
	movs	r4, #175
	lsls	r4, r4, #2
	adds	r3, r7, r4
	ldr	r2, [r3]
	ldr	r3, .L214+28
	movs	r1, r2
	movs	r0, r3
	bl	load_from_memory
	movs	r2, r4
	adds	r3, r7, r2
	ldr	r3, [r3]
	adds	r3, r3, #4
	adds	r2, r7, r2
	str	r3, [r2]
.L136:
	movs	r3, #175
	lsls	r3, r3, #2
	adds	r3, r7, r3
	ldr	r2, [r3]
	ldr	r3, .L214+8
	str	r2, [r3, #52]
	movs	r3, #0
	b	.L60
.L132:
	ldr	r0, .L214
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #12
	uxth	r3, r3
	movs	r2, r3
	movs	r3, #15
	ands	r3, r2
	cmp	r3, #13
	beq	.LCB5761
	b	.L137	@long jump
.LCB5761:
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #8
	uxth	r3, r3
	movs	r2, r3
	movs	r3, #15
	ands	r3, r2
	cmp	r3, #13
	ble	.LCB5771
	b	.L137	@long jump
.LCB5771:
	ldr	r3, .L214+8
	ldr	r3, [r3, #64]
	lsrs	r2, r3, #31
	ldr	r3, .L214+32
	adds	r3, r7, r3
	strb	r2, [r3]
	ldr	r3, .L214+8
	ldr	r3, [r3, #64]
	asrs	r3, r3, #30
	uxtb	r2, r3
	movs	r3, #169
	lsls	r3, r3, #2
	adds	r3, r7, r3
	movs	r1, #1
	ands	r2, r1
	strb	r2, [r3]
	ldr	r3, .L214+8
	ldr	r3, [r3, #64]
	asrs	r3, r3, #29
	uxtb	r2, r3
	ldr	r3, .L214+36
	adds	r3, r7, r3
	movs	r1, #1
	ands	r2, r1
	strb	r2, [r3]
	ldr	r3, .L214+8
	ldr	r3, [r3, #64]
	asrs	r3, r3, #28
	uxtb	r2, r3
	ldr	r3, .L214+40
	adds	r3, r7, r3
	movs	r1, #1
	ands	r2, r1
	strb	r2, [r3]
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #8
	uxth	r3, r3
	uxtb	r2, r3
	ldr	r0, .L214+44
	adds	r3, r7, r0
	movs	r1, #15
	ands	r2, r1
	strb	r2, [r3]
	movs	r3, #0
	movs	r2, #173
	lsls	r2, r2, #2
	adds	r2, r7, r2
	str	r3, [r2]
	adds	r3, r7, r0
	ldrb	r3, [r3]
	cmp	r3, #13
	bls	.LCB5826
	b	.L138	@long jump
.LCB5826:
	lsls	r2, r3, #2
	ldr	r3, .L214+48
	adds	r3, r2, r3
	ldr	r3, [r3]
	mov	pc, r3
	.section	.rodata
	.align	2
.L140:
	.word	.L153
	.word	.L152
	.word	.L151
	.word	.L150
	.word	.L149
	.word	.L148
	.word	.L147
	.word	.L146
	.word	.L145
	.word	.L144
	.word	.L143
	.word	.L142
	.word	.L141
	.word	.L139
	.text
.L153:
	movs	r3, #169
	lsls	r3, r3, #2
	adds	r3, r7, r3
	ldrb	r3, [r3]
	cmp	r3, #1
	beq	.LCB5843
	b	.L180	@long jump
.LCB5843:
	movs	r3, #1
	movs	r2, #173
	lsls	r2, r2, #2
	adds	r2, r7, r2
	str	r3, [r2]
	b	.L180
.L152:
	movs	r3, #169
	lsls	r3, r3, #2
	adds	r3, r7, r3
	ldrb	r3, [r3]
	cmp	r3, #0
	beq	.LCB5858
	b	.L181	@long jump
.LCB5858:
	movs	r3, #1
	movs	r2, #173
	lsls	r2, r2, #2
	adds	r2, r7, r2
	str	r3, [r2]
	b	.L181
.L151:
	ldr	r3, .L214+36
	adds	r3, r7, r3
	ldrb	r3, [r3]
	cmp	r3, #1
	beq	.LCB5872
	b	.L182	@long jump
.LCB5872:
	movs	r3, #1
	movs	r2, #173
	lsls	r2, r2, #2
	adds	r2, r7, r2
	str	r3, [r2]
	b	.L182
.L150:
	ldr	r3, .L214+36
	adds	r3, r7, r3
	ldrb	r3, [r3]
	cmp	r3, #0
	beq	.LCB5886
	b	.L183	@long jump
.LCB5886:
	movs	r3, #1
	movs	r2, #173
	lsls	r2, r2, #2
	adds	r2, r7, r2
	str	r3, [r2]
	b	.L183
.L149:
	ldr	r3, .L214+32
	adds	r3, r7, r3
	ldrb	r3, [r3]
	cmp	r3, #1
	beq	.LCB5900
	b	.L184	@long jump
.LCB5900:
	movs	r3, #1
	movs	r2, #173
	lsls	r2, r2, #2
	adds	r2, r7, r2
	str	r3, [r2]
	b	.L184
.L148:
	ldr	r3, .L214+32
	adds	r3, r7, r3
	ldrb	r3, [r3]
	cmp	r3, #0
	beq	.LCB5914
	b	.L185	@long jump
.LCB5914:
	movs	r3, #1
	movs	r2, #173
	lsls	r2, r2, #2
	adds	r2, r7, r2
	str	r3, [r2]
	b	.L185
.L215:
	.align	2
.L214:
	.word	678
	.word	647
	.word	cpu
	.word	653
	.word	655
	.word	654
	.word	657
	.word	cpu+60
	.word	677
	.word	675
	.word	674
	.word	673
	.word	.L140
.L147:
	ldr	r3, .L216
	adds	r3, r7, r3
	ldrb	r3, [r3]
	cmp	r3, #1
	beq	.LCB5946
	b	.L186	@long jump
.LCB5946:
	movs	r3, #1
	movs	r2, #173
	lsls	r2, r2, #2
	adds	r2, r7, r2
	str	r3, [r2]
	b	.L186
.L146:
	ldr	r3, .L216
	adds	r3, r7, r3
	ldrb	r3, [r3]
	cmp	r3, #0
	beq	.LCB5960
	b	.L187	@long jump
.LCB5960:
	movs	r3, #1
	movs	r2, #173
	lsls	r2, r2, #2
	adds	r2, r7, r2
	str	r3, [r2]
	b	.L187
.L145:
	ldr	r3, .L216+4
	adds	r3, r7, r3
	ldrb	r3, [r3]
	cmp	r3, #1
	beq	.LCB5974
	b	.L188	@long jump
.LCB5974:
	movs	r3, #169
	lsls	r3, r3, #2
	adds	r3, r7, r3
	ldrb	r3, [r3]
	cmp	r3, #0
	beq	.LCB5980
	b	.L188	@long jump
.LCB5980:
	movs	r3, #1
	movs	r2, #173
	lsls	r2, r2, #2
	adds	r2, r7, r2
	str	r3, [r2]
	b	.L188
.L144:
	ldr	r3, .L216+4
	adds	r3, r7, r3
	ldrb	r3, [r3]
	cmp	r3, #0
	beq	.L163
	movs	r3, #169
	lsls	r3, r3, #2
	adds	r3, r7, r3
	ldrb	r3, [r3]
	cmp	r3, #1
	bne	.L189
.L163:
	movs	r3, #1
	movs	r2, #173
	lsls	r2, r2, #2
	adds	r2, r7, r2
	str	r3, [r2]
	b	.L189
.L143:
	ldr	r3, .L216+8
	adds	r2, r7, r3
	ldr	r3, .L216
	adds	r3, r7, r3
	ldrb	r2, [r2]
	ldrb	r3, [r3]
	cmp	r2, r3
	bne	.L190
	movs	r3, #1
	movs	r2, #173
	lsls	r2, r2, #2
	adds	r2, r7, r2
	str	r3, [r2]
	b	.L190
.L142:
	ldr	r3, .L216+8
	adds	r2, r7, r3
	ldr	r3, .L216
	adds	r3, r7, r3
	ldrb	r2, [r2]
	ldrb	r3, [r3]
	cmp	r2, r3
	beq	.L191
	movs	r3, #1
	movs	r2, #173
	lsls	r2, r2, #2
	adds	r2, r7, r2
	str	r3, [r2]
	b	.L191
.L141:
	movs	r3, #169
	lsls	r3, r3, #2
	adds	r3, r7, r3
	ldrb	r3, [r3]
	cmp	r3, #0
	bne	.L192
	ldr	r3, .L216+8
	adds	r2, r7, r3
	ldr	r3, .L216
	adds	r3, r7, r3
	ldrb	r2, [r2]
	ldrb	r3, [r3]
	cmp	r2, r3
	bne	.L192
	movs	r3, #1
	movs	r2, #173
	lsls	r2, r2, #2
	adds	r2, r7, r2
	str	r3, [r2]
	b	.L192
.L139:
	movs	r3, #169
	lsls	r3, r3, #2
	adds	r3, r7, r3
	ldrb	r3, [r3]
	cmp	r3, #1
	beq	.L168
	ldr	r3, .L216+8
	adds	r2, r7, r3
	ldr	r3, .L216
	adds	r3, r7, r3
	ldrb	r2, [r2]
	ldrb	r3, [r3]
	cmp	r2, r3
	beq	.L193
.L168:
	movs	r3, #1
	movs	r2, #173
	lsls	r2, r2, #2
	adds	r2, r7, r2
	str	r3, [r2]
	b	.L193
.L180:
	nop
	b	.L138
.L181:
	nop
	b	.L138
.L182:
	nop
	b	.L138
.L183:
	nop
	b	.L138
.L184:
	nop
	b	.L138
.L185:
	nop
	b	.L138
.L186:
	nop
	b	.L138
.L187:
	nop
	b	.L138
.L188:
	nop
	b	.L138
.L189:
	nop
	b	.L138
.L190:
	nop
	b	.L138
.L191:
	nop
	b	.L138
.L192:
	nop
	b	.L138
.L193:
	nop
.L138:
	movs	r3, #173
	lsls	r3, r3, #2
	adds	r3, r7, r3
	ldr	r3, [r3]
	cmp	r3, #1
	bne	.L170
	movs	r1, #168
	lsls	r1, r1, #2
	adds	r3, r7, r1
	ldr	r2, .L216+12
	adds	r2, r7, r2
	ldrh	r2, [r2]
	strb	r2, [r3]
	ldr	r3, .L216+16
	ldr	r2, [r3, #60]
	adds	r3, r7, r1
	ldrb	r3, [r3]
	sxtb	r3, r3
	adds	r3, r3, #1
	lsls	r3, r3, #1
	adds	r2, r2, r3
	ldr	r3, .L216+16
	str	r2, [r3, #60]
.L170:
	movs	r3, #0
	b	.L60
.L137:
	ldr	r1, .L216+12
	adds	r3, r7, r1
	ldrh	r3, [r3]
	lsrs	r3, r3, #11
	uxth	r3, r3
	movs	r2, r3
	movs	r3, #31
	ands	r3, r2
	cmp	r3, #28
	bne	.L171
	movs	r0, r1
	adds	r3, r7, r1
	movs	r2, #0
	ldrsh	r2, [r3, r2]
	ldr	r1, .L216+20
	adds	r3, r7, r1
	lsls	r2, r2, #21
	lsrs	r2, r2, #21
	strh	r2, [r3]
	adds	r3, r7, r0
	ldrh	r3, [r3]
	lsrs	r3, r3, #10
	uxth	r3, r3
	movs	r2, r3
	movs	r3, #1
	ands	r3, r2
	beq	.L172
	adds	r3, r7, r1
	movs	r2, #0
	ldrsh	r3, [r3, r2]
	lsls	r2, r3, #5
	adds	r3, r7, r1
	strh	r2, [r3]
	adds	r3, r7, r1
	adds	r2, r7, r1
	movs	r1, #0
	ldrsh	r2, [r2, r1]
	asrs	r2, r2, #5
	strh	r2, [r3]
.L172:
	ldr	r3, .L216+16
	ldr	r2, [r3, #60]
	ldr	r3, .L216+20
	adds	r3, r7, r3
	movs	r1, #0
	ldrsh	r3, [r3, r1]
	adds	r3, r3, #1
	lsls	r3, r3, #1
	adds	r2, r2, r3
	ldr	r3, .L216+16
	str	r2, [r3, #60]
	movs	r3, #0
	b	.L60
.L171:
	ldr	r1, .L216+12
	adds	r3, r7, r1
	ldrh	r3, [r3]
	lsrs	r3, r3, #11
	uxth	r3, r3
	movs	r2, r3
	movs	r3, #31
	ands	r3, r2
	cmp	r3, #29
	bne	.L173
	adds	r3, r7, r1
	ldrh	r3, [r3]
	lsrs	r3, r3, #1
	uxth	r3, r3
	lsls	r3, r3, #22
	lsrs	r3, r3, #22
	movs	r2, #165
	lsls	r2, r2, #2
	adds	r2, r7, r2
	str	r3, [r2]
	ldr	r3, .L216+16
	ldr	r3, [r3, #60]
	subs	r3, r3, #6
	ldr	r2, .L216+24
	ldrb	r3, [r2, r3]
	sxth	r2, r3
	ldr	r3, .L216+16
	ldr	r3, [r3, #60]
	subs	r3, r3, #5
	ldr	r1, .L216+24
	ldrb	r3, [r1, r3]
	lsls	r3, r3, #8
	sxth	r3, r3
	orrs	r3, r2
	sxth	r2, r3
	ldr	r1, .L216+28
	adds	r3, r7, r1
	strh	r2, [r3]
	adds	r3, r7, r1
	ldrh	r3, [r3]
	lsrs	r3, r3, #11
	uxth	r3, r3
	movs	r2, r3
	movs	r3, #31
	ands	r3, r2
	cmp	r3, #30
	beq	.L174
	ldr	r3, .L216+32
	ldr	r3, [r3]
	ldr	r0, [r3, #12]
	ldr	r3, .L216+16
	ldr	r3, [r3, #60]
	subs	r2, r3, #4
	adds	r3, r7, r1
	ldrh	r3, [r3]
	ldr	r1, .L216+36
	bl	fprintf
	movs	r3, #1
	b	.L60
.L174:
	ldr	r3, .L216+28
	adds	r3, r7, r3
	ldrh	r3, [r3]
	lsls	r3, r3, #21
	lsrs	r3, r3, #21
	movs	r1, #171
	lsls	r1, r1, #2
	adds	r2, r7, r1
	str	r3, [r2]
	adds	r3, r7, r1
	ldr	r3, [r3]
	asrs	r3, r3, #10
	movs	r2, #1
	ands	r3, r2
	beq	.L175
	adds	r3, r7, r1
	ldr	r3, [r3]
	lsls	r3, r3, #21
	adds	r2, r7, r1
	str	r3, [r2]
	adds	r3, r7, r1
	ldr	r3, [r3]
	asrs	r3, r3, #21
	adds	r2, r7, r1
	str	r3, [r2]
.L175:
	ldr	r3, .L216+16
	ldr	r2, [r3, #60]
	ldr	r3, .L216+16
	str	r2, [r3, #56]
	ldr	r3, .L216+16
	ldr	r2, [r3, #60]
	movs	r3, #171
	lsls	r3, r3, #2
	adds	r3, r7, r3
	ldr	r3, [r3]
	lsls	r3, r3, #12
	adds	r2, r2, r3
	movs	r3, #165
	lsls	r3, r3, #2
	adds	r3, r7, r3
	ldr	r3, [r3]
	lsls	r3, r3, #2
	adds	r3, r2, r3
	movs	r2, #3
	bics	r3, r2
	movs	r2, r3
	ldr	r3, .L216+16
	str	r2, [r3, #60]
	movs	r3, #0
	b	.L60
.L173:
	ldr	r3, .L216+12
	adds	r3, r7, r3
	ldrh	r3, [r3]
	lsrs	r3, r3, #11
	uxth	r3, r3
	movs	r2, r3
	movs	r3, #31
	ands	r3, r2
	cmp	r3, #30
	bne	.L176
	movs	r3, #0
	b	.L60
.L176:
	ldr	r1, .L216+12
	adds	r3, r7, r1
	ldrh	r3, [r3]
	lsrs	r3, r3, #11
	uxth	r3, r3
	movs	r2, r3
	movs	r3, #31
	ands	r3, r2
	cmp	r3, #31
	beq	.LCB6401
	b	.L177	@long jump
.LCB6401:
	adds	r3, r7, r1
	ldrh	r3, [r3]
	lsls	r3, r3, #21
	lsrs	r3, r3, #21
	movs	r2, #167
	lsls	r2, r2, #2
	adds	r2, r7, r2
	str	r3, [r2]
	ldr	r3, .L216+16
	ldr	r3, [r3, #60]
	subs	r3, r3, #6
	ldr	r2, .L216+24
	ldrb	r3, [r2, r3]
	sxth	r2, r3
	ldr	r3, .L216+16
	ldr	r3, [r3, #60]
	subs	r3, r3, #5
	ldr	r1, .L216+24
	ldrb	r3, [r1, r3]
	lsls	r3, r3, #8
	sxth	r3, r3
	orrs	r3, r2
	sxth	r2, r3
	ldr	r1, .L216+40
	adds	r3, r7, r1
	strh	r2, [r3]
	adds	r3, r7, r1
	ldrh	r3, [r3]
	lsrs	r3, r3, #11
	uxth	r3, r3
	movs	r2, r3
	movs	r3, #31
	ands	r3, r2
	cmp	r3, #30
	beq	.L178
	ldr	r3, .L216+32
	ldr	r3, [r3]
	ldr	r0, [r3, #12]
	ldr	r3, .L216+16
	ldr	r3, [r3, #60]
	subs	r2, r3, #4
	adds	r3, r7, r1
	ldrh	r3, [r3]
	ldr	r1, .L216+36
	bl	fprintf
	movs	r3, #1
	b	.L60
.L217:
	.align	2
.L216:
	.word	674
	.word	675
	.word	677
	.word	678
	.word	cpu
	.word	690
	.word	rom
	.word	658
	.word	_impure_ptr
	.word	.LC30
	.word	666
.L178:
	ldr	r3, .L218
	adds	r3, r7, r3
	ldrh	r3, [r3]
	lsls	r3, r3, #21
	lsrs	r3, r3, #21
	movs	r1, #170
	lsls	r1, r1, #2
	adds	r2, r7, r1
	str	r3, [r2]
	adds	r3, r7, r1
	ldr	r3, [r3]
	asrs	r3, r3, #10
	movs	r2, #1
	ands	r3, r2
	beq	.L179
	adds	r3, r7, r1
	ldr	r3, [r3]
	lsls	r3, r3, #21
	adds	r2, r7, r1
	str	r3, [r2]
	adds	r3, r7, r1
	ldr	r3, [r3]
	asrs	r3, r3, #21
	adds	r2, r7, r1
	str	r3, [r2]
.L179:
	ldr	r3, .L218+4
	ldr	r2, [r3, #60]
	ldr	r3, .L218+4
	str	r2, [r3, #56]
	ldr	r3, .L218+4
	ldr	r2, [r3, #60]
	movs	r3, #170
	lsls	r3, r3, #2
	adds	r3, r7, r3
	ldr	r3, [r3]
	lsls	r1, r3, #12
	movs	r3, #167
	lsls	r3, r3, #2
	adds	r3, r7, r3
	ldr	r3, [r3]
	lsls	r3, r3, #1
	adds	r3, r1, r3
	adds	r2, r2, r3
	ldr	r3, .L218+4
	str	r2, [r3, #60]
	movs	r3, #0
	b	.L60
.L177:
	ldr	r3, .L218+8
	ldr	r3, [r3]
	ldr	r0, [r3, #12]
	ldr	r3, .L218+4
	ldr	r3, [r3, #60]
	subs	r2, r3, #4
	ldr	r3, .L218+12
	adds	r3, r7, r3
	ldrh	r3, [r3]
	ldr	r1, .L218+16
	bl	fprintf
	movs	r3, #1
.L60:
	movs	r0, r3
	mov	sp, r7
	movs	r3, #179
	lsls	r3, r3, #2
	add	sp, sp, r3
	@ sp needed
	pop	{r4, r5, r6, r7, pc}
.L219:
	.align	2
.L218:
	.word	666
	.word	cpu
	.word	_impure_ptr
	.word	678
	.word	.LC32
	.size	execute_next, .-execute_next
	.section	.rodata
	.align	2
.LC36:
	.ascii	"\033[2J\033[1;1H\000"
	.align	2
.LC38:
	.ascii	"Debug instruction!\000"
	.align	2
.LC40:
	.ascii	"Note: This is a branch prefix instruction\000"
	.align	2
.LC42:
	.ascii	"Next instruction: 0x%04x @ 0x%08x \012\012\000"
	.align	2
.LC44:
	.ascii	"\033[32m\000"
	.align	2
.LC46:
	.ascii	"R0 (hex)\011R1 (hex)\011R2 (hex)\011R3 (hex)\000"
	.align	2
.LC48:
	.ascii	"\033[97m\000"
	.align	2
.LC50:
	.ascii	"%-8x\011%-8x\011%-8x\011%-8x\012\000"
	.align	2
.LC52:
	.ascii	"R4 (hex)\011R5 (hex)\011R6 (hex)\011R7 (hex)\000"
	.align	2
.LC54:
	.ascii	"R8 (hex)\011R9 (hex)\011R10 (hex)\011R11 (hex)\000"
	.align	2
.LC56:
	.ascii	"R12 (hex)\011SP (hex)\011LR (hex)\011PC (hex)\000"
	.align	2
.LC58:
	.ascii	"FLG_N (hex)\011FLG_Z (hex)\011FLG_C (hex)\011FLG_V "
	.ascii	"(hex)\000"
	.align	2
.LC60:
	.ascii	"\033[37m\000"
	.align	2
.LC62:
	.ascii	"\012\012To print memory from 100 to 200 (hex), type"
	.ascii	" 100-200\000"
	.align	2
.LC64:
	.ascii	"To continue to program, type q\000"
	.align	2
.LC66:
	.ascii	"To disassemble, type d\000"
	.align	2
.LC68:
	.ascii	"%s\000"
	.align	2
.LC70:
	.ascii	"Exited debug mode\000"
	.align	2
.LC72:
	.ascii	"arm-none-eabi-objdump -d armapp.elf\000"
	.align	2
.LC74:
	.ascii	"%x-%x\000"
	.align	2
.LC76:
	.ascii	"Memory %x - %x (inclusive): (%d bytes)\012\012\000"
	.align	2
.LC79:
	.ascii	"Not in ROM or RAM.\000"
	.align	2
.LC81:
	.ascii	"\012%08x\011\000"
	.align	2
.LC83:
	.ascii	"%02x\000"
	.align	2
.LC85:
	.ascii	"'%01c'  \000"
	.align	2
.LC87:
	.ascii	"     \000"
	.text
	.align	1
	.global	debug_dialog
	.syntax unified
	.code	16
	.thumb_func
	.fpu softvfp
	.type	debug_dialog, %function
debug_dialog:
	@ args = 0, pretend = 0, frame = 120
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r4, r7, lr}
	sub	sp, sp, #132
	add	r7, sp, #8
	ldr	r3, .L237
	ldr	r3, [r3, #60]
	subs	r3, r3, #4
	ldr	r2, .L237+4
	ldrb	r3, [r2, r3]
	sxth	r2, r3
	ldr	r3, .L237
	ldr	r3, [r3, #60]
	subs	r3, r3, #3
	ldr	r1, .L237+4
	ldrb	r3, [r1, r3]
	lsls	r3, r3, #8
	sxth	r3, r3
	orrs	r3, r2
	sxth	r2, r3
	movs	r4, #112
	adds	r3, r7, r4
	strh	r2, [r3]
	ldr	r3, .L237
	ldr	r3, [r3, #64]
	lsrs	r2, r3, #31
	movs	r3, #111
	adds	r3, r7, r3
	strb	r2, [r3]
	ldr	r3, .L237
	ldr	r3, [r3, #64]
	asrs	r3, r3, #30
	uxtb	r2, r3
	movs	r3, #110
	adds	r3, r7, r3
	movs	r1, #1
	ands	r2, r1
	strb	r2, [r3]
	ldr	r3, .L237
	ldr	r3, [r3, #64]
	asrs	r3, r3, #29
	uxtb	r2, r3
	movs	r3, #109
	adds	r3, r7, r3
	movs	r1, #1
	ands	r2, r1
	strb	r2, [r3]
	ldr	r3, .L237
	ldr	r3, [r3, #64]
	asrs	r3, r3, #28
	uxtb	r2, r3
	movs	r3, #108
	adds	r3, r7, r3
	movs	r1, #1
	ands	r2, r1
	strb	r2, [r3]
	ldr	r3, .L237+8
	movs	r0, r3
	bl	puts
	ldr	r3, .L237+12
	movs	r0, r3
	bl	puts
	adds	r3, r7, r4
	ldrh	r3, [r3]
	lsrs	r3, r3, #11
	uxth	r3, r3
	movs	r2, r3
	movs	r3, #31
	ands	r3, r2
	cmp	r3, #30
	bne	.L221
	ldr	r3, .L237+16
	movs	r0, r3
	bl	puts
.L221:
	movs	r3, #112
	adds	r3, r7, r3
	ldrh	r1, [r3]
	ldr	r3, .L237
	ldr	r3, [r3, #60]
	subs	r2, r3, #4
	ldr	r3, .L237+20
	movs	r0, r3
	bl	printf
	ldr	r3, .L237+24
	movs	r0, r3
	bl	printf
	ldr	r3, .L237+28
	movs	r0, r3
	bl	puts
	ldr	r3, .L237+32
	movs	r0, r3
	bl	printf
	ldr	r3, .L237
	ldr	r1, [r3]
	ldr	r3, .L237
	ldr	r2, [r3, #4]
	ldr	r3, .L237
	ldr	r4, [r3, #8]
	ldr	r3, .L237
	ldr	r3, [r3, #12]
	ldr	r0, .L237+36
	str	r3, [sp]
	movs	r3, r4
	bl	printf
	ldr	r3, .L237+24
	movs	r0, r3
	bl	printf
	ldr	r3, .L237+40
	movs	r0, r3
	bl	puts
	ldr	r3, .L237+32
	movs	r0, r3
	bl	printf
	ldr	r3, .L237
	ldr	r1, [r3, #16]
	ldr	r3, .L237
	ldr	r2, [r3, #20]
	ldr	r3, .L237
	ldr	r4, [r3, #24]
	ldr	r3, .L237
	ldr	r3, [r3, #28]
	ldr	r0, .L237+36
	str	r3, [sp]
	movs	r3, r4
	bl	printf
	ldr	r3, .L237+24
	movs	r0, r3
	bl	printf
	ldr	r3, .L237+44
	movs	r0, r3
	bl	puts
	ldr	r3, .L237+32
	movs	r0, r3
	bl	printf
	ldr	r3, .L237
	ldr	r1, [r3, #32]
	ldr	r3, .L237
	ldr	r2, [r3, #36]
	ldr	r3, .L237
	ldr	r4, [r3, #40]
	ldr	r3, .L237
	ldr	r3, [r3, #44]
	ldr	r0, .L237+36
	str	r3, [sp]
	movs	r3, r4
	bl	printf
	ldr	r3, .L237+24
	movs	r0, r3
	bl	printf
	ldr	r3, .L237+48
	movs	r0, r3
	bl	puts
	ldr	r3, .L237+32
	movs	r0, r3
	bl	printf
	ldr	r3, .L237
	ldr	r1, [r3, #48]
	ldr	r3, .L237
	ldr	r2, [r3, #52]
	ldr	r3, .L237
	ldr	r4, [r3, #56]
	ldr	r3, .L237
	ldr	r3, [r3, #60]
	ldr	r0, .L237+36
	str	r3, [sp]
	movs	r3, r4
	bl	printf
	ldr	r3, .L237+24
	movs	r0, r3
	bl	printf
	ldr	r3, .L237+52
	movs	r0, r3
	bl	puts
	ldr	r3, .L237+32
	movs	r0, r3
	bl	printf
	movs	r3, #111
	adds	r3, r7, r3
	ldrb	r1, [r3]
	movs	r3, #110
	adds	r3, r7, r3
	ldrb	r2, [r3]
	movs	r3, #109
	adds	r3, r7, r3
	ldrb	r4, [r3]
	movs	r3, #108
	adds	r3, r7, r3
	ldrb	r3, [r3]
	ldr	r0, .L237+36
	str	r3, [sp]
	movs	r3, r4
	bl	printf
.L222:
.L235:
	ldr	r3, .L237+56
	movs	r0, r3
	bl	printf
	ldr	r3, .L237+60
	movs	r0, r3
	bl	puts
	ldr	r3, .L237+64
	movs	r0, r3
	bl	puts
	ldr	r3, .L237+68
	movs	r0, r3
	bl	puts
	ldr	r3, .L237+32
	movs	r0, r3
	bl	printf
	movs	r2, r7
	ldr	r3, .L237+72
	movs	r1, r2
	movs	r0, r3
	bl	scanf
	movs	r3, r7
	ldrb	r3, [r3]
	cmp	r3, #113
	bne	.L223
	ldr	r3, .L237+76
	movs	r0, r3
	bl	puts
	b	.L236
.L223:
	movs	r3, r7
	ldrb	r3, [r3]
	cmp	r3, #100
	bne	.L224
	ldr	r3, .L237+80
	movs	r0, r3
	bl	system
	b	.L235
.L224:
	movs	r3, #100
	adds	r3, r7, r3
	movs	r2, #104
	adds	r2, r7, r2
	ldr	r1, .L237+84
	movs	r0, r7
	bl	sscanf
	ldr	r1, [r7, #104]
	ldr	r4, [r7, #100]
	ldr	r2, [r7, #100]
	ldr	r3, [r7, #104]
	subs	r3, r2, r3
	adds	r3, r3, #1
	ldr	r0, .L237+88
	movs	r2, r4
	bl	printf
	ldr	r3, .L237+24
	movs	r0, r3
	bl	printf
	movs	r3, #0
	str	r3, [r7, #116]
	b	.L226
.L234:
	ldr	r3, [r7, #104]
	ldr	r2, .L237+92
	cmp	r3, r2
	bhi	.L227
	ldr	r2, [r7, #104]
	movs	r3, #115
	adds	r3, r7, r3
	ldr	r1, .L237+4
	ldrb	r2, [r1, r2]
	strb	r2, [r3]
	b	.L228
.L227:
	ldr	r3, [r7, #104]
	ldr	r2, .L237+96
	cmp	r3, r2
	bhi	.L229
	ldr	r3, [r7, #104]
	movs	r2, #224
	lsls	r2, r2, #24
	adds	r2, r3, r2
	movs	r3, #115
	adds	r3, r7, r3
	ldr	r1, .L237+100
	ldrb	r2, [r1, r2]
	strb	r2, [r3]
	b	.L228
.L229:
	ldr	r3, .L237+104
	movs	r0, r3
	bl	puts
	b	.L235
.L228:
	ldr	r3, [r7, #104]
	movs	r2, #7
	ands	r3, r2
	bne	.L230
	movs	r3, #0
	str	r3, [r7, #116]
.L230:
	ldr	r3, [r7, #116]
	movs	r2, #7
	ands	r3, r2
	bne	.L231
	ldr	r3, .L237+24
	movs	r0, r3
	bl	printf
	ldr	r2, [r7, #104]
	ldr	r3, .L237+108
	movs	r1, r2
	movs	r0, r3
	bl	printf
	ldr	r3, .L237+32
	movs	r0, r3
	bl	printf
.L231:
	movs	r4, #115
	adds	r3, r7, r4
	ldrb	r2, [r3]
	ldr	r3, .L237+112
	movs	r1, r2
	movs	r0, r3
	bl	printf
	ldr	r3, .L237+56
	movs	r0, r3
	bl	printf
	movs	r2, r4
	adds	r3, r7, r2
	ldrb	r3, [r3]
	cmp	r3, #31
	bls	.L232
	adds	r3, r7, r2
	ldrb	r3, [r3]
	cmp	r3, #176
	bhi	.L232
	adds	r3, r7, r2
	ldrb	r2, [r3]
	ldr	r3, .L237+116
	movs	r1, r2
	movs	r0, r3
	bl	printf
	b	.L233
.L232:
	ldr	r3, .L237+120
	movs	r0, r3
	bl	printf
.L233:
	ldr	r3, .L237+32
	movs	r0, r3
	bl	printf
	ldr	r3, [r7, #104]
	adds	r3, r3, #1
	str	r3, [r7, #104]
	ldr	r3, [r7, #116]
	adds	r3, r3, #1
	str	r3, [r7, #116]
.L226:
	ldr	r2, [r7, #104]
	ldr	r3, [r7, #100]
	cmp	r2, r3
	bls	.L234
	ldr	r3, .L237+32
	movs	r0, r3
	bl	puts
	b	.L235
.L236:
	mov	sp, r7
	add	sp, sp, #124
	@ sp needed
	pop	{r4, r7, pc}
.L238:
	.align	2
.L237:
	.word	cpu
	.word	rom
	.word	.LC36
	.word	.LC38
	.word	.LC40
	.word	.LC42
	.word	.LC44
	.word	.LC46
	.word	.LC48
	.word	.LC50
	.word	.LC52
	.word	.LC54
	.word	.LC56
	.word	.LC58
	.word	.LC60
	.word	.LC62
	.word	.LC64
	.word	.LC66
	.word	.LC68
	.word	.LC70
	.word	.LC72
	.word	.LC74
	.word	.LC76
	.word	536870910
	.word	1073741822
	.word	ram
	.word	.LC79
	.word	.LC81
	.word	.LC83
	.word	.LC85
	.word	.LC87
	.size	debug_dialog, .-debug_dialog
	.ident	"GCC: (Arch Repository) 10.1.0"
