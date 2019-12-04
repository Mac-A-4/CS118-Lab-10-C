
/*
\vspace{5in}\clearpage
\marginnote{
In the stof file, the read-only data section contains a few entries.
Radix is just a constant, a float that equals 10, used for conversion.
\_1 is a constant, equaling 1, for utility purposes.
\_0 is a constant, equaling 0, for utility purposes.
}
*/

	.section .rodata

Radix:
	.float 10.0
_1:
	.float 1.0
_0:
	.float 0.0

	.text
	.global StringToFloat

/*
\vspace{5in}\clearpage
\marginnote{
When StringToFloat first enters, it sets rcx to zero, because it will be used as a for loop iterator.
Then, the function gets the index of the first decimal point in the string, and if there is none, the index is equal to the index of the null terminator.
}
*/

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

/*
\vspace{5in}\clearpage
\marginnote{
Then, the function sets xmm1 to 1, and multiplies it by the Radix based on how many characters were present before the index of the decimal point.
}
*/

	movss _1, %xmm1
stof_For_3:
	decq %rcx
	jz stof_For_4
	mulss Radix, %xmm1
	jmp stof_For_3
stof_For_4:

/*
\vspace{5in}\clearpage
\marginnote{
The function then sets rcx back to zero, because it will be used as a loop iterator.
It also sets xmm0 to zero because it will be used to accumulate the value of the string.
The function then loops through all numeric characters in the string, skipping decimal points, and dividing the base by 10 each time.
Each character is translated into a float and multiplied by the current base, and added onto the accumulator.
}
*/

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

/*
\vspace{5in}\clearpage
\marginnote{
Then, the function returns.
}
*/

	ret

