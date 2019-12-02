	.text
	.global IntegerToString
	.global StringToInteger

IntegerToString_Reverse:
	push %r12
	movq %rdi, %r12
	call StrLen
	decq %rax
	xorq %rcx, %rcx
IntegerToString_Reverse_While_1:
	cmp %rax, %rcx
	jae IntegerToString_Reverse_While_2
	movb (%r12, %rax, 1), %r8b
	movb (%r12, %rcx, 1), %r9b
	movb %r8b, (%r12, %rcx, 1)
	movb %r9b, (%r12, %rax, 1)
	decq %rax
	incq %rcx
	jmp IntegerToString_Reverse_While_1
IntegerToString_Reverse_While_2:
	pop %r12
	ret

IntegerToString:
	test %rdi, %rdi
	jnz IntegerToString_NotZero
	movb $'0', (%rsi)
	movb $0, 1(%rsi)
	ret
IntegerToString_NotZero:
	xorq %r9, %r9
	xorq %r8, %r8
	movq $10, %rcx
	movq %rdi, %rax
	movq $0x8000000000000000, %rdx
	test %rdx, %rax
	jz IntegerToString_Positive_1
	movq $1, %r8
	negq %rax
IntegerToString_Positive_1:
IntegerToString_While_1:
	test %rax, %rax
	jz IntegerToString_While_2
	xorq %rdx, %rdx
	divq %rcx
	addq $'0', %rdx
	movb %dl, (%rsi, %r9, 1)
	incq %r9
	jmp IntegerToString_While_1
IntegerToString_While_2:
	test %r8, %r8
	jz IntegerToString_Positive_2
	movb $'-', (%rsi, %r9, 1)
	incq %r9
IntegerToString_Positive_2:
	movb $0, (%rsi, %r9, 1)
	movq %rsi, %rdi
	call IntegerToString_Reverse
	ret

StringToInteger:
	push %r12
	movq %rdi, %r12
	call StrLen
	movq %rax, %r9
	decq %r9
	movb $'-', %al
	movq $1, %r11
	xorq %r8, %r8
	cmp %al, (%r12)
	cmove %r11, %r8
	xorq %r10, %r10
	movq $10, %rcx
StringToInteger_While_1:
	cmp %r8, %r9
	jl StringToInteger_While_2
	movzbq (%r12, %r9, 1), %rax
	subq $'0', %rax
	mulq %r11
	addq %rax, %r10
	movq %r11, %rax
	mulq %rcx
	movq %rax, %r11
	decq %r9
	jmp StringToInteger_While_1
StringToInteger_While_2:
	test %r8, %r8
	jz StringToInteger_Positive
	negq %r10
StringToInteger_Positive:
	movq %r10, %rax
	pop %r12
	ret
