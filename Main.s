	.section .rodata

QUERY_STRING:
	.string "QUERY_STRING"
FUNCTION:
	.string "Function"

	.text
	.global main

/*
\vspace{5in}\clearpage
\marginnote{
The objective of this function, main, is to search the environment variables for QUERY\_STRING using GetENV,
and then to get the value of the entry within the QUERY\_STRING that has the name Function.
It will then call the Plot function, which will take the value of the said function and pass it to gnuplot.
Then, the program will print out the html header, and subsequently print a html image tag, telling the web browser to display the graph.
\includegraphics[width=3in]{Main_Stack1.png}
}
*/

	.equ QueryString, -8
	.equ FunctionString, -72

main:
	enter $128, $0
	movq %rdx, %rsi
	lea QUERY_STRING, %rdi
	call GetENV
	movq %rax, QueryString(%rbp)
	movq %rax, %rsi
	lea FUNCTION, %rdi
	lea FunctionString(%rbp), %rdx
	call GetQueryStringValue
	lea FunctionString(%rbp), %rdi
	call Plot
	call PrintHTMLHeader
	lea PLOT_OUTPUT_FILE, %rdi
	call PrintHTMLImage
	xorq %rax, %rax
	leave
	ret
