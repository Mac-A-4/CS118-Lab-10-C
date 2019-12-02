	.section .rodata

HTMLHeader: .string "Content-type: text/html\n\n"

	.text
	.global PrintHTMLHeader

/*
\vspace{5in}\clearpage
\marginnote{
The purpose of the PrintHTMLHeader function is to print a hardcoded HTML header.
It is used because CGI applications are meant to disclose what type of file they are trying to produce, in our case, HTML.
}
*/

PrintHTMLHeader:
	lea HTMLHeader, %rdi
	call PrintLine
	ret

