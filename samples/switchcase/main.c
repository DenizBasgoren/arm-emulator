
char xd = 3;

void _start() {

	switch (xd) {
		case 1: asm("bkpt 1"); break;
		case 2: asm("bkpt 2"); break;
		case 3: asm("bkpt 3"); break;
		case 4: asm("bkpt 4"); break;
		case 5: asm("bkpt 5"); break;
		//case 6: break;
	}
	
	
}