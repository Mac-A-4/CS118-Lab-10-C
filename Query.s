	.text
	.global GetQueryString
	.global GetQueryStringValueAddress
	.global GetQueryStringValue

/*
\vspace{5in}\clearpage
\marginnote{
The GetQueryString function is meant to parse the QUERY\_STRING environment variable for a specified variable.
This is essentially the same as a strstr function.
First the function enters an outer while loop, that will iterate through each character.
The loop first checks if the current character is equal to a null terminator, and if it is, it will return a null pointer.
}
*/

GetQueryString:
GetQueryString_While_1:
	movb (%rsi), %al
	cmp $0, %al
	jne GetQueryString_If_1
	movq $0, %rax
	ret
GetQueryString_If_1:

/*
\vspace{5in}\clearpage
\marginnote{
Here, the function is entering its inner loop, the function of which is to match the key we are looking for to the current string.
r8 is set to zero, because it will be used as the iterator for the inner loop.
The inner loop iterates through the string until it finds either a null character or a non matching character.
If the end of the string is reached before an unmatching character is found, the function will return the pointer to the specified variable within QUERY\_STRING.
}
*/

	xorq %r8, %r8
GetQueryString_For_1:
	movb (%rdi, %r8, 1), %al
	cmp $0, %al
	jne GetQueryString_If_2
	movq %rsi, %rax
	ret
GetQueryString_If_2:
	movb (%rsi, %r8, 1), %al
	cmp $0, %al
	jne GetQueryString_If_3
	xorq %rax, %rax
	ret
GetQueryString_If_3:
	movb (%rdi, %r8, 1), %al
	movb (%rsi, %r8, 1), %cl
	cmp %al, %cl
	jne GetQueryString_For_2
	incq %r8
	jmp GetQueryString_For_1
GetQueryString_For_2:

/*
\vspace{5in}\clearpage
\marginnote{
This code merely increments the string pointer for the outer loop, and jumps back to the beginning of the outer loop.
}
*/

	incq %rsi
	jmp GetQueryString_While_1

/*
\vspace{5in}\clearpage
\marginnote{
The purpose of the GetQueryStringValueAddress function is to call GetQueryString, and increment the returned pointer until the first equals sign in the string has been passed. It's meant to help isolate the variable from the key.
}
*/

GetQueryStringValueAddress:
	call GetQueryString
GetQueryStringValueAddress_While_1:
	movb (%rax), %cl
	cmp $'=', %cl
	je GetQueryStringValueAddress_While_2
	incq %rax
	jmp GetQueryStringValueAddress_While_1
GetQueryStringValueAddress_While_2:
	incq %rax
	ret

/*
\vspace{5in}\clearpage
\marginnote{
The objective of the GetQueryStringValue function is to call GetQueryStringValueAddress, take the returned pointer, and copy every subsequent character in the string until it reaches either an ampersand or a null chaacter.
}
*/

GetQueryStringValue:
	push %rdx
	call GetQueryStringValueAddress
	pop %rdx
	movq %rax, %rdi
	movq %rdx, %rsi
	call QueryTranslate
	ret

/*
\vspace{5in}\clearpage
\marginnote{
The objective of the QueryHex function is to translate HTML hex codes into characters.
}
*/

QueryHex:
	cmp $'0', %dil
	jl QueryHex_Else_1
	cmp $'9', %dil
	jg QueryHex_Else_1
	subb $'0', %dil
	movb %dil, %al
	ret
QueryHex_Else_1:
	andb $0b11011111, %dil
	cmp $'A', %dil
	jl QueryHex_Else_2
	cmp $'F', %dil
	jg QueryHex_Else_2
	subb $'A', %dil
	addb $10, %dil
	movb %dil, %al
	ret
QueryHex_Else_2:
	movb $-1, %al
	ret

/*
\vspace{5in}\clearpage
\marginnote{
The objective of the QueryTranslate function is to normalize HTML strings.
If a string contains html hex codes for special characters, or it contains plus signs in place of spaces,
then this function will translate the string into a format that gnuplot will accept.
}
*/

	.equ QueryTranslate_Input_Index, -8
	.equ QueryTranslate_Output_Index, -16
	.equ QueryTranslate_Input, -24
	.equ QueryTranslate_Output, -32

QueryTranslate:
	enter $32, $0
	push %r12
	movq %rdi, QueryTranslate_Input(%rbp)
	movq %rsi, QueryTranslate_Output(%rbp)
	movq $0, QueryTranslate_Input_Index(%rbp)
	movq $0, QueryTranslate_Output_Index(%rbp)

