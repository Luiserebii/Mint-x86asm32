NAME=mintx86asm32
ASFLAGS=-g --32
LDFLAGS=-m elf_i386

main: setup test.o link
	
setup:
	mkdir -p build
	cd .. && make

test.o: 
	as $(ASFLAGS) src/test.s -o build/test.o 

link: 
	ld $(LDFLAGS) ../build/$(NAME).o build/test.o

test-n: test-n.o link-n

test-n.o:
	as $(ASFLAGS) src/test-1.s -o build/test-1.o 
	as $(ASFLAGS) src/test-2.s -o build/test-2.o 

link-n:
	ld $(LDFLAGS) ../build/$(NAME).o build/test-1.o -o test-1.out
	ld $(LDFLAGS) ../build/$(NAME).o build/test-2.o -o test-2.out

clean:
	rm -rf build/*
