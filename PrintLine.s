	.text
	.global PrintLine

PrintLine:
	call Print
	call NewLine
	ret

