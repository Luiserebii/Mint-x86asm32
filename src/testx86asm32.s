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

	# Push strlen because print macro will otherwise
	# overwrite; I almost wonder if this is best as
	# a function
	pushl %eax
	print 8(%ebp), -8(%ebp)

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
	cmpb $0, (%eax)
	je _strcat_while_char_src_end

	incl %eax
	jmp _strcat_while_char_src

_strcat_while_char_src_end:

	# while(*dest++ = *src++)
	#    ;

_strcat_while_set:
	movb (%ecx), %dl
	movb %dl, (%eax)
	incl %eax
	incl %ecx

	cmpb $0, %dl
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
	movb (%ecx), %dl
	movb %dl, (%eax)
	incl %eax
	incl %edx

	cmpb $0, %dl
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

	# Use %ecx as string
	movl 8(%ebp), %ecx

	# while(*s++) { ++len }
	# The above isn't actually quite accurate, it's more like
	# while(*s) { ++s, ++len; }, we can't stuff something between
	# cmpb and je without it breaking I think
_strlen_while_s:
	cmpb $0, (%ecx)
	je _strlen_while_s_end

	incl %ecx
	incl %eax
	jmp _strlen_while_s

_strlen_while_s_end:

	popl %ebp
	ret

