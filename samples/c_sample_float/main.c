


// arm-none-eabi-gcc -nostdlib -mcpu=cortex-m0 -mthumb main.c -L /usr/lib/gcc/arm-none-eabi/10.1.0/thumb/v6-m/nofp/ -lgcc
// arm-none-eabi-objcopy -O binary -j .text a.out rom

void _start() {

	float a = 4;
	float b = 5;
	float c = a+b;

}