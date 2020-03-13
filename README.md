# test-x86asm32
A minimal test framework for x86 ASM (32-bit).

## Usage
This library exposes the following functions for use in testing:
```c
test\_assert(int32\_t cond, char\* title)
test\_assert\_true(int32\_t cond, char\* title)
test\_assert\_false(int32\_t cond, char\* title)

test\_assert\_equal(int32\_t val, int32\_t exp, char\* title) [default to 32-bit]
test\_assert\_equal\_uint(int32\_t val, int32\_t exp, char\* title) [default to 32-bit]
test\_assert\_equal\_bin(int32\_t val, int32\_t exp, char\* title) [default to 32-bit]
test\_assert\_equal\_oct(int32\_t val, int32\_t exp, char\* title) [default to 32-bit]
test\_assert\_equal\_hex(int32\_t val, int32\_t exp, char\* title) [default to 32-bit]
^ These all compare 32-bit values, but the printing of expected/found values differ based on the function used

//These have not been implemented yet
test\_assert\_equal\_memory(void\* ptr, void\* exp, int32\_t el, char\* title)
test\_assert\_equal\_string(char\* s, char\* exp, char\* title)
test\_assert\_equal\_string\_len(char\* s, char\* exp, int32\_t len, char\* title)
test\_end()
```

This library follows the C calling convention, and each function expects arguments on the stack to process and clean up correctly.

## Building
Running `make` will create a `.so` library to link against in the `build/` directory. For static linking, `build/` should be populated also with the respective `.o` object files needed.

## Testing
Run `make && ./a.out` in the `test/` directory to test, which will run through functions and produce reasonable output.

