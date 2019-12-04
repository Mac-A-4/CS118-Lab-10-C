
/*
\vspace{5in}\clearpage
\marginnote{
In the Equation file, there are some important read-only data variables.
EQ1 is the first hardcoded segment of the equation format,
and EQ2 is the second hardcoded segment of the equation format.
The afformentioned format is a line equation format called point-slope.
It allows you to create a line equation from just a point and the slope, which is perfect for our needs.
}
*/

	.section .rodata

EQ1:
	.string "*(x-"
EQ2:
	.string ")+"

	.text
	.global Equation

/*
\vspace{5in}\clearpage
\marginnote{
The Concatenate function is merely a duplication of strcat, which is used by the Equation function to append strings together.
First, it loops through the destination string, and finds the null-terminator.
}
*/

Concatenate:
	xorq %rax, %rax
Concatenate_While_1:
	movb (%rsi, %rax, 1), %cl
	test %cl, %cl
	jz Concatenate_While_2
	incq %rax
	jmp Concatenate_While_1
Concatenate_While_2:

/*
\vspace{5in}\clearpage
\marginnote{
Then, it loops through the source string, copying it over into the destination string until a null-terminator is reached.
}
*/

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
	movb $0, (%rsi, %rax, 1)
	ret

/*
\vspace{5in}\clearpage
\marginnote{
The Equation function uses several local variables.
X is a storage location for the float value of X.
Y is a storage location for the float value of Y.
M is a storage location for the float value of the Slope.
XString is a string buffer, used to store the string representation of the float X.
YString is a string buffer, used to store the string representation of the float Y.
MString is a string buffer, used to store the string representation of the float M.
Output is a storage location for the pointer value of the output buffer.
}
*/

	.equ X, -4
	.equ Y, -8
	.equ M, -12
	.equ XString, -44
	.equ YString, -76
	.equ MString, -108
	.equ Output, -116

/*
\vspace{5in}\clearpage
\marginnote{
First, the function stores the arguments into local variables.
}
*/

Equation:
	enter $128, $0
	movq %rdi, Output(%rbp)
	movb $0, (%rdi)
	movss %xmm0, X(%rbp)
	movss %xmm1, Y(%rbp)
	movss %xmm2, M(%rbp)

/*
\vspace{5in}\clearpage
\marginnote{
Second, the function converts the three floating arguments into strings, and stores them into their respective string buffers.
}
*/

	lea XString(%rbp), %rdi
	call FloatToString
	movss Y(%rbp), %xmm0
	lea YString(%rbp), %rdi
	call FloatToString
	movss M(%rbp), %xmm0
	lea MString(%rbp), %rdi
	call FloatToString

/*
\vspace{5in}\clearpage
\marginnote{
The string then concatenates the strings, along with a few hardcoded strings, to make a point-slope equation that gnuplot will accept.
}
*/

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

