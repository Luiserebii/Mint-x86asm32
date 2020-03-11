#
# test.s
#
.section .bss
	.equ BUFFER_SIZE, 10000
	.lcomm buffer, 10000

.section .data
hello_world:
	.ascii "hello world\n\0"
t_title:
	.ascii "strlen() returns num\0"
t_val:
	.ascii "10\0"
t_exp:
	.ascii "20\0"

.section .text
.globl _start

_start:

	pushl $BUFFER_SIZE
	pushl $hello_world
	call test_print

	pushl $t_exp
	pushl $t_val
	pushl $t_title
	pushl $buffer
	call test_write_fail

	pushl $BUFFER_SIZE
	pushl $buffer
	call test_print
	
	movl $1, %eax
	movl $0, %ebx
	int $0x80
