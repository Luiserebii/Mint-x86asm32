#
# test.s
#

.section .bss
	.equ BUFFER_SIZE, 10000
	.lcomm buffer, BUFFER_SIZE

	.equ BUFFER_MINI_SIZE, 1000
	.comm buff_m1, BUFFER_SIZE

.section .data
itoa_lookup_table:
	.byte '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'

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

fail_info_bool_true_0x0:
	.ascii ": Expected true, found false (\"\0"

fail_info_bool_false_0x0:
	.ascii ": Expected false, found true (\"\0"

fail_info_bool_0x0:
	.ascii "\")\n\0"

fail_mem_info_0x1:
	.ascii "\" on \0"

fail_mem_info_0x2:
	.ascii "th byte, found \"\0"

space:
	.ascii " \0"

newline:
	.ascii "\n\0"

dnewline:
	.ascii "\n\n\0"

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
.type test_assert, @function
test_assert:
	pushl %ebp
	movl %esp, %ebp
	
	# Branch depending on cond
	cmpl $0, 8(%ebp)
	je test_assert_if_false

	# Logic for true
	pushl 12(%ebp)
	call test_print_success
	jmp test_assert_if_end

test_assert_if_false:
	# Logic for false
	pushl $10
	pushl $buff_m1
	pushl 8(%ebp)
	call _itoa

	pushl $buff_m1
	pushl 12(%ebp)
	call test_print_fail_bool_true

test_assert_if_end:

	movl %ebp, %esp
	popl %ebp
	ret

#
# test_assert_true(int32_t cond, char* title)
#
# Alias for test_assert.
#
.macro test_assert_true 
test_assert
.endm

#
# test_assert_false(int32_t cond, char* title)
#
# Evaluates the condition and prints success if false,
# failure otherwise. The title argument is used to
# prepend the test case.
#
# Note that this uses the C definition of true;
# non-zero is true, zero is false.
#
.globl test_assert_false
.type test_assert_false, @function
test_assert_false:
	pushl %ebp
	movl %esp, %ebp
	
	# Branch depending on cond
	cmpl $0, 8(%ebp)
	jne test_assert_false_if_true

	# Logic for false
	pushl 12(%ebp)
	call test_print_success
	jmp test_assert_false_if_end

test_assert_false_if_true:
	# Logic for true
	pushl $10
	pushl $buff_m1
	pushl 8(%ebp)
	call _itoa

	pushl $buff_m1
	pushl 12(%ebp)
	call test_print_fail_bool_false

test_assert_false_if_end:

	movl %ebp, %esp
	popl %ebp
	ret

# ================================================
#                 WRITE FUNCTIONS
# ================================================
#
# Functions to write to string buffers, particularly
# on success/failure.
#

#
# test_print_success(char* title)
#
# This function uses the buffer to print, overwriting
# its contents.
# 
.globl test_print_success
.type test_print_success, @function
test_print_success:
	pushl %ebp
	movl %esp, %ebp

	# Clear the buffer
	movb $0, buffer

	pushl 8(%ebp)
	pushl $buffer
	call test_write_success
	call test_print

	movl %ebp, %esp
	popl %ebp
	ret

#
# test_print_fail(const char* title, const char* val, const char* exp)
#
# This function uses the buffer to print, overwriting
# its contents.
# 
.globl test_print_fail
.type test_print_fail, @function
test_print_fail:
	pushl %ebp
	movl %esp, %ebp

	# Clear the buffer
	movb $0, buffer

	.equ TEST_PRINT_FAIL_TITLE, 8
	.equ TEST_PRINT_FAIL_VAL, 12
	.equ TEST_PRINT_FAIL_EXP, 16

	pushl TEST_PRINT_FAIL_EXP(%ebp)
	pushl TEST_PRINT_FAIL_VAL(%ebp)
	pushl TEST_PRINT_FAIL_TITLE(%ebp)
	pushl $buffer

	call test_write_fail
	call test_print

	movl %ebp, %esp
	popl %ebp
	ret

