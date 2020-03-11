#
# test.s
#

.section .bss
	.equ BUFFER_SIZE, 10000
	.lcomm buffer, BUFFER_SIZE

.section .data
indent:
	.ascii "  \0"

success:
	.ascii "[SUCCESS]\0"

fail:
	.ascii "[FAIL]\0"

fail_info_0x0:
	.ascii ": Expected \"\0"

fail_info_0x1:
	.ascii "\", found \"\0"

fail_info_0x2:
	.ascii "\"\n\0"

space:
	.ascii " \0"

newline:
	.ascii "\n\0"

dnewline:
	.ascii "\n\n\0"

.section .text

.macro print buffer:req, buffsize:req
	movl $4, %eax
	movl $1, %ebx
	movl \buffer, %ecx
	movl \buffersize, %edx
.endm

.globl test_print
.type test_print, @function
test_print:
	pushl %ebp
	movl %esp, %ebp

	# Print buffer
	print $buffer, $BUFFER_SIZE

	popl %ebp
	ret

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
.type test_assert, @function
test_assert:
	pushl %ebp
	movl %esp, %ebp
	
	# Concat indent to buffer, and title
	pushl indent
	pushl buffer
	call _strcat

	movl 8(%ebp), %eax
	movl %eax, -4(%ebp)
	call _strcat

	# Branch depending on cond
	cmpl $0, 12(%ebp)
	je test_assert_if_false

	# Logic for true
	movl $success, -4(%esp)
	call _strcat
	jmp test_assert_if_end

test_assert_if_false:
	# Logic for false
	movl $fail, -4(%esp)
	call _strcat

	movl $fail_info_init, -4(%esp)
	call _strcat
	
	# itoa(cond, buffer, 10)
	# concat is false at the end

test_assert_if_end:

	movl %ebp, %esp
	popl %ebp
	ret
