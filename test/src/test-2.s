.include "./src/macro-util.s"
.section .data
title1:
	.ascii "numbers are as expected\0"

.section .text
.globl _start

_start:
	stdcall test_assert_equal_uint $1, $1, $title1
	stdcall test_assert_equal_uint $1, $2, $title1
	stdcall test_assert_equal_uint $1, $4, $title1

	stdcall test_end

	movl %eax, %ebx
	movl $1, %eax
	int $0x80
