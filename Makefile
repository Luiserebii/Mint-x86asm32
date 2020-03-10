NAME=testx86asm32
ASFLAGS=-g --32
LDFLAGS=-shared -m elf_i386

main: setup test link
	
# Attempt creation of build/ folder if non-existing
setup:
	mkdir -p build

test: 
	as $(ASFLAGS) src/test.s -o build/test.o 

link: 
	ld $(LDFLAGS) build/test.o -o lib$(NAME).so

clean:
	rm -rf build/* lib$(NAME).so 
