# Mint-x86asm32
A minimal test framework for x86 ASM (32-bit).

## Usage
Mint-x86asm32 exposes the following functions for use in testing:
```c
test_assert(int32_t cond, char* title)
test_assert_true(int32_t cond, char* title)
test_assert_false(int32_t cond, char* title)

test_assert_equal(int32_t val, int32_t exp, char* title) [default to 32-bit]
test_assert_equal_uint(int32_t val, int32_t exp, char* title) [default to 32-bit]
test_assert_equal_bin(int32_t val, int32_t exp, char* title) [default to 32-bit]
test_assert_equal_oct(int32_t val, int32_t exp, char* title) [default to 32-bit]
test_assert_equal_hex(int32_t val, int32_t exp, char* title) [default to 32-bit]
^ These all compare 32-bit values, but the printing of expected/found values differ based on the function used

//These have not been implemented yet
test_assert_equal_memory(void* ptr, void* exp, int32_t el, char* title)
test_assert_equal_string(char* s, char* exp, char* title)
test_assert_equal_string_len(char* s, char* exp, int32_t len, char* title)
test_end()
```

This library follows the C calling convention, and each function expects arguments on the stack to process and clean up correctly.

## Building
Running `make` will create a `.so` library to link against in the `build/` directory. For static linking, `build/` should be populated also with the respective `.o` object files needed.

## Testing
Run `make && ./a.out` in the `test/` directory to test, which will run through functions and produce reasonable output.

