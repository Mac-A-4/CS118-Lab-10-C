	.data

Radix:
	.float 10.0
_1:
	.float 1.0
Round_Sentinel:
	.float 0.000001

	.text
	.global StringToFloat
	.global FloatToString

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

	.equ FloatToString_Initial, -4
	.equ FloatToString_Sign, -8
	.equ FloatToString_Exponent, -12
	.equ FloatToString_Mantissa, -16

FloatToString:
	enter $16, $0
	movss %xmm0, FloatToString_Initial(%rbp)
	movl FloatToString_Initial(%rbp), %eax
	movl %eax, %ecx
	shrl $0x1F, %ecx
	andl $0x1, %ecx
	movl %ecx, FloatToString_Sign(%rbp)
	movl %eax, %ecx
	shrl $0x17, %ecx
	andl $0xFF, %ecx
	movl %ecx, FloatToString_Exponent(%rbp)
	movl %eax, %ecx
	andl $0x7FFFFF, %ecx
	movl %ecx, FloatToString_Mantissa(%rbp)
