	.section .rodata

EQ1:
	.string "(x-"
EQ2:
	.string ")+"

	.text
	.global Equation

Concatenate:
	xorq %rax, %rax
Concatenate_While_1:
	movb (%rsi, %rax, 1), %cl
	test %cl, %cl
	jz Concatenate_While_2
	incq %rax
	jmp Concatenate_While_1
Concatenate_While_2:
	xorq %rcx, %rcx
Concatenate_While_3:
	movb (%rdi, %rcx, 1), %dl
	test %dl, %dl
	jz Concatenate_While_4
	movb %dl, (%rsi, %rax, 1)
	incq %rax
	incq %rcx
	jmp Concatenate_While_3
Concatenate_While_4:
	movb $0, (%rsi, %rcx, 1)
	ret

	.equ X, -4
	.equ Y, -8
	.equ M, -12
	.equ XString, -44
	.equ YString, -76
	.equ MString, -108
	.equ Output, -116

Equation:
	enter $128, $0
	movq %rdi, Output(%rbp)
	movss %xmm0, X(%rbp)
	movss %xmm1, Y(%rbp)
	movss %xmm2, M(%rbp)
	lea XString(%rbp), %rdi
	call FloatToString
	movss Y(%rbp), %xmm0
	lea YString(%rbp), %rdi
	call FloatToString
	movss M(%rbp), %xmm0
	lea MString(%rbp), %rdi
	call FloatToString
	movq Output(%rbp), %rsi
	lea MString(%rbp), %rdi
	call Concatenate
	movq Output(%rbp), %rsi
	lea EQ1, %rdi
	call Concatenate
	movq Output(%rbp), %rsi
	lea XString(%rbp), %rdi
	call Concatenate
	movq Output(%rbp), %rsi
	lea EQ2, %rdi
	call Concatenate
	movq Output(%rbp), %rsi
	lea YString(%rbp), %rdi
	call Concatenate
	leave
	ret

