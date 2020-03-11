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

.macro print buffer:req, bytes:req
	movl $4, %eax
	movl $1, %ebx
	movl \buffer, %ecx
	movl \bytes, %edx
	int $0x80
.endm

.globl test_print
.type test_print, @function
test_print:
	pushl %ebp
	movl %esp, %ebp

	# Print buffer
	pushl 8(%ebp)
	call _strlen

	print 8(%ebp), %eax

	movl %ebp, %esp
	popl %ebp
	ret

# With this macro, please place title, val, and exp into regs
# if passing memory references.
.macro write_fail buffer:req, title:req, val:req, exp:req
	pushl $indent
	pushl \buffer
	call _strcat

	movl $fail, 4(%esp)
	call _strcat

	movl $space, 4(%esp)
	call _strcat
	
	movl \title, 4(%esp)
	call _strcat
	
	movl $fail_info_0x0, 4(%esp)
	call _strcat
	
	movl \exp, 4(%esp)
	call _strcat

	movl $fail_info_0x1, 4(%esp)
	call _strcat

	movl \val, 4(%esp)
	call _strcat
	
	movl $fail_info_0x2, 4(%esp)
	call _strcat
.endm

.globl test_write_fail
.type test_write_fail, @function
test_write_fail:
	pushl %ebp
	movl %esp, %ebp

	.equ TEST_WRITE_FAIL_BUFF, 8
	.equ TEST_WRITE_FAIL_TITLE, 12
	.equ TEST_WRITE_FAIL_VAL, 16
	.equ TEST_WRITE_FAIL_EXP, 20
	
	#write_fail TEST_WRITE_FAIL_BUFF(%ebp), %eax, %ecx, %edx
	pushl $indent
	pushl TEST_WRITE_FAIL_BUFF(%ebp)
	call _strcat

	movl $fail, 4(%esp)
	call _strcat

	movl $space, 4(%esp)
	call _strcat

	movl TEST_WRITE_FAIL_TITLE(%ebp), %eax
	movl %eax, 4(%esp)
	call _strcat
	
	movl $fail_info_0x0, 4(%esp)
	call _strcat

	movl TEST_WRITE_FAIL_VAL(%ebp), %eax
	movl %eax, 4(%esp)
	call _strcat

	movl $fail_info_0x1, 4(%esp)
	call _strcat
	
	movl TEST_WRITE_FAIL_EXP(%ebp), %eax	
	movl %eax, 4(%esp)
	call _strcat
	
	movl $fail_info_0x2, 4(%esp)
	call _strcat

	movl %ebp, %esp
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

	movl $fail_info_0x0, -4(%esp)
	call _strcat
	
	# itoa(cond, buffer, 10)
	# concat is false at the end

test_assert_if_end:

	movl %ebp, %esp
	popl %ebp
	ret
#
# void strcat(char* dest, const char* src)
#
.type _strcat, @function
_strcat:
	pushl %ebp
	movl %esp, %ebp

	# Load dest and src into registers
	movl 8(%ebp), %eax
	movl 12(%ebp), %ecx
	
	# Roll dest up to the null terminator (\0)
	# while(*dest) { ++dest; }
_strcat_while_char_src:
	cmpl $0, (%eax)
	je _strcat_while_char_src_end

	addl $4, %eax
	jmp _strcat_while_char_src

_strcat_while_char_src_end:

	# while(*dest++ = *src++)
	#    ;

_strcat_while_set:
	movl (%ecx), %edx
	movl %edx, (%eax)
	addl $4, %eax
	addl $4, %ecx

	cmpl $0, %edx
	jne _strcat_while_set

	popl %ebp
	ret
#
# strcpy(char* dest, const char* src)
#
.type _strcpy, @function
_strcpy:
	pushl %ebp
	movl %esp, %ebp

	# while(*dest++ = *src++)
	#    ;

	# Load dest and src into registers
	movl 8(%ebp), %eax
	movl 12(%ebp), %ecx

_strcpy_while_set:
	movl (%ecx), %edx
	movl %edx, (%eax)
	addl $4, %eax
	addl $4, %ecx

	cmpl $0, %edx
	jne _strcpy_while_set

	popl %ebp
	ret

#
# int strlen(const char* s)
#
.type _strlen, @function
_strlen:
	pushl %ebp
	movl %esp, %ebp

	# Reserve 0 as place for length
	movl $0, %eax

	# Use %ebx as string
	movl 8(%ebp), %ebx

	# while(*s++) { ++len }
_strlen_while_s:
	cmpl $0, (%ebx)
	addl $4, %ebx
	je _strlen_while_s_end

	incl %eax
	jmp _strlen_while_s

_strlen_while_s_end:

	popl %ebp
	ret

