
#define i8 char
#define i16 short
#define i32 int
#define f32 float

i32 res = 2;

void _s() {
	
	i32 a,b,c,d,e,f;
						// a	b	c	d	e	f
	a = res;			// 2	0	0	0	0	0
	b = res * 2;		// 2	4	0	0	0	0
	c = res * 3;		// 2	4	6	0	0	0
	d = a + 3;			// 2	4	6	5	0	0
	e = b - 3;			// 2	4	6	5	1	0
	f = c / 2;			// 2	4	6	5	1	3
	b = b + f;			// 2	7	6	5	1	3
	c = c + a;			// 2	7	8	5	1	3
	d = d + c;			// 2	7	8	13	1	3
	e = 5 - e;			// 2	7	8	13	4	3
	e = e * d;			// 2	7	8	13	52	3
	c += e / 10;		// 2	7	13	13	52	3
	res = a+b+c+d+e+f;	// res = 90

	asm("bkpt 0");
}