
/*
\vspace{5in}\clearpage
\marginnote{
In the read-only data section of the ftos file, there are a few important constants to be noted.
RADIXD is a double equaling 10, used in conversion.
RADIXF is a float equaling 10, used in conversion.
NEGATIVED is a double equaling -1, used for flipping the sign of doubles.
NEGATIVEF is a float equaling -1, used for flipping the sign of floats.
ZEROF is a float equaling zero, used for checking if other floats are zero.
}
*/

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

/*
\vspace{5in}\clearpage
\marginnote{
The FloatToString function uses one local variable on its stack frame, Buffer.
Buffer is a string buffer, that is used during the function to contain an intermediate form of the final output,
before it is copied over and a null-terminator and decimal point are added.
Precision is a constant, defining how many decimal places the string should preserve.
Radix is a constant, because float strings are generally in base 10.
}
*/

	.text
	.global FloatToString

	.equ Precision, 6
	.equ Radix, 10
	.equ Buffer, -64

/*
\vspace{5in}\clearpage
\marginnote{
The objective of the FloatToString function is to convert a 32 bit float to a string.
First, it checks if the given float is zero, and if so, it writes a zero into the output buffer and returns.
}
*/

FloatToString:
	comiss ZEROF, %xmm0
	jne ftos_Start
	movb $'0', (%rdi)
	movb $0, 1(%rdi)
	ret

/*
\vspace{5in}\clearpage
\marginnote{
If the given float was not zero, the function will begin translating the float to a string.
First, the function converts the float to a double, to increase the range of numbers that can be represented.
Second, the function loops through and multiplies the given double by Radix, however many times the Precision constant requires.
}
*/

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

/*
\vspace{5in}\clearpage
\marginnote{
After the function has finished multiplying by Radix, it converts the freshly multiplied double into an integer, to ease conversion.
It then checks if the integer is negative, and if it is, it sets a flag and negates the value.
}
*/

	cvtsd2si %xmm2, %rax
	xorq %rcx, %rcx
	xorq %r8, %r8
	cmp $0, %rax
	jnl ftos_If_1
	movb $1, %r8b
	negq %rax
ftos_If_1:

/*
\vspace{5in}\clearpage
\marginnote{
Subsequently, the function loops through the integer, converting it into its string representation
and storing it in the intermediate output buffer on the stack.
}
*/

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

/*
\vspace{5in}\clearpage
\marginnote{
After conversion, the function checks if the afformentioned negative flag was set, and if so, it appends a negative sign.
Subsequently, it sets r8 to zero, because it will be used as an index for the final output buffer, and r9 to rcx, which is the number of characters in the intermediate buffer. It will be used to count down through the reversed intermediate buffer.
}
*/

	test %r8, %r8
	jz ftos_If_2
	movb $'-', Buffer(%rbp, %rcx, 1)
	incq %rcx
ftos_If_2:
	xorq %r8, %r8
	movq %rcx, %r9
	decq %r9

/*
\vspace{5in}\clearpage
\marginnote{
The function now has to copy the reversed characters from the intermediate buffer into the final buffer, and add a decimal point and null-terminator.
All this loop does is go through the intermediate buffer backwards, copying characters, and if the required position of a decimal place is met, a decimal point is also appended.
}
*/

ftos_While_5:
	cmp $0, %r9
	jl ftos_While_6
	movq %rcx, %r11
	movq $Precision, %rsi
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

/*
\vspace{5in}\clearpage
\marginnote{
Then, the function returns.
}
*/

	movb $0, (%rdi, %r8, 1)
	leave
	ret