#
# void test_print_fail_bool_true(const char* title, const char* val)
#
.globl test_print_fail_bool_true
.type test_print_fail_bool_true, @function
test_print_fail_bool_true:
	pushl %ebp
	movl %esp, %ebp

	# Clear the buffer
	movb $0, buffer

	.equ TEST_PRINT_FAIL_BOOL_TRUE_TITLE, 8
	.equ TEST_PRINT_FAIL_BOOL_TRUE_VAL, 12

	pushl TEST_PRINT_FAIL_BOOL_TRUE_VAL(%ebp)
	pushl TEST_PRINT_FAIL_BOOL_TRUE_TITLE(%ebp)
	pushl $buffer

	call test_write_fail_bool_true
	call test_print

	movl %ebp, %esp
	popl %ebp
	ret

#
# void test_print_fail_bool_false(const char* title, const char* val)
#
.globl test_print_fail_bool_false
.type test_print_fail_bool_false, @function
test_print_fail_bool_false:
	pushl %ebp
	movl %esp, %ebp

	# Clear the buffer
	movb $0, buffer

	.equ TEST_PRINT_FAIL_BOOL_FALSE_TITLE, 8
	.equ TEST_PRINT_FAIL_BOOL_FALSE_VAL, 12

	pushl TEST_PRINT_FAIL_BOOL_FALSE_VAL(%ebp)
	pushl TEST_PRINT_FAIL_BOOL_FALSE_TITLE(%ebp)
	pushl $buffer

	call test_write_fail_bool_false
	call test_print

	movl %ebp, %esp
	popl %ebp
	ret

#
# void test_print_fail_memory(const char* title, const char* val, const char* exp, const char* n)
#
# This function uses the buffer to print, overwriting
# its contents.
# 
.globl test_print_fail_memory
.type test_print_fail_memory, @function
test_print_fail_memory:
	pushl %ebp
	movl %esp, %ebp

	# Clear the buffer
	movb $0, buffer

	.equ TEST_PRINT_FAIL_MEMORY_TITLE, 8
	.equ TEST_PRINT_FAIL_MEMORY_VAL, 12
	.equ TEST_PRINT_FAIL_MEMORY_EXP, 16
	.equ TEST_PRINT_FAIL_MEMORY_N, 20

	pushl TEST_PRINT_FAIL_MEMORY_N(%ebp)
	pushl TEST_PRINT_FAIL_MEMORY_EXP(%ebp)
	pushl TEST_PRINT_FAIL_MEMORY_VAL(%ebp)
	pushl TEST_PRINT_FAIL_MEMORY_TITLE(%ebp)
	pushl $buffer

	call test_write_fail_memory
	call test_print

	movl %ebp, %esp
	popl %ebp
	ret


.macro print buffer:req, bytes:req
	movl $4, %eax
	movl $1, %ebx
	movl \buffer, %ecx
	movl \bytes, %edx
	int $0x80
.endm

#
# void test_print(char* buffer)
#
# Prints the buffer to STDOUT.
#
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

#
# void test_write_success(char* buffer, const char* title)
#
.globl test_write_success
.type test_write_success, @function
test_write_success:
	pushl %ebp
	movl %esp, %ebp

	.equ TEST_WRITE_SUCC_BUFF, 8
	.equ TEST_WRITE_SUCC_TITLE, 12
	
	#write_fail TEST_WRITE_FAIL_BUFF(%ebp), %eax, %ecx, %edx
	pushl $indent
	pushl TEST_WRITE_SUCC_BUFF(%ebp)
	call _strcat

	movl $success, 4(%esp)
	call _strcat

	movl $space, 4(%esp)
	call _strcat
	
	movl TEST_WRITE_SUCC_TITLE(%ebp), %eax
	movl %eax, 4(%esp)
	call _strcat

	movl $newline, 4(%esp)
	call _strcat

	movl %ebp, %esp
	popl %ebp
	ret

