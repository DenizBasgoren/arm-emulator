
#ifndef _DEBUGGER_H_
#define _DEBUGGER_H_

#include <stdint.h>
#include <time.h>

void debug_dialog(char clearScreen);
void debug_printTimer();
void debug_printMemoryUntilNull(uint32_t from);
void debug_printMemoryBetween(uint32_t from, uint32_t to);
void debug_disassemble();
void debug_printRegisters();
void debug_storeString(char* str, uint32_t to);

// BKPT:
// 0= activate interactive debug dialog
// 1= print registers
// 2= disassemble
// 3= timer call
// 4= print mem between (inclusive)
// 5= print string
// 6= scanf num
// 7= scanf string
// 8= scanf float
// 9= print stack

// fps counters
extern clock_t debug_lastTime;
extern int debug_inst_elapsed;



#endif