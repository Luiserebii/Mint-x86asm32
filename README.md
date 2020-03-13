# Mint-x86asm32
![GitHub](https://img.shields.io/github/license/Luiserebii/Mint-x86asm32?color=222222)

A minimal test framework for x86 ASM (32-bit).

## Usage
Mint-x86asm32 exposes the following functions for use in testing:
```c
test_assert(int32_t cond, char* title)
test_assert_true(int32_t cond, char* title)
test_assert_false(int32_t cond, char* title)

test_assert_equal(int32_t val, int32_t exp, char* title)
test_assert_equal_uint(int32_t val, int32_t exp, char* title)
test_assert_equal_bin(int32_t val, int32_t exp, char* title)
test_assert_equal_oct(int32_t val, int32_t exp, char* title)
test_assert_equal_hex(int32_t val, int32_t exp, char* title)

test_assert_equal_string(char* s, char* exp, char* title)
test_assert_equal_string_len(char* s, char* exp, int32_t len, char* title)
test_assert_equal_memory(void* ptr, void* exp, int32_t el, char* title)

test_end()
```
This library follows the C calling convention, and each function expects arguments on the stack to process and clean up correctly.

## Expected output

The general formatting of each function follows these patterns:
```
  [SUCCESS] strlen() returns num
  [SUCCESS] strlen() returns num
  [FAIL] strlen() returns num: Expected true, found false ("[NUM]")
  [FAIL] isbool() returns true: Expected false, found true ("[NUM]")
  [FAIL] sums are equal: Expected "[NUM]", found "[NUM]"
  [FAIL] sums are equal: Expected "01010", found "01111"
  [FAIL] sums are equal: Expected "0[NUM]", found "0[NUM]"
  [FAIL] sums are equal: Expected "0x[NUM]", found "0x[NUM]"
  [FAIL] memory arrs are equal: Expected "0x[NUM]" on [N]th byte, found "0x[NUM]"
  [FAIL] strings are equal: Expected "[STR]", found "[STR]"

[FAIL] 8 tests failing with 2 tests passing.
[SUCCESS] All tests ([NUM]) passing with no tests failing.
```
For a particular set of test cases, output may look as follows:
```
string.h
  [SUCCESS] strlen() returns num
  [SUCCESS] strlen() returns num
  [FAIL] strlen() returns num: Expected true, found false ("0")
  [FAIL] strlen() returns num: Expected false, found true ("1")
  [FAIL] strlen() returns num: Expected false, found true ("1024")
  [FAIL] strlen() returns num: Expected "100", found "200"
  [FAIL] strlen() returns num: Expected "1100100", found "11001000"
  [FAIL] strlen() returns num: Expected "0144", found "0310"
  [FAIL] strlen() returns num: Expected "0x64", found "0xC8"
  [FAIL] strlen() returns num: Expected "aac", found "aaa"
  [FAIL] strlen() returns num: Expected "0x63" on 12th byte, found "0x61"
  [FAIL] strlen() returns num: Expected "0x5A" on 20th byte, found "0x7A"

[FAIL] 10 tests failing with 2 tests passing.
```

## Building
Running `make` will create a `.so` library to link against in the `build/` directory. For static linking, `build/` should be populated also with the respective `.o` object files needed.

## Testing
Run `make && ./a.out` in the `test/` directory to test, which will run through functions and produce reasonable output.

## License
This code has been licensed under the GNU General Public License v3.0.
