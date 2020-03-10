#
# test.s
#

.section .bss
	.equ BUFFER_SIZE, 1000
	.lcomm buffer, BUFFER_SIZE

.section .data
indent:
	.ascii "  \0"

success:
	.ascii "SUCCESS\0"

fail:
	.ascii "FAIL\0"

.section .text

#
# test_assert(int32_t cond, char* title)
#
# Evaluates the condition and prints success if true,
# failure otherwise. The title argument is used to
# prepend the test case.
#
# Note that this uses the C definition of true;
# non-zero is true, zero is false.
#
.globl test_assert
test_assert:
	pushl %ebp
	movl %esp, %ebp
	
	# Concat indent to buffer, and title
	pushl indent
	pushl buffer
	call strcat

	movl 8(%ebp), %eax
	movl %eax, 4(%esp)
	call strcat

	# Branch depending on cond
	cmpl $0, 12(%ebp)
	je test_assert_if_false

	# Logic for true

test_assert_if_false:
	# Logic for false

test_assert_if_end:

	movl %ebp, %esp
	popl %ebp
	ret
