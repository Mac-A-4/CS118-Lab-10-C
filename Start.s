	.data
	.global _argc_
	.global _argv_
	.global _envp_

_argc_: .long 0
_argv_: .quad 0
_envp_: .quad 0

	.text
	.global _start

/*
\vspace{5in}\clearpage
\marginnote{
The purpose of this implementation of \_start is to grab argc, argv, and envp off of the stack, place them in global variables, and pass them to main as arguments. After main has exited, \_start will call sys\_exit.
}
*/

_start:
	movl (%rsp), %edi
	lea 8(%rsp), %rsi
	lea 16(%rsp, %rdi, 8), %rdx
	movl %edi, _argc_
	movq %rsi, _argv_
	movq %rdx, _envp_
	call main
	movq %rax, %rdi
	movq $60, %rax
	syscall
