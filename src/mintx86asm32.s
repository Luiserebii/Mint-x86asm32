/**
 * mintx86asm32.s of Mint-x86asm32.
 *
 * Copyright (C) 2020 Luiserebii
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

.section .bss
	.equ BUFFER_SIZE, 10000
	.lcomm buffer, BUFFER_SIZE

	.equ BUFFER_MINI_SIZE, 1000
	.lcomm buff_m1, BUFFER_MINI_SIZE
	.lcomm buff_m2, BUFFER_MINI_SIZE
	.lcomm buff_m3, BUFFER_MINI_SIZE
	
	.lcomm buff_bin, 2

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

fail_line_0x0:
	.ascii " tests failing with \0"

fail_line_0x1:
	.ascii " tests passing.\n\0"

success_line_0x0:
	.ascii "All tests (\0"

success_line_0x1:
	.ascii ") passing with no tests failing.\n\0"

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

#
# void test_assert_equal(int32_t val, int32_t exp, char* title)
#
# Alias for test_assert_equal_uint
#
.macro test_assert_equal
test_assert_equal_uint
.endm

#
# void test_assert_equal_uint(int32_t val, int32_t exp, char* title)
#
.globl test_assert_equal_uint
.type test_assert_equal_uint, @function
test_assert_equal_uint:
	pushl %ebp
	movl %esp, %ebp
	
	# Branch depending on equality
	movl 8(%ebp), %eax
	cmpl %eax, 12(%ebp)
	jne test_assert_equal_uint_ne

	# It's equal, so write success
	pushl 16(%ebp)
	call test_print_success
	jmp test_assert_equal_uint_end

test_assert_equal_uint_ne:

	# Convert both exp and val to char* and store into mini-buffers
	pushl $10
	pushl $buff_m1
	pushl 8(%ebp)
	call _itoa

	movl $buff_m2, -8(%ebp)
	movl 12(%ebp), %eax
	movl %eax, -12(%ebp)
	call _itoa

	# Finally, print
	pushl $buff_m2
	pushl $buff_m1
	pushl 16(%ebp)
	call test_print_fail

test_assert_equal_uint_end:

	movl %ebp, %esp
	popl %ebp
	ret

#
# void test_assert_equal_bin(int32_t val, int32_t exp, char* title)
#
.globl test_assert_equal_bin
.type test_assert_equal_bin, @function
test_assert_equal_bin:
	pushl %ebp
	movl %esp, %ebp
	
	# Branch depending on equality
	movl 8(%ebp), %eax
	cmpl %eax, 12(%ebp)
	jne test_assert_equal_bin_ne

	# It's equal, so write success
	pushl 16(%ebp)
	call test_print_success
	jmp test_assert_equal_bin_end

test_assert_equal_bin_ne:

	# Convert both exp and val to char* and store into mini-buffers
	pushl $2
	pushl $buff_m1
	pushl 8(%ebp)
	call _itoa

	movl $buff_m2, -8(%ebp)
	movl 12(%ebp), %eax
	movl %eax, -12(%ebp)
	call _itoa

	# Finally, print
	pushl $buff_m2
	pushl $buff_m1
	pushl 16(%ebp)
	call test_print_fail

test_assert_equal_bin_end:

	movl %ebp, %esp
	popl %ebp
	ret

#
# void test_assert_equal_hex(int32_t val, int32_t exp, char* title)
#
.globl test_assert_equal_hex
.type test_assert_equal_hex, @function
test_assert_equal_hex:
	pushl %ebp
	movl %esp, %ebp
	
	# Branch depending on equality
	movl 8(%ebp), %eax
	cmpl %eax, 12(%ebp)
	jne test_assert_equal_hex_ne

	# It's equal, so write success
	pushl 16(%ebp)
	call test_print_success
	jmp test_assert_equal_hex_end

test_assert_equal_hex_ne:

	# Convert both exp and val to char* and store into mini-buffers
	# Prepend each buffer with a 0x
	movl $buff_m1, %eax
	movb $'0', (%eax)
	movb $'x', 1(%eax)
	addl $2, %eax
	
	pushl $16
	pushl %eax
	pushl 8(%ebp)
	call _itoa
	
	movl $buff_m2, %eax
	movb $'0', (%eax)
	movb $'x', 1(%eax)
	addl $2, %eax

	movl %eax, -8(%ebp)
	movl 12(%ebp), %eax
	movl %eax, -12(%ebp)
	call _itoa

	# Finally, print
	pushl $buff_m2
	pushl $buff_m1
	pushl 16(%ebp)
	call test_print_fail

test_assert_equal_hex_end:

	movl %ebp, %esp
	popl %ebp
	ret


#
# void test_assert_equal_oct(int32_t val, int32_t exp, char* title)
#
.globl test_assert_equal_oct
.type test_assert_equal_oct, @function
test_assert_equal_oct:
	pushl %ebp
	movl %esp, %ebp
	
	# Branch depending on equality
	movl 8(%ebp), %eax
	cmpl %eax, 12(%ebp)
	jne test_assert_equal_oct_ne

	# It's equal, so write success
	pushl 16(%ebp)
	call test_print_success
	jmp test_assert_equal_oct_end

test_assert_equal_oct_ne:

	# Convert both exp and val to char* and store into mini-buffers
	# Prepend each buffer with a 0
	movl $buff_m1, %eax
	movb $'0', (%eax)
	incl %eax
	
	pushl $8
	pushl %eax
	pushl 8(%ebp)
	call _itoa
	
	movl $buff_m2, %eax
	movb $'0', (%eax)
	incl %eax

	movl %eax, -8(%ebp)
	movl 12(%ebp), %eax
	movl %eax, -12(%ebp)
	call _itoa

	# Finally, print
	pushl $buff_m2
	pushl $buff_m1
	pushl 16(%ebp)
	call test_print_fail

test_assert_equal_oct_end:

	movl %ebp, %esp
	popl %ebp
	ret

#
# void test_assert_equal_string(char* val, char* exp, char* title)
#
.globl test_assert_equal_string
.type test_assert_equal_string, @function
test_assert_equal_string:
        pushl %ebp
        movl %esp, %ebp

	# Compare with strcmp
	pushl 8(%ebp)
	pushl 12(%ebp)
	call _strcmp

	# Branch depending on %eax
	cmpl $0, %eax
	jne test_assert_equal_string_ne

	pushl 16(%ebp)
	call test_print_success
	jmp test_assert_equal_string_end

test_assert_equal_string_ne:
	pushl 12(%ebp)
	pushl 8(%ebp)
	pushl 16(%ebp)
	call test_print_fail

test_assert_equal_string_end:
	movl %ebp, %esp
	popl %ebp
	ret

#
# void test_assert_equal_string_len(char* val, char* exp, int32_t n, char* title)
#
.globl test_assert_equal_string_len
.type test_assert_equal_string_len, @function
test_assert_equal_string_len:
        pushl %ebp
        movl %esp, %ebp

	# Compare with strncmp (change to _strncmp by shifting macro higher)
	pushl 16(%ebp)
	pushl 8(%ebp)
	pushl 12(%ebp)
	call _memcmp

	# Branch depending on %eax
	cmpl $0, %eax
	jne test_assert_equal_string_len_ne

	pushl 20(%ebp)
	call test_print_success
	jmp test_assert_equal_string_len_end

test_assert_equal_string_len_ne:
	pushl 12(%ebp)
	pushl 8(%ebp)
	pushl 20(%ebp)
	call test_print_fail

test_assert_equal_string_len_end:
	movl %ebp, %esp
	popl %ebp
	ret

#
# void test_assert_equal_memory(char* val, char* exp, int32_t n, char* title)
#
.globl test_assert_equal_memory
.type test_assert_equal_memory, @function
test_assert_equal_memory:
        pushl %ebp
        movl %esp, %ebp

	# Compare with memcpy_v
	pushl 16(%ebp)
	pushl $buff_bin
	pushl 8(%ebp)
	pushl 12(%ebp)
	call _memcmp_v

	# Branch depending on %eax
	cmpl $0, %eax
	jne test_assert_equal_memory_ne

	pushl 20(%ebp)
	call test_print_success
	jmp test_assert_equal_memory_end

test_assert_equal_memory_ne:
	
	# Take %eax for nth byte and make into str
	pushl $10
	pushl $buff_m1
	pushl %eax
	call _itoa

	# Convert buff_bin bytes into hex
	pushl $16
	pushl $buff_m2
	# We're stuffing a byte into a long, so
	# we will have to set %eax to 0 first
	movl $0, %eax
	movb buff_bin, %al
	pushl %eax
	call _itoa	

	movl $buff_m3, 4(%esp)
	movl $1, %eax
	movb buff_bin(, %eax, 1), %al
	movl %eax, (%esp)
	call _itoa

	pushl $buff_m1
	pushl $buff_m3
	pushl $buff_m2
	pushl 20(%ebp)
	call test_print_fail_memory

test_assert_equal_memory_end:
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

#
# void test_print_success_line(const char* pass)
#
.globl test_print_success_line
.type test_print_success_line, @function
test_print_success_line:
	pushl %ebp
	movl %esp, %ebp
	
	# Clear the buffer
	movb $0, buffer

	.equ TEST_PRINT_SUCC_LINE_PASS, 8
	pushl TEST_PRINT_SUCC_LINE_PASS(%ebp)
	pushl $buffer

	call test_write_success_line
	call test_print

	movl %ebp, %esp
	popl %ebp
	ret

#
# void test_print_fail_line(const char* fail, const char* pass)
#
.globl test_print_fail_line
.type test_print_fail_line, @function
test_print_fail_line:
	pushl %ebp
	movl %esp, %ebp
	
	# Clear the buffer
	movb $0, buffer

	.equ TEST_PRINT_FAIL_LINE_FAIL, 8
	.equ TEST_PRINT_FAIL_LINE_PASS, 12
	pushl TEST_PRINT_FAIL_LINE_PASS(%ebp)
	pushl TEST_PRINT_FAIL_LINE_FAIL(%ebp)
	pushl $buffer

	call test_write_fail_line
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

#
# void test_write_success_line(char* buffer, const char* pass)
#
.globl test_write_success_line
.type test_write_success_line, @function
test_write_success_line:
	pushl %ebp
	movl %esp, %ebp

	.equ TEST_WRITE_SUCC_LINE_BUFF, 8
	.equ TEST_WRITE_SUCC_LINE_PASS, 12
	
	pushl $newline
	pushl TEST_WRITE_SUCC_LINE_BUFF(%ebp)
	call _strcat
	
	movl $success, 4(%esp)
	call _strcat
	
	movl $space, 4(%esp)
	call _strcat
	
	movl $success_line_0x0, 4(%esp)
	call _strcat

	movl TEST_WRITE_SUCC_LINE_PASS(%ebp), %eax
	movl %eax, 4(%esp)
	call _strcat

	movl $success_line_0x1, 4(%esp)
	call _strcat

	movl %ebp, %esp
	popl %ebp
	ret

#
# void test_write_fail_line(char* buffer, const char* fail, const char* pass)
#
.globl test_write_fail_line
.type test_write_fail_line, @function
test_write_fail_line:
	pushl %ebp
	movl %esp, %ebp

	.equ TEST_WRITE_FAIL_LINE_BUFF, 8
	.equ TEST_WRITE_FAIL_LINE_FAIL, 12
	.equ TEST_WRITE_FAIL_LINE_PASS, 16
	
	pushl $newline
	pushl TEST_WRITE_FAIL_LINE_BUFF(%ebp)
	call _strcat
	
	movl $fail, 4(%esp)
	call _strcat
	
	movl $space, 4(%esp)
	call _strcat
	
	movl TEST_WRITE_FAIL_LINE_FAIL(%ebp), %eax
	movl %eax, 4(%esp)
	call _strcat

	movl $fail_line_0x0, 4(%esp)
	call _strcat

	movl TEST_WRITE_FAIL_LINE_PASS(%ebp), %eax
	movl %eax, 4(%esp)
	call _strcat
	
	movl $fail_line_0x1, 4(%esp)
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

#
# void strrev(char* s)
#
.type _strrev, @function
_strrev:
	pushl %ebp
	movl %esp, %ebp

	.equ STRREV_LEN, -4
	.equ STRREV_LIM, -8
	.equ STRREV_I, -12
	subl $12, %esp	

	movl 8(%ebp), %eax
	movl %eax, -12(%ebp)
	call _strlen
	movl %eax, STRREV_LEN(%ebp)
	
	# Divide len by 2 and store in lim
	movl $0, %edx
	movl $2, %ecx
	divl %ecx
	movl %eax, STRREV_LIM(%ebp)

	# Initialize i of for loop
	movl $0, STRREV_I(%ebp)

strrev_for:
	# i < lim
	movl STRREV_I(%ebp), %eax
	cmpl STRREV_LIM(%ebp), %eax
	jge strrev_for_end
	
	# Swap s + i and s + len - i - 1
	# Using %ecx for s + i
	# Using %edx for s + len - i - 1
	movl 8(%ebp), %ecx
	movl %ecx, %edx

	addl %eax, %ecx
	addl STRREV_LEN(%ebp), %edx
	subl %eax, %edx
	subl $1, %edx

	pushl %ecx
	pushl %edx
	call _swap	

strrev_for_inc:
	incl STRREV_I(%ebp)
	jmp strrev_for

strrev_for_end:

	movl %ebp, %esp
	popl %ebp
	ret

#
# void swap(char* ptr1, char* ptr2)
#
# Swaps the content of the two pointers.
# NOTE: This could probably be better made a macro
# 
.type _swap, @function
_swap:
	pushl %ebp
	movl %esp, %ebp
	
	movl 8(%ebp), %eax
	movl 12(%ebp), %ebx
	
	movb (%eax), %cl
	movb (%ebx), %dl
	
	movb %cl, (%ebx)
	movb %dl, (%eax) 

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
	.equ ITOA_NO_LVARS, 3
	.equ ITOA_LV_BYTES, ITOA_NO_LVARS * 4
	subl $ITOA_LV_BYTES, %esp

	# Use var to hold the 32-bit int to manipulate
	.equ ITOA_N, -4
	movl 8(%ebp), %eax
	movl %eax, ITOA_N(%ebp)

	# Use var to hold the digit to keep track of
	.equ ITOA_DIGIT, -8

	# Use var to hold the address of the string to iterate through
	.equ ITOA_STR, -12
	movl 12(%ebp), %ecx
	movl %ecx, ITOA_STR(%ebp)

	# Check to see that number is 0, to apply special case
	cmpl $0, %eax
	jne itoa_while_not_zero

	movl $'0', (%ecx)
	incl %ecx
	movl $0, (%ecx) 

	movl %ebp, %esp
	popl %ebp
	ret 

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
	
	# Set current string pos to digit equivalent, and increment
	movl ITOA_STR(%ebp), %eax
	movl ITOA_DIGIT(%ebp), %ecx
	movl itoa_lookup_table(, %ecx, 1), %ecx
	
	movl %ecx, (%eax)
	incl ITOA_STR(%ebp)

	jmp itoa_while_not_zero

itoa_while_not_zero_end:
	# Finally, cap string off with '\0' null terminator
	movl ITOA_STR(%ebp), %eax
	movl $0, (%eax)

	# And, reverse:
	pushl 12(%ebp)
	call _strrev

	movl %ebp, %esp
	popl %ebp
	ret

#
# int strcmp(char* a, char* b)
#
# Iterates through a and b until \0 is found,
# returning -1 if a < b, 1 if a > b, or 0 if a == b.
#
# NOTE: There is a more efficient way to implement this
# that saves on the double conditionals, this can be improved
#
.globl _strcmp
.type _strcmp, @function
_strcmp: 
	pushl %ebp
	movl %esp, %ebp

	# Load a and b into %eax, %ecx respectively
	movl 8(%ebp), %eax
	movl 12(%ebp), %ecx
	
strcmp_for_len:
	# This section is worthy of anaylsis due to &&
	# I wrote it intuitively, but it's not obvious to me
	# by the way I typically write conditionals in ASM
	# why this is
	#
	# (*a != 0 && *b != 0) == !(*a == 0 || *b == 0)
	cmpl $0, (%eax)
	jne strcmp_cond_cont

	cmpl $0, (%ecx)
	jne strcmp_cond_cont
	jmp strcmp_for_end

strcmp_cond_cont:

	# If *a < *b, -1
	movb (%eax), %dl
	cmpb %dl, (%ecx)
	jle strcmp_if_greater_cmp

	movl $-1, %eax
	popl %ebp
	ret

strcmp_if_greater_cmp:
	# If *a > *b
	movb (%eax), %dl
	cmpb %dl, (%ecx)
	jge strcmp_for_inc

	movl $1, %eax
	popl %ebp
	ret
	
strcmp_for_inc:
	incl %eax
	incl %ecx

	jmp strcmp_for_len

strcmp_for_end:
	# Return 0
	movl $0, %eax
	popl %ebp
	ret


#
# int strncmp(char* a, char* b, int32_t n)
#
# Iterates through the ranges [a, a + n) and [b, b + n),
# returning -1 if a < b, 1 if a > b, or 0 if a == b.
#
# Alias of memcmp, the same functionality really. 
#
.macro _strncmp
_memcmp
.endm

#
# int memcmp_v(void* val, void* exp, void* out, int32_t n)
#
# Iterates through the ranges [a, a + n) and [b, b + n),
# returning the nth byte at which the difference was found,
# 0 otherwise (if the memory segments are equal).
# 
# If -1 or 1 is returned, then the found byte is written to
# *out, whereas the expected char is written to *(out + 1)
#
.globl _memcmp_v
.type _memcmp_v, @function
_memcmp_v: 
	pushl %ebp
	movl %esp, %ebp

	# Load val and exp into %eax, %ecx respectively
	# We can't reserve %edx for n, because we need
	# a register to hold the comparisons between
	# the two chars
	movl 8(%ebp), %eax
	movl 12(%ebp), %ecx
	
	.equ MEMCMP_V_N, -4
	pushl 20(%ebp)

memcmp_v_for_len:
	cmpl $0, MEMCMP_V_N(%ebp)
	je memcmp_v_for_end

	# If *val != *exp,
	movb (%eax), %dl
	cmpb %dl, (%ecx)
	je memcmp_v_if_eq

	# We only have 3 registers, so save expected char onto stack
	pushl (%ecx)
	movl 16(%ebp), %ecx
	movb %dl, (%ecx)

	# Move exp char into %edx, shuffle into *(out + 1)	
	movl -8(%ebp), %edx
	movb %dl, 1(%ecx)

	# Calculate return val (nth byte)
	movl 20(%ebp), %eax
	subl MEMCMP_V_N(%ebp), %eax
	movl %ebp, %esp
	popl %ebp
	ret

memcmp_v_if_eq:
	
memcmp_v_for_inc:
	decl MEMCMP_V_N(%ebp)
	incl %eax
	incl %ecx

	jmp memcmp_v_for_len

memcmp_v_for_end:
	# Return 0
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret

#
# int memcmp(void* a, void* b, int32_t n)
#
# Iterates through the ranges [a, a + n) and [b, b + n),
# returning -1 if a < b, 1 if a > b, or 0 if a == b.
#
.globl _memcmp
.type _memcmp, @function
_memcmp: 
	pushl %ebp
	movl %esp, %ebp

	# Load a and b into %eax, %ecx respectively
	# We can't reserve %edx for n, because we need
	# a register to hold the comparisons between
	# the two chars
	movl 8(%ebp), %eax
	movl 12(%ebp), %ecx
	
	.equ MEMCMP_N, -4
	pushl 16(%ebp)

memcmp_for_len:
	cmpl $0, MEMCMP_N(%ebp)
	je memcmp_for_end

	# If *a < *b, -1
	movb (%eax), %dl
	cmpb %dl, (%ecx)
	jle memcmp_if_greater_cmp

	movl $-1, %eax
	movl %ebp, %esp
	popl %ebp
	ret

memcmp_if_greater_cmp:
	# If *a > *b
	movb (%eax), %dl
	cmpb %dl, (%ecx)
	jge memcmp_for_inc

	movl $1, %eax
	movl %ebp, %esp
	popl %ebp
	ret
	
memcmp_for_inc:
	decl MEMCMP_N(%ebp)
	incl %eax
	incl %ecx

	jmp memcmp_for_len

memcmp_for_end:
	# Return 0
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
