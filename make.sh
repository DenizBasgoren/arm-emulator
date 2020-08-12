
gcc src/emulator.c src/emulib.c -O3 -g -lSDL

if test -f "./a.out"; then
	mv a.out dist-linux/emulator
	echo "Emulator is ready at dist-linux/emulator"
else
	echo "Oops"
fi

