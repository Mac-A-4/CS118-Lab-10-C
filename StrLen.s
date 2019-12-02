	.text
	.global StrLen

StrLen:
	xorq %rax, %rax
StrLen_1:
	movb (%rdi, %rax, 1), %cl
	test %cl, %cl
	jz StrLen_2
	incq %rax
	jmp StrLen_1
StrLen_2:
	ret
