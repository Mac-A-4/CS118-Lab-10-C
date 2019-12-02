	.text
	.global Fork
	.global Execute
	.global Wait
	.global Spawn

	.equ SYS_FORK, 57
	.equ SYS_EXECVE, 59
	.equ SYS_WAIT4, 61

	.equ WAIT_STAT_LOC, -4
	.equ WAIT_OPTION, 0
	.equ WAIT_RUSAGE, -64

/*
\vspace{5in}\clearpage
\marginnote{
The objective of this function, Fork, is to act as a wrapper around the SYS\_FORK syscall.
All it does is pass the given arguments to the operating system.
}
*/

Fork:
	movq $SYS_FORK, %rax
	syscall
	ret

/*
\vspace{5in}\clearpage
\marginnote{
The objective of this function, Execute, is to act as a wrapper around the SYS\_EXECVE syscall.
All it does is pass the given arguments to the operating system.
}
*/

Execute:
	movq $SYS_EXECVE, %rax
	syscall

/*
\vspace{5in}\clearpage
\marginnote{
The objective of this function, Wait, is to simplify the usage of the SYS\_WAIT4 syscall.
It takes in the process ID of the forked process, and creates a memory location for the return value of the process to be stored.
It then passes the process id and a pointer to the memory location to the system.
Once the system call finishes, the function returns the return value stored in the memory location by SYS\_WAIT4.
}
*/

Wait:
	enter $128, $0
	lea WAIT_STAT_LOC(%rbp), %rsi
	movl $WAIT_OPTION, %edx
	lea WAIT_RUSAGE(%rbp), %rcx
	movq $SYS_WAIT4, %rax
	syscall
	movl WAIT_STAT_LOC(%rbp), %eax
	leave
	ret
