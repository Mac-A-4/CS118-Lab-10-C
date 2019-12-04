	.section .rodata

BREAK:
	.string "<br>"

	.text
	.global PrintHTMLBreak

PrintHTMLBreak:
	lea BREAK, %rdi
	call PrintLine
	ret