/*
\vspace{5in}\clearpage
\marginnote{
After initializing its local variables, QueryTranslate begins its first while loop, the purpose of which is to iterate through all the characters in the input string.
It will only stop iterating if it reaches either a null terminator or an ampersand.
Inside of the loop, it goes through a switch statement that checks for percent signs and plus signs.
Percent signs denote the presence of a literal hex character in the following two bytes.
Plus signs, in html, are replacements for spaces.
}
*/

QueryTranslate_While_1:
	movq QueryTranslate_Input(%rbp), %rax
	movq QueryTranslate_Input_Index(%rbp), %rcx
	movb (%rax, %rcx, 1), %al
	test %al, %al
	jz QueryTranslate_While_2
	cmp $'&', %al
	je QueryTranslate_While_2
	cmp $'%', %al
	je QueryTranslate_Switch_Case_Percent
	cmp $'+', %al
	je QueryTranslate_Switch_Case_Plus
	jmp QueryTranslate_Switch_Default

/*
\vspace{5in}\clearpage
\marginnote{
If the character was a percent sign, the function will set r12b to zero, because it will be used to accumulate the character onto.
It will also increment the input index to bypass the percent sign.
}
*/

QueryTranslate_Switch_Case_Percent:
	xorb %r12b, %r12b
	incq QueryTranslate_Input_Index(%rbp)

/*
\vspace{5in}\clearpage
\marginnote{
This is the for loop through which the function iterates until it finds a non-hex character.
For every character, it calls QueryHex, which will check if the character is a valid hex code.
If so, it will accumulate it onto r12b, in order to translate the hex code into an actual character.
}
*/

QueryTranslate_For_1:
	movq QueryTranslate_Input(%rbp), %rcx
	movq QueryTranslate_Input_Index(%rbp), %rdx
	movb (%rcx, %rdx, 1), %dil
	call QueryHex
	cmp $-1, %al
	jz QueryTranslate_For_2
	movb %al, %r8b
	movb %r12b, %al
	movb $16, %cl
	imulb %cl
	movb %al, %r12b
	addb %r8b, %r12b
	incq QueryTranslate_Input_Index(%rbp)
	jmp QueryTranslate_For_1
QueryTranslate_For_2:

/*
\vspace{5in}\clearpage
\marginnote{
Once the translation loop has exited, the function writes the character onto the output string, and jumps to the end of the switch statement.
}
*/

	movq QueryTranslate_Output(%rbp), %rcx
	movq QueryTranslate_Output_Index(%rbp), %rdx
	movb %r12b, (%rcx, %rdx, 1)
	incq QueryTranslate_Output_Index(%rbp)
	jmp QueryTranslate_Switch_End

/*
\vspace{5in}\clearpage
\marginnote{
If the character was a plus, the function substitutes a space for the character in the output string, and jumps to the end of the switch statement.
}
*/

QueryTranslate_Switch_Case_Plus:
	movq QueryTranslate_Output(%rbp), %rcx
	movq QueryTranslate_Output_Index(%rbp), %rdx
	movb $' ', (%rcx, %rdx, 1)
	incq QueryTranslate_Input_Index(%rbp)
	incq QueryTranslate_Output_Index(%rbp)
	jmp QueryTranslate_Switch_End

/*
\vspace{5in}\clearpage
\marginnote{
If the character has no special meaning, just write it into the output string with no changes.
}
*/

QueryTranslate_Switch_Default:
	movq QueryTranslate_Output(%rbp), %rcx
	movq QueryTranslate_Output_Index(%rbp), %rdx
	movb %al, (%rcx, %rdx, 1)
	incq QueryTranslate_Input_Index(%rbp)
	incq QueryTranslate_Output_Index(%rbp)

/*
\vspace{5in}\clearpage
\marginnote{
At the end of the switch statement, all that takes place is a jump back to the beginning of the first while loop.
}
*/

QueryTranslate_Switch_End:
	jmp QueryTranslate_While_1

/*
\vspace{5in}\clearpage
\marginnote{
When the while loop ends, the function writes a null terminator to the end of the output string, collapses its stack frame, and returns.
}
*/

QueryTranslate_While_2:
	movq QueryTranslate_Output(%rbp), %rcx
	movq QueryTranslate_Output_Index(%rbp), %rdx
	movb $0, (%rcx, %rdx, 1)
	pop %r12
	leave
	ret
