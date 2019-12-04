/*
\vspace{5in}\clearpage
\marginnote{
This is the read-only data section of the Plot file, and it contains some important things.
First, the PROGRAM variable contains the path to the gnuplot program.
Second, the COMMAND variable contains a template argument for the gnuplot program.
Third, the ARGUMENT variable contains a required argument for the gnuplot program.
Fourth, the ARGUMENT\_ENVP variable is the environment pointers that gnuplot will be called with, as you can see, there is only one entry, which is the null-terminator.
Fifth, the PLOT\_OUTPUT\_FILE variable is the path to where the web server can find the image created by gnuplot.
}
*/

	.section .rodata
	.global PLOT_OUTPUT_FILE

PROGRAM: 
	.string "/usr/bin/gnuplot"
COMMAND: 
	.string "set terminal png; set output '/home/debian/CS118-Lab-10-C-Output.png'; plot [-5:5] "
ARGUMENT:
	.string "-e"
ARGUMENT_ENVP:
	.quad 0
PLOT_OUTPUT_FILE:
	.string "/home/CS118-Lab-10-C-Output.png"

/*
\vspace{5in}\clearpage
*/

	.text
	.global Plot

/*
\vspace{5in}\clearpage
\marginnote{
The objective of the Command function is simply to store a copy of the COMMAND string, above, into a buffer, with a given string appended onto it.
The string that will be appended onto the output should be passed in rdi, while the output buffer should be passed in rsi.
First, the function stores a pointer to the COMMAND variable, which is used as a template, into rax.
It also sets rcx to zero, because it will be used as a loop iterator variable.
}
*/

Command:
	lea COMMAND, %rax
	xorq %rcx, %rcx

/*
\vspace{5in}\clearpage
\marginnote{
Next, the function enters its first loop, the objective of which is to copy the COMMAND template string into the output buffer.
The function just iterates through each character of the COMMAND string until it reaches a null pointer, at which point it stops copying and exits the loop.
}
*/

Command_While_1:
	movb (%rax, %rcx, 1), %r8b
	test %r8b, %r8b
	jz Command_While_2
	movb %r8b, (%rsi, %rcx, 1)
	incq %rcx
	jmp Command_While_1
Command_While_2:

/*
\vspace{5in}\clearpage
\marginnote{
After the first loop has ended, the function sets r9 to zero, because it will be used as the index that is currently being copied from the string contained in rdi.
Now, the function enters the second loop, in which it appends the string contained in rdi onto the output buffer.
Once the end of the string contained in rdi is reached, the loop ends.
}
*/

	xorq %r9, %r9
Command_While_3:
	movb (%rdi, %r9, 1), %r8b
	test %r8b, %r8b
	jz Command_While_4
	movb %r8b, (%rsi, %rcx, 1)
	incq %rcx
	incq %r9
	jmp Command_While_3
Command_While_4:

/*
\vspace{5in}\clearpage
\marginnote{
Once the second loop has exited, the function writes a null terminator to the end of the output buffer.
Subsequently, the function returns.
}
*/

	movb $0, (%rsi, %rcx, 1)
	ret

/*
\vspace{5in}\clearpage
\marginnote{
These are the stack variables used by the PlotInternal function.
the Plot\_ARGVx variables are entries in gnuplot's arguments, and the Plot\_Command variable is a string buffer for the formatted gnuplot command to be stored in.
}
*/

	.equ Plot_ARGV3, -8
	.equ Plot_ARGV2, -16
	.equ Plot_ARGV1, -24
	.equ Plot_ARGV0, -32
	.equ Plot_Command, -256

/*
\vspace{5in}\clearpage
\marginnote{
The purpose of the PlotInternal function is to simply take in a single string, that represents a mathematical function,
and append the given string onto the COMMAND string above using the Command function. It will then package that command,
along with a few other required commands, into a two dimensional array that will be passed to Execute as gnuplot's argv.
First, the function calls the Command function, which places the command string onto the stack, in Plot\_Command.
\includegraphics[width=3in]{PlotInternal_Stack1.png}
}
*/

PlotInternal:
	enter $256, $0
	lea Plot_Command(%rbp), %rsi
	call Command

/*
\vspace{5in}\clearpage
\marginnote{
After the command has been formatted and stored on the stack, PlotInternal has to build the argv for gnuplot.
It will consist of four things, gnuplot's path, a command flag, the command itself, and a null terminator.
After building the argument list, this is what the stack looks like.
\includegraphics[width=3in]{PlotInternal_Stack2.png}
}
*/

	lea Plot_Command(%rbp), %rax
	movq %rax, Plot_ARGV2(%rbp)
	lea ARGUMENT, %rax
	movq %rax, Plot_ARGV1(%rbp)
	lea PROGRAM, %rax
	movq %rax, Plot_ARGV0(%rbp)
	xorq %rax, %rax
	movq %rax, Plot_ARGV3(%rbp)

/*
\vspace{5in}\clearpage
\marginnote{
After setting up the argv for gnuplot, PlotInternal has to pass a pointer to the argv array, as well as an envp array, to Execute.
First, it loads the address of the argv array into rsi, then it loads the path to gnuplot into rdi, and subsequently loads the address of the empty envp array into rdx.
After that, it calls execute. There's no need to return after it, because execute will never return.
}
*/

	lea PROGRAM, %rdi
	lea Plot_ARGV0(%rbp), %rsi
	lea ARGUMENT_ENVP, %rdx
	call Execute
	#Exection does not continue

/*
\vspace{5in}\clearpage
\marginnote{
The objective of the Plot function is to provide a wrapper around Fork and PlotInternal. First, the function first calls Fork, which creates a child process,
then, it checks if it is the child process or not, by comparing the value returned by Fork to zero, if it is zero, it is the child, if not, it is the parent.
If it is the child, it calls PlotInternal, which will call gnuplot.
If it is the parent, it calls Wait, which is a wrapper around SYS\_WAIT4.
After the parent's call to Wait is finished, the function returns.
}
*/

Plot:
	push %r12
	movq %rdi, %r12
	call Fork
	test %rax, %rax
	jnz Plot_Parent
Plot_Child:
	movq %r12, %rdi
	call PlotInternal
	#Execution does not continue
Plot_Parent:
	movq %rax, %rdi
	call Wait
Plot_End:
	pop %r12
	ret