#
# void test_write_fail(char* buffer, const char* title, const char* val, const char* exp)
#
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

	movl TEST_WRITE_FAIL_EXP(%ebp), %eax
	movl %eax, 4(%esp)
	call _strcat

	movl $fail_info_0x1, 4(%esp)
	call _strcat
	
	movl TEST_WRITE_FAIL_VAL(%ebp), %eax	
	movl %eax, 4(%esp)
	call _strcat
	
	movl $fail_info_0x2, 4(%esp)
	call _strcat

	movl %ebp, %esp
	popl %ebp
	ret

#
# void test_write_fail_bool_true(char* buffer, const char* title, const char* val)
#
.globl test_write_fail_bool_true
.type test_write_fail_bool_true, @function
test_write_fail_bool_true:
	pushl %ebp
	movl %esp, %ebp

	.equ TEST_WRITE_FAIL_BOOL_TRUE_BUFF, 8
	.equ TEST_WRITE_FAIL_BOOL_TRUE_TITLE, 12
	.equ TEST_WRITE_FAIL_BOOL_TRUE_VAL, 16
	
	pushl $indent
	pushl TEST_WRITE_FAIL_BOOL_TRUE_BUFF(%ebp)
	call _strcat

	movl $fail, 4(%esp)
	call _strcat

	movl $space, 4(%esp)
	call _strcat

	movl TEST_WRITE_FAIL_BOOL_TRUE_TITLE(%ebp), %eax
	movl %eax, 4(%esp)
	call _strcat
	
	movl $fail_info_bool_true_0x0, 4(%esp)
	call _strcat

	movl TEST_WRITE_FAIL_BOOL_TRUE_VAL(%ebp), %eax	
	movl %eax, 4(%esp)
	call _strcat
	
	movl $fail_info_bool_0x0, 4(%esp)
	call _strcat

	movl %ebp, %esp
	popl %ebp
	ret

#
# void test_write_fail_bool_false(char* buffer, const char* title, const char* val)
#
.globl test_write_fail_bool_false
.type test_write_fail_bool_false, @function
test_write_fail_bool_false:
	pushl %ebp
	movl %esp, %ebp

	.equ TEST_WRITE_FAIL_BOOL_FALSE_BUFF, 8
	.equ TEST_WRITE_FAIL_BOOL_FALSE_TITLE, 12
	.equ TEST_WRITE_FAIL_BOOL_FALSE_VAL, 16
	
	pushl $indent
	pushl TEST_WRITE_FAIL_BOOL_FALSE_BUFF(%ebp)
	call _strcat

	movl $fail, 4(%esp)
	call _strcat

	movl $space, 4(%esp)
	call _strcat

	movl TEST_WRITE_FAIL_BOOL_FALSE_TITLE(%ebp), %eax
	movl %eax, 4(%esp)
	call _strcat
	
	movl $fail_info_bool_false_0x0, 4(%esp)
	call _strcat

	movl TEST_WRITE_FAIL_BOOL_FALSE_VAL(%ebp), %eax	
	movl %eax, 4(%esp)
	call _strcat
	
	movl $fail_info_bool_0x0, 4(%esp)
	call _strcat

	movl %ebp, %esp
	popl %ebp
	ret

