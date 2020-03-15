.include "macro-util.s"
.section .data
title1:
	.ascii "numbers are as expected\0"

.section .text
.globl _start

_start:
	stdcall test_assert_equal_uint $1, $2, $title1

	movl $1, %eax
	movl $0, %ebx
	int $0x80
