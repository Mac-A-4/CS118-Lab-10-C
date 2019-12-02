	.section .rodata

_NewLine_: .string "\n"

	.text
	.global NewLine

NewLine:
	lea _NewLine_, %rdi
	call Print
	ret

