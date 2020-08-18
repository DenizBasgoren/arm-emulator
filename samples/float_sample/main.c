
extern float xd;
extern float yd;
extern float zd;

void _start() {
	zd = xd*yd;
	
	asm("bkpt 0");
	
	while (1);
}