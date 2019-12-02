	.section .rodata

TAG_1:
	.string "<img src=\""
TAG_2:
	.string "\">"

	.text
	.global PrintHTMLImage

/*
\vspace{5in}\clearpage
\marginnote{
The objective of the PrintHTMLImage function is to provide a simple way to display an image.
All it does is wrap the given string, passed in rdi, inside of a html image tag.
}
*/

PrintHTMLImage:
	push %rdi
	lea TAG_1, %rdi
	call Print
	pop %rdi
	call Print
	lea TAG_2, %rdi
	call Print
	call NewLine
	ret
