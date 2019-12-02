	.text
	.global GetENV
	.global GetENVValue

/*
\vspace{5in}\clearpage
\marginnote{
The GetENV function is meant to parse through a list of environment pointers, and return a pointer to the one bearing the specified key.
Our use case would be only for QUERY\_STRING, but this function can be used to retrieve any environment pointer.
First, the function sets rcx to zero, because it will later be used as an iterator variable for a loop.
}
*/

GetENV:
	xorq %rcx, %rcx

/*
\vspace{5in}\clearpage
\marginnote{
This is the beginning of the outer loop in the GetENV function. It basically iterates through every single envp entry in the envp array until it reaches a null pointer.
}
*/

GetENV_While_1:
	movq (%rsi, %rcx, 8), %rax
	test %rax, %rax
	jz GetENV_Fail
	xorq %rdx, %rdx

/*
\vspace{5in}\clearpage
\marginnote{
This is the inner loop, its function is to take the current envp that the outer loop has provided it, and perform a simple string matching operation to determine whether or not the key is the one we are searching for.
It just goes through the environment variable until it either finds a non-matching character or a null pointer, and if it hits an equals sign before that, it will indicate success by returning a pointer to the environment variable.
}
*/

GetENV_For_1:
	movb (%rdi, %rdx, 1), %r8b
	movb (%rax, %rdx, 1), %r9b
	test %r8b, %r8b
	jnz GetENV_No_Success
	cmp $'=', %r9b
	jne GetENV_No_Success
	jmp GetENV_Success
GetENV_No_Success:
	test %r9b, %r9b
	jz GetENV_For_2
	cmp %r8b, %r9b
	jne GetENV_For_2
	incq %rdx
	jmp GetENV_For_1

/*
\vspace{5in}\clearpage
\marginnote{
This is the code that is executed whenever the inner loop finishes execution without finding a confirmed match.
All it does is increment the outer loop iterator variable rcx, and jump back to the start of the outer loop.
}
*/

GetENV_For_2:
	incq %rcx
	jmp GetENV_While_1

/*
\vspace{5in}\clearpage
\marginnote{
These are the labels that are jumped to to indicate either success or failiure.
If the failiure label is jumped to, rax is set to zero, and the function returns a null pointer.
If the success label is jumped to, the function just returns, because the current env variable is already in rax.
}
*/

GetENV_Fail:
	xorq %rax, %rax
GetENV_Success:
	ret

/*
\vspace{5in}\clearpage
\marginnote{
The GetENVValue function is essentially just a wrapper around the GetENV function.
All it does is call GetENV to get the start of the matchig environment pointer, and subsequently increments the pointer until the first equals sign in the environment string has been passed.
}
*/

GetENVValue:
	call GetENV
GetENVValue_While_1:
	movb (%rax), %cl
	cmp $'=', %cl
	je GetENVValue_Success
	incq %rax
	jmp GetENVValue_While_1
GetENVValue_Success:
	incq %rax
	ret

