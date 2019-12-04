	.section .rodata

RADIXD:
	.double 10.0
RADIXF:
	.float 10.0
NEGATIVED:
	.double -1.0
NEGATIVEF:
	.float -1.0
ZEROF:
	.float 0.0

	.text
	.global FloatToString

	.equ Precision, 6
	.equ Radix, 10
	.equ Buffer, -64

FloatToString:
	comiss ZEROF, %xmm0
	jne ftos_Start
	movb $'0', (%rdi)
	movb $0, 1(%rdi)
	ret
ftos_Start:
	enter $64, $0
	xorq %rax, %rax
	cvtss2sd %xmm0, %xmm2
	movsd RADIXD, %xmm3
ftos_While_1:
	cmp $Precision, %rax
	je ftos_While_2
	mulsd %xmm3, %xmm2
	incq %rax
	jmp ftos_While_1
ftos_While_2:
	cvtsd2si %xmm2, %rax
	xorq %rcx, %rcx
	xorq %r8, %r8
	cmp $0, %rax
	jnl ftos_If_1
	movb $1, %r8b
	negq %rax
ftos_If_1:
ftos_While_3:
	test %rax, %rax
	jz ftos_While_4
	movq $Radix, %r9
	xorq %rdx, %rdx
	divq %r9
	addb $'0', %dl
	movb %dl, Buffer(%rbp, %rcx, 1)
	incq %rcx
	jmp ftos_While_3
ftos_While_4:
	test %r8, %r8
	jz ftos_If_2
	movb $'-', Buffer(%rbp, %rcx, 1)
	incq %rcx
ftos_If_2:
	xorq %r8, %r8
	movq %rcx, %r9
	decq %r9
ftos_While_5:
	cmp $0, %r9
	jl ftos_While_6
	movq %rcx, %r11
	movq $Precision, %rsi
	#decq %rsi
	subq %rsi, %r11
	cmp %r11, %r8
	jne ftos_If_3
	movb $'.', (%rdi, %r8, 1)
	incq %r8
ftos_If_3:
	movb Buffer(%rbp, %r9, 1), %r10b
	movb %r10b, (%rdi, %r8, 1)
	incq %r8
	decq %r9
	jmp ftos_While_5
ftos_While_6:
	movb $0, (%rdi, %r8, 1)
	leave
	ret
