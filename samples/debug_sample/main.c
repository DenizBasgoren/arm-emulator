

// opens interactive debug menu
void interactive() {
	asm("bkpt 0");
}

void printRegisters() {
	asm("bkpt 1");
}

void disassemble() {
	asm("bkpt 2");
}

// prints how many inst, sec passed since last resetTimer() call
void resetTimer() {
	asm("bkpt 3");
}

// from, to in bytes
void printNum(int* from, int* to) {
	asm("bkpt 4");
}

// print str from addr to \0
void printString(int* addr) {
	asm("bkpt 5");
}

// scans num from stdin and puts to dest
void scanInteger(int* dest) {
	asm("bkpt 6");
}

// scans str from stdin and puts to dest (including \0)
void scanString(int* dest) {
	asm("bkpt 7");
}

// scans float from stdin and puts to dest (in float format!)
void scanFloat(int* dest) {
	asm("bkpt 8");
}

// prints stack from SP to RAM_MAX
void printStack() {
	asm("bkpt 9");
}





//////////////////////////////
void _start() {
	
	float n1, n2;
	int op;
	float result;

	printStack();


	// print float 1!
	scanFloat((int*) &n1);

	// print float 2!
	scanFloat((int*) &n2);

	// select operation: 0-add 1-sub 2-mul 3-div
	scanInteger(&op);

	if (op == 0) result = n1+n2;
	if (op == 1) result = n1-n2;
	if (op == 2) result = n1*n2;
	if (op == 3) result = n1/n2;
	
	// adr of result ... adr of result + 4 bytes
	printNum((int*) &result, (int*) &result+1);

	while(1);
}