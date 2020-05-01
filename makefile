
build_linux:
	gcc emulator.c  emulib.o -lSDL

build_windows:
	gcc emulator.c emulib.o -lSDL
	
build_emulib_win:
	gcc -c .\emulib-src-linux\emulib.c -I .\. -lSDL -o .\emulib.o

build_win_all:
	gcc -c .\emulib-src-linux\emulib.c -I .\. -lSDL -o .\emulib.o
	gcc emulator.c emulib.o -lSDL