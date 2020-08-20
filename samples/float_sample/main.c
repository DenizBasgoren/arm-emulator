
extern int xd;
extern float zd;

// void printNum(int from, int to) {
// 	asm("bkpt 4");
// }

void _start() {
	
	zd = xd / 100.0f;
	asm("bkpt 0");
}