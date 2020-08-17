
#define i8 char
#define i16 short
#define i32 int
#define f32 float

f32 xd;

void _start() {
	float a = 0.1;
	float b = 0.2;

	if (a+b==0.3f) {
		asm("bkpt 3");
	}
	else {
		asm("bkpt 3");
		asm("bkpt 3");
	}

	while (1);
}