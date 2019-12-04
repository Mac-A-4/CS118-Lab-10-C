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

	.equ QueryString, -8
	.equ X1F, -12
	.equ Y1F, -16
	.equ X2F, -20
	.equ Y2F, -24
	.equ Buffer, -88
	.equ EquationBuffer, -152
	.equ Slope, -156

main:
	enter $256, $0
	movq %rdx, %rsi
	lea QUERY_STRING, %rdi
	call GetENV
	movq %rax, QueryString(%rbp)
	
	movq QueryString(%rbp), %rsi
	lea X1, %rdi
	lea Buffer(%rbp), %rdx
	call GetQueryStringValue
	lea Buffer(%rbp), %rdi
	call StringToFloat
	movss %xmm0, X1F(%rbp)
	movq QueryString(%rbp), %rsi
	lea Y1, %rdi
	lea Buffer(%rbp), %rdx
	call GetQueryStringValue
	lea Buffer(%rbp), %rdi
	call StringToFloat
	movss %xmm0, Y1F(%rbp)
	movq QueryString(%rbp), %rsi
	lea X2, %rdi
	lea Buffer(%rbp), %rdx
	call GetQueryStringValue
	lea Buffer(%rbp), %rdi
	call StringToFloat
	movss %xmm0, X2F(%rbp)
	movq QueryString(%rbp), %rsi
	lea Y2, %rdi
	lea Buffer(%rbp), %rdx
	call GetQueryStringValue
	lea Buffer(%rbp), %rdi
	call StringToFloat
	movss %xmm0, Y2F(%rbp)
	
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
	
	call PrintHTMLHeader
	lea SLOPE, %rdi
	call Print
	lea Buffer(%rbp), %rdi
	call PrintLine
	call PrintHTMLBreak
	
	lea EquationBuffer(%rbp), %rdi
	movss X1F(%rbp), %xmm0
	movss Y1F(%rbp), %xmm1
	movss Slope(%rbp), %xmm2
	call Equation
	lea EquationBuffer(%rbp), %rdi
	call Plot
	
	lea PLOT_OUTPUT_FILE, %rdi
	call PrintHTMLImage
	
	xorq %rax, %rax
	leave
	ret
