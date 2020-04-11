
build_linux:
	gcc emulator.c  emulib.o -lSDL

build_windows:
	gcc emulator.c -L . -lemulib -lSDL
	del .\armapp.bin .\armapp.elf .\armapp.o