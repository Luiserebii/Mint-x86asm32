#
# test.s
#
.section .data
buffer:
	.ascii "hello world\0"
	.equ BUFFER_SIZE, 20

.section .text
.globl _start

_start:

	pushl $BUFFER_SIZE
	pushl $buffer
	call test_print
	
	movl $1, %eax
	movl $0, %ebx
	int $0x80
