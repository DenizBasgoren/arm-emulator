
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
    uint16_t next_inst = rom[PC] | rom[PC+1] << 8; // !!!
    

    puts("\x1b[2J\x1b[1;1H");
    puts("Debug instruction!");

    if(GET_BITS(next_inst, 15, 5) == 0b11110) {
        puts("Note: This is a branch prefix instruction");
    }

    printf("Next instruction: 0x%04x @ 0x%08x \n\n", next_inst, PC); /// !!!
    debug_printRegisters();

    uint32_t from, to;
    debug_loop:
    while(1) {
        printf(GRAY_TERM);
        puts("\n\nTo print memory from 100 to 200 (hex), type 100-200");
        puts("To continue to program, type q");
        puts("To disassemble, type d");
        puts("To print registers, type r");
        puts("To toggle -debug, type t");
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
        else if ( *input_string == 'r') {
            debug_printRegisters();
            continue;
        }
        else if ( *input_string == 't') {
            is_debug_mode = 1 - is_debug_mode;
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
    system("arm-none-eabi-objdump -d dist-linux/armapp.elf");
}

void debug_printMemoryBetween(uint32_t from, uint32_t to) {

    int temp = 0;

    for (; from <= to; from++, temp++) {

        struct range new = rangeOf(from);
        if (!new.exists) {
            puts("Not in memory.");
            return;
        }

        uint8_t val = *new.real;

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

    struct range new = rangeOf(from);

    if (!new.exists) {
        puts("Not in memory.");
        return;
    }

    while (1) {
        if (new.real > new.real_max) {
            puts("\nBuffer overflow\n");
            return;
        }
        else if (*new.real == '\0') {
            break;
        }
        else {
            putc( *new.real, stdout);
            new.real += 4;
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
    size_t maxlen;
    
    struct range new = rangeOf(to);
    if (!new.exists) {
        puts("Not in memory.");
        return;
    }

    realAddr = (uint32_t*) new.real;
    maxlen = (size_t) (new.max - to + 1);
    
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