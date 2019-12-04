
/*
\vspace{5in}\clearpage
\marginnote{
The read-only data section of the main file consists of a few variables.
QUERY\_STRING is just a hardcoded string to search for in the environment variables.
X1 is a hardcoded string to search for within the query string, as well as Y1, X2, and Y2.
SLOPE is a hardcoded message.
}
*/

	.section .rodata

QUERY_STRING:
	.string "QUERY_STRING"

X1:
	.string "X1"
Y1:
	.string "Y1"
X2:
	.string "X2"
Y2:
	.string "Y2"
SLOPE:
	.string "Slope: "

	.text
	.global main

/*
\vspace{5in}\clearpage
\marginnote{
The main function uses multiple local variables.
QueryString holds a pointer to the QUERY\_STRING.
X1F will contain the float value of the X1 argument.
Y1F will contain the float value of the Y1 argument.
X2F will contain the float value of the X2 argument.
Y2F will contain the float value of the Y2 argument.
Buffer is a general usage string buffer.
EquationBuffer is a buffer that will hold the generated line equation.
Slope will hold the float value of the slope.
}
*/

	.equ QueryString, -8
	.equ X1F, -12
	.equ Y1F, -16
	.equ X2F, -20
	.equ Y2F, -24
	.equ Buffer, -88
	.equ EquationBuffer, -152
	.equ Slope, -156

/*
\vspace{5in}\clearpage
\marginnote{
First, the function enters, and creates the stack frame.
It also calls GetENV and stores the QUERY\_STRING pointer on the stack.
\includegraphics[width=3in]{Main_Stack1.png}
}
*/

main:
	enter $256, $0
	movq %rdx, %rsi
	lea QUERY_STRING, %rdi
	call GetENV
	movq %rax, QueryString(%rbp)

/*
\vspace{5in}\clearpage
\marginnote{
Now, the function will translate the first float argument into a float value.
It uses GetQueryStringValue to copy the string into the general purpose buffer, then it uses StringToFloat to convert it to a float.
After that, it copies the float onto the stack.
\includegraphics[width=3in]{Main_Stack2.png}
}
*/

	movq QueryString(%rbp), %rsi
	lea X1, %rdi
	lea Buffer(%rbp), %rdx
	call GetQueryStringValue
	lea Buffer(%rbp), %rdi
	call StringToFloat
	movss %xmm0, X1F(%rbp)

/*
\vspace{5in}\clearpage
\marginnote{
Now, the function will translate the first float argument into a float value.
It uses GetQueryStringValue to copy the string into the general purpose buffer, then it uses StringToFloat to convert it to a float.
After that, it copies the float onto the stack.
\includegraphics[width=3in]{Main_Stack3.png}
}
*/

	movq QueryString(%rbp), %rsi
	lea Y1, %rdi
	lea Buffer(%rbp), %rdx
	call GetQueryStringValue
	lea Buffer(%rbp), %rdi
	call StringToFloat
	movss %xmm0, Y1F(%rbp)

/*
\vspace{5in}\clearpage
\marginnote{
Now, the function will translate the first float argument into a float value.
It uses GetQueryStringValue to copy the string into the general purpose buffer, then it uses StringToFloat to convert it to a float.
After that, it copies the float onto the stack.
\includegraphics[width=3in]{Main_Stack4.png}
}
*/

	movq QueryString(%rbp), %rsi
	lea X2, %rdi
	lea Buffer(%rbp), %rdx
	call GetQueryStringValue
	lea Buffer(%rbp), %rdi
	call StringToFloat
	movss %xmm0, X2F(%rbp)

/*
\vspace{5in}\clearpage
\marginnote{
Now, the function will translate the first float argument into a float value.
It uses GetQueryStringValue to copy the string into the general purpose buffer, then it uses StringToFloat to convert it to a float.
After that, it copies the float onto the stack.
\includegraphics[width=3in]{Main_Stack5.png}
}
*/

	movq QueryString(%rbp), %rsi
	lea Y2, %rdi
	lea Buffer(%rbp), %rdx
	call GetQueryStringValue
	lea Buffer(%rbp), %rdi
	call StringToFloat
	movss %xmm0, Y2F(%rbp)

/*
\vspace{5in}\clearpage
\marginnote{
Now, the function will take the converted float values, and use them to calculate the slope of the line between them.
It subtracts them from each other, and calculates rise over run.
Then, it uses the FloatToString function to convert it back into a string.
It also stores the converted float value on the stack in the Slope variable.
\includegraphics[width=3in]{Main_Stack6.png}
}
*/

	movss Y2F(%rbp), %xmm0
	movss Y1F(%rbp), %xmm1
	subss %xmm1, %xmm0
	movss X2F(%rbp), %xmm2
	movss X1F(%rbp), %xmm3
	subss %xmm3, %xmm2
	divss %xmm2, %xmm0
	movss %xmm0, Slope(%rbp)
	lea Buffer(%rbp), %rdi
	call FloatToString

/*
\vspace{5in}\clearpage
\marginnote{
Next, the function will print the HTML header, as well as the slope.
It will then print a line break to make the graph show up on a new line.
}
*/

	call PrintHTMLHeader
	lea SLOPE, %rdi
	call Print
	lea Buffer(%rbp), %rdi
	call PrintLine
	call PrintHTMLBreak

/*
\vspace{5in}\clearpage
\marginnote{
Next, the function will generate the equation to graph.
It loads the values of X1F, Y1F, and Slope into floating point argument registers, and a pointer to the Equation buffer in rdi.
Then, it calls the Equation function to generate the equation, and subsequently calls Plot, to create the graph of the line.
\includegraphics[width=3in]{Main_Stack7.png}
}
*/

	lea EquationBuffer(%rbp), %rdi
	movss X1F(%rbp), %xmm0
	movss Y1F(%rbp), %xmm1
	movss Slope(%rbp), %xmm2
	call Equation
	lea EquationBuffer(%rbp), %rdi
	call Plot

/*
\vspace{5in}\clearpage
\marginnote{
Finally, the function displays an HTML image tag containing the path to the image generated.
Then, the function returns zero.
}
*/

	lea PLOT_OUTPUT_FILE, %rdi
	call PrintHTMLImage	
	xorq %rax, %rax
	leave
	ret
