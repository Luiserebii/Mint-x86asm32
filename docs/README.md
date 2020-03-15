# Mintx86asm32 API

This section contains documentation on using the Mint test framework. Each function is documented with its prototype and a brief description. Similar functions will be grouped together and described for brevity.

Running an assertion function causes a line to print to the standard output stream describing the success or failure of the assertion.

## Testing Boolean Value

The functions below assert a particular boolean value, which parallels the way expressions are evaluated and determine the behavior of control structures in C (i.e. `true` as non-zero and `false` otherwise).

#### test\_assert(int32\_t cond, char\* title)

Asserts `cond` as true. Alias of `test_assert_true()`.

#### test\_assert\_true(int32\_t cond, char\* title)

Asserts `cond` as true.

#### test\_assert\_false(int32\_t cond, char\* title)

Asserts `cond` as false.

## Testing Integer Equality

The functions below assert integer values, testing the equality of a value (`val`) against an expected value (`exp`). All of these functions perform the same logic in equality, but differ in terms of the formatting of the values when printing them on failure.

#### test\_assert\_equal(int32\_t val, int32\_t exp, char\* title)

Alias of `test_assert_equal_uint`.

#### test\_assert\_equal\_uint(int32\_t val, int32\_t exp, char\* title)

Asserts the equality of `val` to `exp`. On failure, prints integers as unsigned integers in decimal.

#### test\_assert\_equal\_bin(int32\_t val, int32\_t exp, char\* title)

Asserts the equality of `val` to `exp`. On failure, prints integers in binary.

#### test\_assert\_equal\_oct(int32\_t val, int32\_t exp, char\* title)

Asserts the equality of `val` to `exp`. On failure, prints integers in octal.

#### test\_assert\_equal\_hex(int32\_t val, int32\_t exp, char\* title)

Asserts the equality of `val` to `exp`. On failure, prints integers in hexadecimal.


