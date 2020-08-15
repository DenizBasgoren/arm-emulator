
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>


#include "emulator.h"
#include "debugger.h"


// fps counters
clock_t debug_lastTime = 0;
int debug_inst_elapsed = 0;

// this gets called on every "bkpt 0" sequence in asm code.
// it lets you see current register values, and memory contents.
// for a per-instruction debugging mode, add -debug flag to args
void debug_dialog () {    
    uint16_t inst = rom[PC - 4] | rom[PC - 3] << 8;


    puts("\x1b[2J\x1b[1;1H");
    puts("Debug instruction!");

    if(GET_BITS(inst, 15, 5) == 0b11110) {
        puts("Note: This is a branch prefix instruction");
    }

    printf("Next instruction: 0x%04x @ 0x%08x \n\n", inst, PC - 4);
    debug_printRegisters();

    uint32_t from, to;
    debug_loop:
    while(1) {
        printf(GRAY_TERM);
        puts("\n\nTo print memory from 100 to 200 (hex), type 100-200");
        puts("To continue to program, type q");
        puts("To disassemble, type d");
        printf(WHITE_TERM);

        char input_string[100];

        scanf("%s", input_string);
        if ( *input_string == 'q') {
            puts("Exited debug mode");
            break;
        }
        else if ( *input_string == 'd') {
            debug_disassemble();
            continue;
        }
        else {
            sscanf(input_string, "%x-%x", &from, &to );
            debug_printMemoryBetween(from, to);
        }

    }
}

void debug_printRegisters() {

    uint8_t N = GET_BITS(FLG, FLG_N, 1);
    uint8_t Z = GET_BITS(FLG, FLG_Z, 1);
    uint8_t C = GET_BITS(FLG, FLG_C, 1);
    uint8_t V = GET_BITS(FLG, FLG_V, 1);

    printf(GREEN_TERM);
    puts("R0 (hex)\tR1 (hex)\tR2 (hex)\tR3 (hex)");
    printf(WHITE_TERM);
    printf("%-8x\t%-8x\t%-8x\t%-8x\n", R0, R1, R2, R3);

    printf(GREEN_TERM);
    puts("R4 (hex)\tR5 (hex)\tR6 (hex)\tR7 (hex)");
    printf(WHITE_TERM);
    printf("%-8x\t%-8x\t%-8x\t%-8x\n", R4, R5, R6, R7);

    printf(GREEN_TERM);
    puts("R8 (hex)\tR9 (hex)\tR10 (hex)\tR11 (hex)");
    printf(WHITE_TERM);
    printf("%-8x\t%-8x\t%-8x\t%-8x\n", R8, R9, R10, R11);

    printf(GREEN_TERM);
    puts("R12 (hex)\tSP (hex)\tLR (hex)\tPC (hex)");
    printf(WHITE_TERM);
    printf("%-8x\t%-8x\t%-8x\t%-8x\n", R12, SP, LR, PC);

    printf(GREEN_TERM);
    puts("FLG_N (hex)\tFLG_Z (hex)\tFLG_C (hex)\tFLG_V (hex)");
    printf(WHITE_TERM);
    printf("%-8x\t%-8x\t%-8x\t%-8x\n", N, Z, C, V);

}

void debug_disassemble() {
    system("arm-none-eabi-objdump -d armapp.elf");
}

void debug_printMemoryBetween(uint32_t from, uint32_t to) {

    printf("Memory %x - %x (inclusive): (%d bytes)\n\n", from, to, to-from+1);

    int temp = 0;

    for (; from <= to; from++, temp++) {

        uint8_t val;
        // get val
        if (from >= ROM_MIN && from <= ROM_MAX) val = rom[from - ROM_MIN];
        else if (from >= RAM_MIN && from <= RAM_MAX) val = ram[from - RAM_MIN];
        else if (from >= GPU_MIN && from <= GPU_MAX) val = gpu[from - GPU_MIN];
        else {
            puts("Not in ROM or RAM.");
            return;
        }

        if ( from % 8 == 0) {
            temp = 0;
        }

        if ( temp % 8 == 0) {
            printf(GREEN_TERM);
            printf("\n%08x\t", from);
            printf(WHITE_TERM);
        }
        
        printf("%02x", val);
        printf(GRAY_TERM);
        if (val > 31 && val < 177)
        printf("'%01c'  ", val );
        else printf("     ");
        printf(WHITE_TERM);

    }
}

// CHAR = 4 BYTE VARIANT
void debug_printMemoryUntilNull(uint32_t from) {
    char* realAddr;
    char* realMax;

    // get val
    if (from >= ROM_MIN && from <= ROM_MAX) {
        realAddr = rom + from - ROM_MIN;
        realMax = rom + ROM_MAX - ROM_MIN;
    }
    else if (from >= RAM_MIN && from <= RAM_MAX) {
        realAddr = ram + from - RAM_MIN;
        realMax = ram + RAM_MAX - RAM_MIN;
    }
    else if (from >= GPU_MIN && from <= GPU_MAX) {
        realAddr = gpu + from - GPU_MIN;
        realMax = gpu + GPU_MAX - GPU_MIN;
    }
    else {
        puts("Not in ROM or RAM.");
        return;
    }

    while (1) {
        if (realAddr > realMax) {
            puts("\nBuffer overflow\n");
            return;
        }
        else if (*realAddr == '\0') {
            break;
        }
        else {
            putc( *realAddr, stdout);
            realAddr += 4;
        }

    }

    fflush(stdout);
}


void debug_printTimer() {
    clock_t curr = clock();
    double time_elapsed = ((double)(curr-debug_lastTime))/CLOCKS_PER_SEC;
    debug_lastTime = curr;
    printf("%f sec \t %d inst\n", time_elapsed, debug_inst_elapsed);
    debug_inst_elapsed = 0;
}


void debug_storeString(char* str, uint32_t to) {
    uint32_t* realAddr;
    int maxlen;
    
    if (to >= ROM_MIN && to <= ROM_MAX) {
        realAddr = (uint32_t*) (rom + to - ROM_MIN);
        maxlen = ROM_MAX - to + 1;
    }
    else if (to >= RAM_MIN && to <= RAM_MAX) {
        realAddr = (uint32_t*) (ram + to - RAM_MIN);
        maxlen = RAM_MAX - to + 1;
    }
    else if (to >= GPU_MIN && to <= GPU_MAX) {
        realAddr = (uint32_t*) (gpu + to - GPU_MIN);
        maxlen = GPU_MAX - to + 1;
    }
    else {
        puts("Not in ROM or RAM.");
        return;
    }

    if ( strlen(str)*4 > maxlen ) {
        puts("Buffer overflow");
        return;
    }
    
    while(1) {
        *realAddr = *str;

        if (*str == '\0') {
            return;
        }
        else {
            str++;
            realAddr++; // will add 4 because uint32_t
        }
    }
    

    return;
}