	.text
	.global Print

Print:
	push %rdi
	call StrLen
	pop %rsi
	movq %rax, %rdx
	movq $1, %rdi
	movq $1, %rax
	syscall
	ret
