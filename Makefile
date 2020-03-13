NAME=mintx86asm32
ASFLAGS=-g --32
LDFLAGS=-shared -m elf_i386

main: setup mintx86asm32.o link
	
# Attempt creation of build/ folder if non-existing
setup:
	mkdir -p build

mintx86asm32.o: 
	as $(ASFLAGS) src/$(NAME).s -o build/$(NAME).o 

link: 
	ld $(LDFLAGS) build/$(NAME).o -o build/lib$(NAME).so

clean:
	rm -rf build/*
