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

	pushl $t_val
	pushl $t_title
	call test_print_fail_bool_true
	call test_print_fail_bool_false
	
	pushl $t_exp
	pushl $t_val
	pushl $t_title
	call test_print_fail
	
	pushl $t_n
	pushl $t_exp
	pushl $t_val
	pushl $t_title
	call test_print_fail_memory

	pushl $t_val
	pushl $t_exp
	call test_print_fail_line
	call test_print_success_line

	pushl $divider
	call test_print	

	# Test assert functions
	pushl $t_title
	pushl $1
	call test_assert

	pushl $t_title
	pushl $0
	call test_assert
	
	pushl $t_title
	pushl $0
	call test_assert_false

	pushl $t_title
	pushl $1
	call test_assert_false
	
	pushl $t_title
	pushl $1024
	call test_assert_false

	pushl $t_title
	pushl $100
	pushl $100
	call test_assert_equal_uint
	
	pushl $t_title
	pushl $100
	pushl $200
	call test_assert_equal_uint	
	
	pushl $t_title
	pushl $100
	pushl $100
	call test_assert_equal_bin
	
	pushl $t_title
	pushl $100
	pushl $200
	call test_assert_equal_bin
	
	pushl $t_title
	pushl $100
	pushl $100
	call test_assert_equal_oct
	
	pushl $t_title
	pushl $100
	pushl $200
	call test_assert_equal_oct

	movl $1, %eax
	movl $0, %ebx
	int $0x80
