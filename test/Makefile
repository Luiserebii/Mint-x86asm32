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

clean:
	rm -rf build/*
