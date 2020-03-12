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
t_n:
	.ascii "2\0"
divider:
	.ascii "==============================\n\0"

.section .text
.globl _start

_start:

	# Test write functions
	pushl $hello_world
	call test_print

	# Set buffer to empty string
	movl $0, buffer

	pushl $t_title
	pushl $buffer
	call test_write_success

	pushl $t_exp
	pushl $t_val
	pushl $t_title
	pushl $buffer
	call test_write_fail
	
	pushl $t_n
	pushl $t_exp
	pushl $t_val
	pushl $t_title
	pushl $buffer
	call test_write_fail_memory
	call test_print
	
	pushl $divider
	call test_print	

	# Test print functions
	pushl $t_title
	call test_print_success
	
	pushl $t_exp
	pushl $t_val
	pushl $t_title
	call test_print_fail
	
	pushl $t_n
	pushl $t_exp
	pushl $t_val
	pushl $t_title
	call test_print_fail_memory
	
	movl $1, %eax
	movl $0, %ebx
	int $0x80
