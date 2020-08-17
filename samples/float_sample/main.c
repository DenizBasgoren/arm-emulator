
#define i8 char
#define i16 short
#define i32 int
#define f32 float


void _start() {
	i32 a = 5;
	f32 b = 5;

	if (a==b) {
		asm("bkpt 0");
	}
}