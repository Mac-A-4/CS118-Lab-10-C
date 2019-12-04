
/*
\vspace{5in}\clearpage
\marginnote{
The objective of the PrintHTMLBreak function is to print an html break tag.
}
*/

	.section .rodata

BREAK:
	.string "<br>"

	.text
	.global PrintHTMLBreak

PrintHTMLBreak:
	lea BREAK, %rdi
	call PrintLine
	ret
