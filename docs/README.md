# Mintx86asm32 API

This section contains documentation on using the Mint test framework. Each function is documented with its prototype and a brief description. Similar functions will be grouped together and described for brevity.

Running an assertion function causes a line to print to the standard output stream describing the success or failure of the assertion. Each assertion function takes a `title` argument, which is printed as the name of the assertion which succeeded or failed.

## Booleans

The functions below assert a particular boolean value, which parallels the way expressions are evaluated and determine the behavior of control structures in C (i.e. `true` as non-zero and `false` otherwise).

- #### void test\_assert(int32\_t cond, char\* title)

Alias of `test_assert_true()`.

- #### void test\_assert\_true(int32\_t cond, char\* title)

Asserts `cond` as true.

- #### void test\_assert\_false(int32\_t cond, char\* title)

Asserts `cond` as false.

## Integers

The functions below assert integer values, testing the equality of a value (`val`) against an expected value (`exp`). All of these functions perform the same logic in equality, but differ in terms of the formatting of the values when printing them on failure.

- #### void test\_assert\_equal(int32\_t val, int32\_t exp, char\* title)

Alias of `test_assert_equal_uint`.

- #### void test\_assert\_equal\_uint(int32\_t val, int32\_t exp, char\* title)

Asserts the equality of `val` to `exp`. On failure, prints integers as unsigned integers in decimal.

- #### void test\_assert\_equal\_bin(int32\_t val, int32\_t exp, char\* title)

Asserts the equality of `val` to `exp`. On failure, prints integers in binary.

- #### void test\_assert\_equal\_oct(int32\_t val, int32\_t exp, char\* title)

Asserts the equality of `val` to `exp`. On failure, prints integers in octal.

- #### void test\_assert\_equal\_hex(int32\_t val, int32\_t exp, char\* title)

Asserts the equality of `val` to `exp`. On failure, prints integers in hexadecimal.

## Strings

The functions below assert string values, or `char` arrays, testing the equality of the values in a string (`s`) against an expected string (`exp`).

- #### void test\_assert\_equal\_string(char\* s, char\* exp, char\* title)

Assert the equality of `s` to `exp`.

- #### void test\_assert\_equal\_string\_len(char\* s, char\* exp, int32\_t n, char\* title)

Assert the equality of the first `n` chars from both `s` and `exp`. In other words, the equality of the values in the range `[a, a + n)` and `[b, b + n)` is asserted.

## Memory

This function asserts the equality of values along two regions of memory, comparing them byte-by-byte. If an unexpected byte is found, the index of the byte is printed alongside the byte expected, and the byte found.

- #### void test\_assert\_equal\_memory(void\* ptr, void\* exp, int32\_t n, char\* title)

Assert the equality of the first `n` bytes from both `ptr` and `exp`. In other words, the equality of the values in the range `[a, a + n)` and `[b, b + n)` is asserted.

## Other

- #### int test\_end()

Prints a line summarizing the number of tests passed, and the number of tests failed. Returns an exit code to forward to the `exit` syscall.
