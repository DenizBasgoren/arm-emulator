
#define i8 char
#define i16 short
#define i32 int
#define f32 float

f32 xd;

void _start() {
	float a = 0.1f;
	float b = 0.2f;

	xd = a*b;
	asm("bkpt 0");
	
	while (1);
}