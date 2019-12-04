	.section .rodata

Radix:
	.float 10.0
_1:
	.float 1.0
_0:
	.float 0.0

	.text
	.global StringToFloat

StringToFloat:
	xorq %rcx, %rcx
stof_For_1:
	movb (%rdi, %rcx, 1), %al
	cmp $'.', %al
	je stof_For_2
	test %al, %al
	jz stof_For_2
	incq %rcx
	jmp stof_For_1
stof_For_2:
	movss _1, %xmm1
stof_For_3:
	decq %rcx
	jz stof_For_4
	mulss Radix, %xmm1
	jmp stof_For_3
stof_For_4:
	xorq %rcx, %rcx
	xorps %xmm0, %xmm0
stof_For_5:
	movzbq (%rdi, %rcx, 1), %rax
	cmp $'.', %rax
	je stof_Skip
	test %rax, %rax
	jz stof_For_6
	subq $'0', %rax
	cvtsi2ss %rax, %xmm2
	mulss %xmm1, %xmm2
	addss %xmm2, %xmm0
	divss Radix, %xmm1
stof_Skip:
	incq %rcx
	jmp stof_For_5
stof_For_6:
	ret