#
# void test_write_fail_memory(char* buffer, const char* title, const char* val, const char* exp, const char* n)
#
.globl test_write_fail_memory
.type test_write_fail_memory, @function
test_write_fail_memory:
	pushl %ebp
	movl %esp, %ebp

	.equ TEST_WRITE_FAIL_MEM_BUFF, 8
	.equ TEST_WRITE_FAIL_MEM_TITLE, 12
	.equ TEST_WRITE_FAIL_MEM_VAL, 16
	.equ TEST_WRITE_FAIL_MEM_EXP, 20
	.equ TEST_WRITE_FAIL_MEM_N, 24
	
	pushl $indent
	pushl TEST_WRITE_FAIL_MEM_BUFF(%ebp)
	call _strcat

	movl $fail, 4(%esp)
	call _strcat

	movl $space, 4(%esp)
	call _strcat

	movl TEST_WRITE_FAIL_MEM_TITLE(%ebp), %eax
	movl %eax, 4(%esp)
	call _strcat
	
	movl $fail_info_0x0, 4(%esp)
	call _strcat

	movl TEST_WRITE_FAIL_MEM_EXP(%ebp), %eax
	movl %eax, 4(%esp)
	call _strcat

	movl $fail_mem_info_0x1, 4(%esp)
	call _strcat
	
	movl TEST_WRITE_FAIL_MEM_N(%ebp), %eax	
	movl %eax, 4(%esp)
	call _strcat

	movl $fail_mem_info_0x2, 4(%esp)
	call _strcat
	
	movl TEST_WRITE_FAIL_MEM_VAL(%ebp), %eax	
	movl %eax, 4(%esp)
	call _strcat
	
	movl $fail_info_0x2, 4(%esp)
	call _strcat

	movl %ebp, %esp
	popl %ebp
	ret

# ================================================
#                 UTILITY FUNCTIONS
# ================================================
#
# Private utility functions to avoid dependencies
# and linker naming collision.
# 

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

#=========
# itoa
#=========
#
#  void itoa(int32_t val, char* s, int32_t base)
#
#  Takes two arguments, a 32-bit int and an address pointing to
#  an array of chars.
#
#  It is assumed that the char array has enough space to fit the
#  int; otherwise, the behavior is undefined.
#
#  It is also assumed that the base is at least 2 and not greater
#  than 16; otherwise, the behavior is undefined.
#
.type _itoa, @function
_itoa:
	pushl %ebp
	movl %esp, %ebp

	# Make room for a few local variables on the stack:
	.equ ITOA_NO_LVARS, 4
	.equ ITOA_LV_BYTES, ITOA_NO_LVARS * 4
	subl $ITOA_LV_BYTES, %esp

	# Use var to hold the mult. counter
	.equ ITOA_MULT_CTR, -4
	movl $1, ITOA_MULT_CTR(%ebp)

	# Use var to hold the 32-bit int to manipulate
	.equ ITOA_N, -8
	movl 8(%ebp), %eax
	movl %eax, ITOA_N(%ebp)

	# Use var to hold the digit to keep track of
	.equ ITOA_DIGIT, -12

	# Use var to hold the address of the string to iterate through
	.equ ITOA_STR, -16
	movl 12(%ebp), %eax
	movl %eax, ITOA_STR(%ebp)

itoa_while_not_zero:
	# while(n != 0)
	cmpl $0, ITOA_N(%ebp)
	je itoa_while_not_zero_end

	# Define dividend ATOI_N in %edx:%eax
	movl $0, %edx
	movl ITOA_N(%ebp), %eax

	# Divide ATOI_N by the base
	movl 16(%ebp), %ecx
	idivl %ecx
	
	# Set remainder (%) to digit, and quotient back to ATOI_N
	movl %edx, ITOA_DIGIT(%ebp)
	movl %eax, ITOA_N(%ebp)
	
	# "Increment" multctr by multiplying by base
	imull %ecx
	movl %eax, ITOA_MULT_CTR(%ebp)

	# Set current string pos to digit equivalent, and increment
	movl ITOA_STR(%ebp), %eax
	#.equ ITOA_0_CHAR, '0'
	#movl $ITOA_0_CHAR, %ecx
	#addl ITOA_DIGIT(%ebp), %ecx
	movl ITOA_DIGIT(%ebp), %ecx
	movl itoa_lookup_table(, %ecx, 1), %ecx
	
	movl %ecx, (%eax)
	incl ITOA_STR(%ebp)

	jmp itoa_while_not_zero

itoa_while_not_zero_end:
	# Finally, cap string off with '\0' null terminator
	movl ITOA_STR(%ebp), %eax
	movl $0, (%eax)

	movl %ebp, %esp
	popl %ebp
	ret
