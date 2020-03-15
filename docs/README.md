# Mintx86asm32 API

This section contains documentation on using the Mint test framework. Each function is documented with its prototype and a brief description. Similar functions will be grouped together and described for brevity.

Running an assertion function causes a line to print to the standard output stream describing the success or failure of the assertion.

## Testing Boolean Value

The functions below assert a particular boolean value, which parallels the way expressions are evaluated and determine the behavior of control structures in C (i.e. `true` as non-zero and `false` otherwise).

### test\_assert(int32\_t cond, char\* title)

Asserts `cond` as true. Alias of `test_assert_true()`.

### test\_assert\_true(int32\_t cond, char\* title)

Asserts `cond` as true.

### test\_assert\_false(int32\_t cond, char\* title)

Asserts `cond` as false.

