
build_linux:
	gcc emulator.c  emulib.o -lSDL

build_windows:
	gcc emulator.c -L . -lemulib -lSDL -O3
	del .\armapp.bin .\armapp.elf .\armapp.o