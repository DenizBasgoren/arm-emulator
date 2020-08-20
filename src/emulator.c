
// 26 april 2020, version 1
// Deniz Bashgoren  github.com/denizBasgoren
// Cem Belentepe    github.com/theCCB

#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "emulator.h"
#include "emulib.h"
#include "debugger.h"
#include "gpu.h"
#include "nvic.h"


// registers
struct cpu_t cpu;

// memory
uint8_t rom[ROM_LEN];
uint8_t ram[RAM_LEN];
int is_debug_mode;

int32_t execute_next( int is_debug_mode );
void update_nz_flags(int32_t reg);
void update_vr_flags(char carry, char overflow);
void sigint_handler();
int store_to_memory(uint32_t value, uint32_t address, int n_bytes);
int load_from_memory(uint32_t *destination, uint32_t address, int n_bytes);

//Emulator main function
int32_t main(int32_t argc, char* argv[])
{
    if (argc < 3)
    {
        puts("Usage: emulator path/to/rom path/to/ram [, -debug ]");
        return 1;
    }

    // fill rom with 1s
    memset(rom, 0xFF, sizeof(rom));
    memset(ram, 0xFF, sizeof(ram));
    
    // init SDL
    system_init();

    // load bytes to rom
    if (load_program(argv[1], argv[2], rom, ram) < 0) return 1;

    // exit gracefully on ctrl+c
    signal(SIGINT, sigint_handler);


    // all flags 0.
    // T flag should actually be 1, but we simply ignore it here, since cortex m0 supports thumb only
    FLG = 0;

    LR = 0xFFFFFFFF;

    //First 4 bytes in ROM specifies initializes the stack pointer
    load_from_memory( &SP, ROM_MIN, 4);

    // SP must be word aligned
    SP &= ~3;

    //Following 4 bytes in ROM initializes the PC
    load_from_memory( &PC, ROM_MIN+4, 4);

    // gcc will generate _start+1 for thumb, so truncate last bit
    PC &= ~1;

    // PC always points to the first byte of the instr to execute next.
    // PC += 4; // WRONG!

    // on debug mode, execution breaks after every instruction
    is_debug_mode = argc == 4 && !strcmp(argv[3], "-debug");

    // activate timer
    debug_lastTime = clock();

    // main loop
    while (1)
    {
        // Last bit is never 1
        if (PC % 2) {
            puts("Alignment fault");
            return -1;
        }
        
        int err = execute_next( is_debug_mode );
        debug_inst_elapsed++;

        if (err) break;
    }
    
    // Free SDL
    system_deinit();

    return 0;
}


// Flag updater functions
void update_nz_flags(int32_t reg) {
    if(reg == 0) SET_BIT(FLG, FLG_Z);
    else RESET_BIT(FLG, FLG_Z);
    if (reg < 0) SET_BIT(FLG, FLG_N);
    else RESET_BIT(FLG, FLG_N);
}

void update_vc_flags(char c, char v) {
    if (c) SET_BIT(FLG, FLG_C);
    else RESET_BIT(FLG, FLG_C);
    if (v) SET_BIT(FLG, FLG_V);
    else RESET_BIT(FLG, FLG_V);
}


struct additionResult {
    uint32_t result;
    char carry_out;
    char overflow;
};

// manual pg 34, generic m0 guide pg 60
struct additionResult addWithCarry(uint32_t x, uint32_t y, char carry_in, char isAddition) {
    char carry_out, overflow;
    uint32_t result;

    if (isAddition) {
        result = x+y;

        carry_out = (uint64_t) x + (uint64_t) y > (uint64_t) 0xFFFFFFFF;

        int32_t xs = x;
        int32_t ys = y;

        overflow = xs >= 0 && ys >= 0 && xs+ys < 0 ||
                    xs < 0 && ys < 0 && xs+ys >= 0;
    }
    else {
        result = x-y;

        carry_out = x >= y;

        int32_t xs = x;
        int32_t ys = y;

        overflow = xs < 0 && ys >= 0 && xs-ys >= 0 ||
                    xs >= 0 && ys < 0 && xs-ys < 0;
    }
    
    struct additionResult r = {result, carry_out, overflow};

    return r;
}


// ctrl+c handler
void sigint_handler() {
    puts("\nTermination");    
    exit(0);
}

//////////////////////////
// Every time a new peripheral is added, modify these 3 functions:

int store_to_memory(uint32_t value, uint32_t address, int n_bytes) {

    // Adress must be aligned
    if ( address % n_bytes != 0) {
        puts("Cant store to unaligned address!");
        return -1;
    }

    if(address >= ROM_MIN && address <= ROM_MAX) {
        memcpy(rom + address - ROM_MIN, &value, n_bytes);
    }
    else if(address >= RAM_MIN && address <= RAM_MAX) {
        memcpy(ram + address - RAM_MIN, &value, n_bytes);
    }
    else if(address >= GPU_MIN && address <= GPU_MAX)
        gpu_write(address, value, n_bytes);

}

int load_from_memory(uint32_t *destination, uint32_t address, int n_bytes) {
    
    // Adress must be aligned
    if ( address % n_bytes != 0) {
        puts("Cant load from unaligned address!");
        return -1;
    }
    
    if(address >= ROM_MIN && address <= ROM_MAX) {
        memcpy(destination, rom + address - ROM_MIN, n_bytes);
    }
    else if(address >= RAM_MIN && address <= RAM_MAX) { 
        memcpy(destination, ram + address - RAM_MIN, n_bytes);
    }
    else if(address >= GPU_MIN && address <= GPU_MAX)
        gpu_read(address, destination, n_bytes);
}

struct range rangeOf(uint32_t from) {
    
    struct range new;

    uint32_t mins[] = {ROM_MIN, RAM_MIN, GPU_MIN, NVIC_MIN};
    uint32_t maxs[] = {ROM_MAX, RAM_MAX, GPU_MAX, NVIC_MAX};
    int lens[] = {ROM_LEN, RAM_LEN, GPU_LEN, NVIC_LEN};
    char* adrs[] = {rom, ram, gpu, nvic};
    int regions = 3;

    new.exists = 0;

    for (int i = 0; i<regions; i++) {
        if(from >= mins[i] && from <= maxs[i]) {
            new.exists = 1;
            new.min = mins[i];
            new.max = maxs[i];
            new.len = lens[i];
            new.real = from -  mins[i] + adrs[i];
            new.real_min = adrs[i];
            new.real_max = adrs[i] + lens[i] - 1;
        }
    }

    return new;
}

// End of the 3 memory functions
/////////////////////////////////


//Fetches an instruction from ROM, decodes and executes it
int32_t execute_next( int is_debug_mode )
{
    uint16_t inst = rom[PC] | rom[PC + 1] << 8; // !!!

    if (is_debug_mode) {
        debug_dialog(1); // clear screen
    }


    // LSL Rd, Rm, immed
    if (GET_BITS(inst, 15, 5) == 0b00000) {
        uint8_t immed = GET_BITS(inst, 10, 5);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint8_t rd = GET_BITS(inst, 2, 3);

        uint32_t rm_ = cpu.reg[rm];
        int carry = GET_BITS(rm_, 31-immed, 1);

        uint32_t rc = rm_ << immed;
        cpu.reg[rd] = rc;

        update_nz_flags(rc);

        // if immed is positive, update carry
        if (immed > 0) {
            if (carry) SET_BIT(FLG, FLG_C);
            else RESET_BIT(FLG, FLG_C);
        }

        PC += 2;
        return 0;
    }

    // LSR Rd, Rm, immed
    else if (GET_BITS(inst, 15, 5) == 0b00001) {
        uint8_t immed = GET_BITS(inst, 10, 5);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint8_t rd = GET_BITS(inst, 2, 3);

        uint32_t rm_ = cpu.reg[rm];

        // update carry
        int carry;
        if (immed > 0) {
            carry = GET_BITS(rm_, immed-1, 1);

            if (carry) SET_BIT(FLG, FLG_C);
            else RESET_BIT(FLG, FLG_C);
        }

        uint32_t rc = rm_ >> immed;
        cpu.reg[rd] = rc;

        update_nz_flags(rc);

        PC += 2;
        return 0;
    }

    // ASR Rd, Rm, immed
    else if (GET_BITS(inst, 15, 5) == 0b00010) {
        uint8_t immed = GET_BITS(inst, 10, 5);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint8_t rd = GET_BITS(inst, 2, 3);

        int32_t rm_ = cpu.reg[rm];
        int carry = GET_BITS(rm_, 31-immed, 1);

        int32_t rc = rm_ >> immed;
        cpu.reg[rd] = rc;

        update_nz_flags(rc);

        // if immed is positive, update carry
        if (immed > 0) {
            if (carry) SET_BIT(FLG, FLG_C);
            else RESET_BIT(FLG, FLG_C);
        }

        PC += 2;
        return 0;
    }

    // ADD Rd, Rn, Rm
    else if (GET_BITS(inst, 15, 7) == 0b0001100) {
        uint8_t rm = GET_BITS(inst, 8, 3);
        uint8_t rn = GET_BITS(inst, 5, 3);
        uint8_t rd = GET_BITS(inst, 2, 3);

        uint32_t ra = cpu.reg[rn];
        uint32_t rb = cpu.reg[rm];

        struct additionResult r = addWithCarry(ra, rb, 0, 1);
        update_nz_flags(r.result);
        update_vc_flags(r.carry_out, r.overflow);
        cpu.reg[rd] = r.result;

        PC += 2;
        return 0;
    }

    // SUB Rd, Rn, Rm
    else if (GET_BITS(inst, 15, 7) == 0b0001101) {
        uint8_t rm = GET_BITS(inst, 8, 3);
        uint8_t rn = GET_BITS(inst, 5, 3);
        uint8_t rd = GET_BITS(inst, 2, 3);

        uint32_t ra = cpu.reg[rn];
        uint32_t rb = cpu.reg[rm];
        
        struct additionResult r = addWithCarry(ra, rb, 0, 0);
        update_nz_flags(r.result);
        update_vc_flags(r.carry_out, r.overflow);
        cpu.reg[rd] = r.result;

        PC += 2;
        return 0;
    }

    // ADD Rd, Rn, immed
    else if (GET_BITS(inst, 15, 7) == 0b0001110) {
        uint8_t immed = GET_BITS(inst, 8, 3);
        uint8_t rn = GET_BITS(inst, 5, 3);
        uint8_t rd = GET_BITS(inst, 2, 3);

        uint32_t ra = cpu.reg[rn];
        
        struct additionResult r = addWithCarry(ra, immed, 0, 1);
        update_nz_flags(r.result);
        update_vc_flags(r.carry_out, r.overflow);
        cpu.reg[rd] = r.result;

        PC += 2;
        return 0;
    }

    // SUB Rd, Rn, immed
    else if (GET_BITS(inst, 15, 7) == 0b0001111) {
        uint8_t immed = GET_BITS(inst, 8, 3);
        uint8_t rn = GET_BITS(inst, 5, 3);
        uint8_t rd = GET_BITS(inst, 2, 3);

        uint32_t ra = cpu.reg[rn];
        
        struct additionResult r = addWithCarry(ra, immed, 0, 0);
        update_nz_flags(r.result);
        update_vc_flags(r.carry_out, r.overflow);
        cpu.reg[rd] = r.result;

        PC += 2;
        return 0;
    }

    // MOV Rd, immed
    else if (GET_BITS(inst, 15, 5) == 0b00100) {
        uint8_t rd = GET_BITS(inst, 10, 3);
        uint8_t immed = GET_BITS(inst, 7, 8);

        cpu.reg[rd] = immed;

        update_nz_flags( cpu.reg[rd] );
        PC += 2;
        return 0;
    }

    // CMP Rm, immed
    else if (GET_BITS(inst, 15, 5) == 0b00101) {
        uint8_t rn = GET_BITS(inst, 10, 3);
        uint8_t immed = GET_BITS(inst, 7, 8);

        uint32_t ra = cpu.reg[rn];
        
        struct additionResult r = addWithCarry(ra, immed, 0, 0);
        update_nz_flags(r.result);
        update_vc_flags(r.carry_out, r.overflow);

        PC += 2;
        return 0;
    }

    // ADD Rd, immed
    else if (GET_BITS(inst, 15, 5) == 0b00110) {
        uint8_t rd = GET_BITS(inst, 10, 3);
        uint8_t immed = GET_BITS(inst, 7, 8);

        uint32_t ra = cpu.reg[rd];

        struct additionResult r = addWithCarry(ra, immed, 0, 1);
        update_nz_flags(r.result);
        update_vc_flags(r.carry_out, r.overflow);
        cpu.reg[rd] = r.result;

        PC += 2;
        return 0;
    }

    // SUB Rd, immed
    else if (GET_BITS(inst, 15, 5) == 0b00111) {
        uint8_t rd = GET_BITS(inst, 10, 3);
        uint8_t immed = GET_BITS(inst, 7, 8);

        uint32_t ra = cpu.reg[rd];
        
        struct additionResult r = addWithCarry(ra, immed, 0, 0);
        update_nz_flags(r.result);
        update_vc_flags(r.carry_out, r.overflow);
        cpu.reg[rd] = r.result;

        PC += 2;
        return 0;
    }

    // AND Rd, Rm
    else if (GET_BITS(inst, 15, 10) == 0b0100000000)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint32_t ra = cpu.reg[rd];
        uint32_t rb = cpu.reg[rm];
        uint32_t rc = ra & rb;
        cpu.reg[rd] = rc;
        
        update_nz_flags(rc);
        PC += 2;
        return 0;
    }

    // EOR Rd, Rm
    else if (GET_BITS(inst, 15, 10) == 0b0100000001)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint32_t ra = cpu.reg[rd];
        uint32_t rb = cpu.reg[rm];
        uint32_t rc = ra ^ rb;
        cpu.reg[rd] = rc;
        
        update_nz_flags(rc);
        PC += 2;
        return 0;
    }

    // LSL Rd, Rm
    else if (GET_BITS(inst, 15, 10) == 0b0100000010)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint32_t ra = cpu.reg[rd];
        uint32_t rb = GET_BITS(cpu.reg[rm], 7, 8);
        uint32_t rc = ra << rb;
        cpu.reg[rd] = rc;
        
        int carry = GET_BITS(ra, 31-rb, 1);

        update_nz_flags(rc);

        // if shift is positive, update carry
        if (rb > 0) {
            if (carry) SET_BIT(FLG, FLG_C);
            else RESET_BIT(FLG, FLG_C);
        }

        PC += 2;
        return 0;
    }

    // LSR Rd, Rm
    else if (GET_BITS(inst, 15, 10) == 0b0100000011)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint32_t ra = cpu.reg[rd];
        uint32_t rb = GET_BITS(cpu.reg[rm], 7, 8);
        uint32_t rc = ra >> rb;
        cpu.reg[rd] = rc;
        
        int carry = GET_BITS(ra, rb-1, 1);

        update_nz_flags(rc);

        // if shift is positive, update carry
        if (rb > 0) {
            if (carry) SET_BIT(FLG, FLG_C);
            else RESET_BIT(FLG, FLG_C);
        }

        PC += 2;
        return 0;
    }

    // ASR Rd, Rm
    else if (GET_BITS(inst, 15, 10) == 0b0100000100)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        int32_t ra = cpu.reg[rd];
        int32_t rb = GET_BITS(cpu.reg[rm], 7, 8);
        int32_t rc = ra >> rb;
        cpu.reg[rd] = rc;
        
        update_nz_flags(rc);

        int carry = GET_BITS(ra, rb-1, 1);
        // if shift is positive, update carry
        if (rb > 0) {
            if (carry) SET_BIT(FLG, FLG_C);
            else RESET_BIT(FLG, FLG_C);
        }

        PC += 2;
        return 0;
    }

    // ADC Rd, Rm
    else if (GET_BITS(inst, 15, 10) == 0b0100000101)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint32_t ra = cpu.reg[rd];
        uint32_t rb = cpu.reg[rm];
        int carry = GET_BITS(FLG, FLG_C, 1);
        
        struct additionResult r = addWithCarry(ra, rb, carry, 1);
        update_nz_flags(r.result);
        update_vc_flags(r.carry_out, r.overflow);
        cpu.reg[rd] = r.result;

        PC += 2;
        return 0;
    }

    // SBC Rd, Rm
    else if (GET_BITS(inst, 15, 10) == 0b0100000110)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint32_t ra = cpu.reg[rd];
        uint32_t rb = cpu.reg[rm];
        int carry = GET_BITS(FLG, FLG_C, 1);
        
        struct additionResult r = addWithCarry(ra, rb, carry, 0);
        update_nz_flags(r.result);
        update_vc_flags(r.carry_out, r.overflow);
        cpu.reg[rd] = r.result;

        PC += 2;
        return 0;
    }

    // ROR Rd, Rm
    else if (GET_BITS(inst, 15, 10) == 0b0100000111)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint32_t ra = cpu.reg[rd];
        uint32_t rb = GET_BITS(cpu.reg[rm], 7, 8) % 32;
        uint32_t rc = (ra >> rb) | (ra << (32 - rb));
        cpu.reg[rd] = rc;
        
        update_nz_flags(rc);
        int carry = GET_BITS(ra, rb-1, 1);

        if (rb > 0) {
            if (carry) SET_BIT(FLG, FLG_C);
            else RESET_BIT(FLG, FLG_C);
        }

        PC += 2;
        return 0;
    }

    // TST Rd, Rm
    else if (GET_BITS(inst, 15, 10) == 0b0100001000)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint32_t ra = cpu.reg[rd];
        uint32_t rb = cpu.reg[rm];
        uint32_t rc = ra & rb;
        
        update_nz_flags(rc);
        PC += 2;
        return 0;
    }

    // NEG Rd, Rm
    // same as rd = ~rm + 1
    else if (GET_BITS(inst, 15, 10) == 0b0100001001)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint32_t ra = cpu.reg[rm];
        uint32_t rc = ~ra+1;
        cpu.reg[rd] = rc;
        
        update_nz_flags(rc);
        PC += 2;
        return 0;
    }

    // CMP Rd, Rm
    else if (GET_BITS(inst, 15, 10) == 0b0100001010)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint32_t ra = cpu.reg[rd];
        uint32_t rb = cpu.reg[rm];
        
        struct additionResult r = addWithCarry(ra, rb, 0, 0);
        update_nz_flags(r.result);
        update_vc_flags(r.carry_out, r.overflow);

        PC += 2;
        return 0;
    }

    // CMN Rd, Rm
    else if (GET_BITS(inst, 15, 10) == 0b0100001011)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint32_t ra = cpu.reg[rd];
        uint32_t rb = cpu.reg[rm];
       
        struct additionResult r = addWithCarry(ra, rb, 0, 1);
        update_nz_flags(r.result);
        update_vc_flags(r.carry_out, r.overflow);

        PC += 2;
        return 0;
    }

    // ORR Rd, Rm
    else if (GET_BITS(inst, 15, 10) == 0b0100001100)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint32_t ra = cpu.reg[rd];
        uint32_t rb = cpu.reg[rm];
        uint32_t rc = ra | rb;
        cpu.reg[rd] = rc;

        PC += 2;
        update_nz_flags(rc);
        return 0;
    }

    // MUL Rd, Rm
    else if (GET_BITS(inst, 15, 10) == 0b0100001101)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint32_t ra = cpu.reg[rd];
        uint32_t rb = cpu.reg[rm];
        uint32_t rc = ra * rb;
        cpu.reg[rd] = rc;
        
        update_nz_flags(rc);
        PC += 2;
        return 0;
    }

    // BIC Rd, Rm
    else if (GET_BITS(inst, 15, 10) == 0b0100001110)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint32_t ra = cpu.reg[rd];
        uint32_t rb = cpu.reg[rm];
        uint32_t rc = ra & ~rb;
        cpu.reg[rd] = rc;
        
        update_nz_flags(rc);
        PC += 2;
        return 0;
    }

    // MVN Rd, Rm
    else if (GET_BITS(inst, 15, 10) == 0b0100001111)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint32_t ra = cpu.reg[rm];
        uint32_t rc = ~ra;
        cpu.reg[rd] = rc;
        
        update_nz_flags(rc);
        PC += 2;
        return 0;
    }

    // CPY Rd, Rm
    // same as mov rd, rm but doesnt affect nz
    else if (GET_BITS(inst, 15, 10) == 0b0100011000)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint32_t ra = cpu.reg[rm];
        cpu.reg[rd] = ra;
        
        PC += 2;
        return 0;
    }

    // ADD Ld, Hm
    else if (GET_BITS(inst, 15, 10) == 0b0100010001)
    {
        uint8_t ld = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint32_t ra = cpu.reg[ld];
        uint32_t rb = cpu.reg[rm+8];
        
        ra += rb;
        cpu.reg[ld] = ra;

        PC += 2;
        return 0;
    }

    // MOV Ld, Hm
    else if (GET_BITS(inst, 15, 10) == 0b0100011001)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint32_t ra = cpu.reg[rd];
        uint32_t rb = cpu.reg[rm+8];
        
        ra = rb;
        cpu.reg[rd] = ra;
        
        PC += 2;
        return 0;
    }

    // ADD Hd, Lm
    else if (GET_BITS(inst, 15, 10) == 0b0100010010)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint32_t ra = cpu.reg[rd+8];
        uint32_t rb = cpu.reg[rm];
        
        ra += rb;
        cpu.reg[rd+8] = ra;

        if (rd != 7) { // increment only if we didnt set to it
            PC += 2;
        }

        return 0;
    }

    // MOV Hd, Lm
    else if (GET_BITS(inst, 15, 10) == 0b0100011010)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint32_t ra = cpu.reg[rd+8];
        uint32_t rb = cpu.reg[rm];
        
        ra = rb;
        cpu.reg[rd+8] = ra;
        
        if (rd != 7) { // increment only if we didnt set to it
            PC += 2;
        }

        return 0;
    }

    // ADD Hd, Hm
    else if (GET_BITS(inst, 15, 10) == 0b0100010011)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint32_t ra = cpu.reg[rd+8];
        uint32_t rb = cpu.reg[rm+8];
        
        ra += rb;
        cpu.reg[rd+8] = ra;
        
        if (rd != 7) { // increment only if we didnt set to it
            PC += 2;
        }

        return 0;
    }

    // MOV Hd, Hm
    else if (GET_BITS(inst, 15, 10) == 0b0100011011)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint32_t ra = cpu.reg[rd+8];
        uint32_t rb = cpu.reg[rm+8];
        
        ra = rb;
        cpu.reg[rd+8] = ra;
        
        if (rd != 7) { // increment only if we didnt set to it
            PC += 2;
        }

        return 0;
    }


    // note: CMP Rn, Rm == Rn-Rm
    // CMP Ln, Hm
    else if (GET_BITS(inst, 15, 10) == 0b0100010101)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint32_t ra = cpu.reg[rd];
        uint32_t rb = cpu.reg[rm+8];
        
        
        struct additionResult r = addWithCarry(ra, rb, 0, 0);
        update_nz_flags(r.result);
        update_vc_flags(r.carry_out, r.overflow);

        PC += 2;
        return 0;
    }

    // CMP Hn, Lm
    else if (GET_BITS(inst, 15, 10) == 0b0100010110)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint32_t ra = cpu.reg[rd+8];
        uint32_t rb = cpu.reg[rm];
        
        
        struct additionResult r = addWithCarry(ra, rb, 0, 0);
        update_nz_flags(r.result);
        update_vc_flags(r.carry_out, r.overflow);

        PC += 2;
        return 0;
    }

    // CMP Hn, Hm
    else if (GET_BITS(inst, 15, 10) == 0b0100010111)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint32_t ra = cpu.reg[rd+8];
        uint32_t rb = cpu.reg[rm+8];
        
        
        struct additionResult r = addWithCarry(ra, rb, 0, 0);
        update_nz_flags(r.result);
        update_vc_flags(r.carry_out, r.overflow);

        PC += 2;
        return 0;
    }
    
    // BX Rm
    else if(GET_BITS(inst, 15, 9) == 0b010001110){
        uint8_t rm = GET_BITS(inst, 6, 4);
        
        PC = cpu.reg[rm] &~ 1; // TODO TEST
        return 0;
    }

    // BLX Rm
    else if(GET_BITS(inst, 15, 9) == 0b010001111){ // TODO TEST
        uint8_t rm = GET_BITS(inst, 6, 4);

        // here, temp is needed, because if cpu.reg[rm] == lr, we lose the value in lr
        uint32_t temp = PC;
        PC = cpu.reg[rm] &~ 1;
        LR = temp + 2; // return to next instr
        LR += 1; // plus one to be compatible with thumb code

        return 0;
    }

    // LDR Ld, [ pc, immed * 4 ]
    else if (GET_BITS(inst, 15, 5) == 0b01001)
    {
        uint8_t rd = GET_BITS(inst, 10, 3);
        uint8_t immed = GET_BITS(inst, 7, 8);
        
        // +4 here because of fetch decode execute cycles
        load_from_memory( &cpu.reg[rd], (PC + 4 + immed * 4) & ~3 , 4); // !!!
        // https://stackoverflow.com/questions/29586536/about-arm-pc-value-in-thumb-16-32bits-mixed-instructions-stream
        // https://stackoverflow.com/questions/24091566/why-does-the-arm-pc-register-point-to-the-instruction-after-the-next-one-to-be-e
        // https://soundcloud.com/university-of-cambridge/a-history-of-the-arm-architecture-and-the-lessons-learned-while-building-it
        // https://en.wikipedia.org/wiki/Delay_slot

        PC += 2;
        return 0;
    }

    // STR Rd, [Rn, Rm]
    // store value in rd, in address rn+rm (see page 66)
    else if (GET_BITS(inst, 15, 7) == 0b0101000)
    {
        uint8_t rm = GET_BITS(inst, 8, 3);
        uint8_t rn = GET_BITS(inst, 5, 3);
        uint8_t rd = GET_BITS(inst, 2, 3);

        uint32_t addr = cpu.reg[rm] + cpu.reg[rn];

        store_to_memory( cpu.reg[rd], addr, 4);

        PC += 2;
        return 0;
    }

    // STRH Rd, [Rn, Rm]
    else if (GET_BITS(inst, 15, 7) == 0b0101001)
    {
        uint8_t rm = GET_BITS(inst, 8, 3);
        uint8_t rn = GET_BITS(inst, 5, 3);
        uint8_t rd = GET_BITS(inst, 2, 3);

        uint32_t addr = cpu.reg[rm] + cpu.reg[rn];

        store_to_memory( cpu.reg[rd], addr, 2);

        PC += 2;
        return 0;
    }

    // STRB Rd, [Rn, Rm]
    else if (GET_BITS(inst, 15, 7) == 0b0101010)
    {
        uint8_t rm = GET_BITS(inst, 8, 3);
        uint8_t rn = GET_BITS(inst, 5, 3);
        uint8_t rd = GET_BITS(inst, 2, 3);

        uint32_t addr = cpu.reg[rm] + cpu.reg[rn];

        store_to_memory( cpu.reg[rd], addr, 1);

        PC += 2;
        return 0;
    }

    // LDRSB Rd, [Rn, Rm]
    else if (GET_BITS(inst, 15, 7) == 0b0101011)
    {
        uint8_t rm = GET_BITS(inst, 8, 3);
        uint8_t rn = GET_BITS(inst, 5, 3);
        uint8_t rd = GET_BITS(inst, 2, 3);

        uint32_t addr = cpu.reg[rm] + cpu.reg[rn];

        load_from_memory( &cpu.reg[rd], addr, 1);
        cpu.reg[rd] <<= 24; // sign extended
        cpu.reg[rd] >>= 24;

        PC += 2;
        return 0;
    }

    // LDR Rd, [Rn, Rm]
    // load val in rn+rm into rd
    else if (GET_BITS(inst, 15, 7) == 0b0101100)
    {
        uint8_t rm = GET_BITS(inst, 8, 3);
        uint8_t rn = GET_BITS(inst, 5, 3);
        uint8_t rd = GET_BITS(inst, 2, 3);

        uint32_t addr = cpu.reg[rm] + cpu.reg[rn];

        load_from_memory( &cpu.reg[rd], addr, 4);

        PC += 2;
        return 0;
    }

    // LDRH Rd, [Rn, Rm]
    else if (GET_BITS(inst, 15, 7) == 0b0101101)
    {
        uint8_t rm = GET_BITS(inst, 8, 3);
        uint8_t rn = GET_BITS(inst, 5, 3);
        uint8_t rd = GET_BITS(inst, 2, 3);

        uint32_t addr = cpu.reg[rm] + cpu.reg[rn];

        cpu.reg[rd] = 0; // zero extended
        load_from_memory( &cpu.reg[rd], addr, 2);

        PC += 2;
        return 0;
    }

    // LDRB Rd, [Rn, Rm]
    else if (GET_BITS(inst, 15, 7) == 0b0101110)
    {
        uint8_t rm = GET_BITS(inst, 8, 3);
        uint8_t rn = GET_BITS(inst, 5, 3);
        uint8_t rd = GET_BITS(inst, 2, 3);

        uint32_t addr = cpu.reg[rm] + cpu.reg[rn];

        cpu.reg[rd] = 0; // zero extended
        load_from_memory( &cpu.reg[rd], addr, 1);

        PC += 2;
        return 0;
    }

    // LDRSH Rd, [Rn, Rm]
    else if (GET_BITS(inst, 15, 7) == 0b0101111)
    {
        uint8_t rm = GET_BITS(inst, 8, 3);
        uint8_t rn = GET_BITS(inst, 5, 3);
        uint8_t rd = GET_BITS(inst, 2, 3);

        uint32_t addr = cpu.reg[rm] + cpu.reg[rn];

        load_from_memory( &cpu.reg[rd], addr, 2);
        cpu.reg[rd] <<= 16; // sign extended
        cpu.reg[rd] >>= 16;

        PC += 2;
        return 0;
    }

    // STR Ld, [Ln, immed * 4]
    else if (GET_BITS(inst, 15, 5) == 0b01100)
    {
        uint8_t immed = GET_BITS(inst, 10, 5);
        uint8_t rn = GET_BITS(inst, 5, 3);
        uint8_t rd = GET_BITS(inst, 2, 3);

        uint32_t addr = cpu.reg[rn] + 4 * immed;

        store_to_memory( cpu.reg[rd], addr, 4);

        PC += 2;
        return 0;
    }

    // LDR Ld, [Ln, immed*4 ]
    else if (GET_BITS(inst, 15, 5) == 0b01101)
    {
        uint8_t immed = GET_BITS(inst, 10, 5);
        uint8_t rn = GET_BITS(inst, 5, 3);
        uint8_t rd = GET_BITS(inst, 2, 3);

        uint32_t addr = cpu.reg[rn] + 4 * immed;

        load_from_memory( &cpu.reg[rd], addr, 4);

        PC += 2;
        return 0;
    }

    // STRB Ld, [Ln, immed]
    else if (GET_BITS(inst, 15, 5) == 0b01110) {
        uint8_t immed = GET_BITS(inst, 10, 5);
        uint8_t rn = GET_BITS(inst, 5, 3);
        uint8_t rd = GET_BITS(inst, 2, 3);

        uint32_t addr = cpu.reg[rn] + immed;

        store_to_memory( cpu.reg[rd], addr, 1);

        PC += 2;
        return 0;
    }

    // LDRB Ld, [Ln, immed]
    else if (GET_BITS(inst, 15, 5) == 0b01111) {
        uint8_t immed = GET_BITS(inst, 10, 5);
        uint8_t rn = GET_BITS(inst, 5, 3);
        uint8_t rd = GET_BITS(inst, 2, 3);

        uint32_t addr = cpu.reg[rn] + immed;

        cpu.reg[rd] = 0;
        load_from_memory( &cpu.reg[rd], addr, 1);

        PC += 2;
        return 0;
    }

    // STRH Ld, [Ln, immed*2]
    else if (GET_BITS(inst, 15, 5) == 0b10000) {
        uint8_t immed = GET_BITS(inst, 10, 5);
        uint8_t rn = GET_BITS(inst, 5, 3);
        uint8_t rd = GET_BITS(inst, 2, 3);

        uint32_t addr = cpu.reg[rn] + 2 * immed;

        store_to_memory( cpu.reg[rd], addr, 2);

        PC += 2;
        return 0;
    }

    // LDRH Ld, [Ln, immed*2]
    else if (GET_BITS(inst, 15, 5) == 0b10001) {
        uint8_t immed = GET_BITS(inst, 10, 5);
        uint8_t rn = GET_BITS(inst, 5, 3);
        uint8_t rd = GET_BITS(inst, 2, 3);

        uint32_t addr = cpu.reg[rn] + 2 * immed;

        cpu.reg[rd] = 0; // zero extended
        load_from_memory( &cpu.reg[rd], addr, 2);

        PC += 2;
        return 0;
    }

    // STR Ld, [sp, immed*4]
    else if (GET_BITS(inst, 15, 5) == 0b10010)
    {
        uint8_t rd = GET_BITS(inst, 10, 3);
        uint8_t immed = GET_BITS(inst, 7, 8);

        uint32_t addr = SP + immed * 4;

        store_to_memory( cpu.reg[rd], addr, 4);

        PC += 2;
        return 0;
    }

    // LDR Ld, [sp, immed*4]
    else if (GET_BITS(inst, 15, 5) == 0b10011)
    {
        uint8_t rd = GET_BITS(inst, 10, 3);
        uint8_t immed = GET_BITS(inst, 7, 8);

        uint32_t addr = SP + immed * 4;

        load_from_memory( &cpu.reg[rd], addr, 4);

        PC += 2;
        return 0;
    }

    // ADD Ld, pc, immed*4
    // ld = pc + immed*4 (page 75)
    else if (GET_BITS(inst, 15, 5) == 0b10100)
    {
        uint8_t rd = GET_BITS(inst, 10, 3);
        uint8_t immed = GET_BITS(inst, 7, 8);
        uint32_t immed_times_4 = immed * 4;

        cpu.reg[rd] = PC + immed_times_4 + 4; // !!!
        // +4 here because of fetch decode exec cycle.
        // NOT TESTED, RARE

        // Adress must be divisible by 4. so, truncate last two bits.
        cpu.reg[rd] &= ~3;

        PC += 2;
        return 0;
    }

    // ADD Ld, sp, immed * 4
    else if (GET_BITS(inst, 15, 5) == 0b10101)
    {
        uint8_t rd = GET_BITS(inst, 10, 3);
        uint8_t immed = GET_BITS(inst, 7, 8);
        uint32_t immed_times_4 = immed * 4;

        cpu.reg[rd] = SP + immed_times_4;
        
        // Adress must be divisible by 4. so, truncate last two bits.
        cpu.reg[rd] &= ~3;

        PC += 2;
        return 0;
    }

    // ADD sp, immed*4
    // sp += immed * 4
    else if (GET_BITS(inst, 15, 9) == 0b101100000)
    {
        uint8_t immed = GET_BITS(inst, 6, 7);
        uint32_t immed_times_4 = immed * 4;
        SP = SP + immed_times_4;

        PC += 2;
        return 0;
    }

    // SUB sp, immed*4
    else if (GET_BITS(inst, 15, 9) == 0b101100001)
    {
        uint8_t immed = GET_BITS(inst, 6, 7);
        uint32_t immed_times_4 = immed * 4;
        SP = SP - immed_times_4;

        PC += 2;
        return 0;
    }

    // SXTH Ld, Lm
    else if (GET_BITS(inst, 15, 10) == 0b1011001000) {
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint8_t rd = GET_BITS(inst, 2, 3);
        int32_t temp = cpu.reg[rm];
        temp <<= 16;
        temp >>= 16;

        cpu.reg[rd] = temp;

        PC += 2;
        return 0;
    }

    // SXTB Ld, Lm
    else if (GET_BITS(inst, 15, 10) == 0b1011001001) {
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint8_t rd = GET_BITS(inst, 2, 3);
        int32_t temp = cpu.reg[rm];
        temp <<= 24;
        temp >>= 24;

        cpu.reg[rd] = temp;

        PC += 2;
        return 0;
    }

    // UXTH Ld, Lm
    else if (GET_BITS(inst, 15, 10) == 0b1011001010) {
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint32_t temp = cpu.reg[rm];
        temp <<= 16;
        temp >>= 16;

        cpu.reg[rd] = temp;

        PC += 2;
        return 0;
    }

    // UXTB Ld, Lm
    else if (GET_BITS(inst, 15, 10) == 0b1011001011) {
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint32_t temp = cpu.reg[rm];
        temp <<= 24;
        temp >>= 24;

        cpu.reg[rd] = temp;

        PC += 2;
        return 0;
    }

    // REV Ld, Lm
    else if (GET_BITS(inst, 15, 10) == 0b1011101000) {
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint32_t r = cpu.reg[rm];

        cpu.reg[rd] =   GET_BITS(r, 31, 8) |
                        GET_BITS(r, 23, 8) << 8 |
                        GET_BITS(r, 15, 8) << 16 |
                        GET_BITS(r, 7, 8) << 24;

        PC += 2;
        return 0;
    }

    // REV16 Ld, Lm
    else if (GET_BITS(inst, 15, 10) == 0b1011101001) {
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint32_t r = cpu.reg[rm];

        cpu.reg[rd] =   GET_BITS(r, 31, 8) << 16 |
                        GET_BITS(r, 23, 8) << 24 |
                        GET_BITS(r, 15, 8) |
                        GET_BITS(r, 7, 8) << 8;

        PC += 2;
        return 0;
    }

    // REVSH Ld, Lm
    else if (GET_BITS(inst, 15, 10) == 0b1011101011) {
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint32_t r = cpu.reg[rm];

        cpu.reg[rd] =   GET_BITS(r, 15, 8) |
                        GET_BITS(r, 7, 8) << 8;
        
        cpu.reg[rd] <<= 16;
        cpu.reg[rd] >>= 16;

        PC += 2;
        return 0;
    }


    // PUSH R, reglist
    // reglist : one hot encoded [r7, r6 ... r0]
    // R : include LR
    else if (GET_BITS(inst, 15, 7) == 0b1011010)
    {
        uint8_t r = GET_BITS(inst, 8, 1);
        uint8_t list = GET_BITS(inst, 7, 8);
        uint32_t addr = SP;

        if(r == 1){
            addr -= 4; // stack is full descending
            store_to_memory(LR, addr, 4);
        }

        for(int i = 7; i >= 0; i--){
            if((list & (1 << i)) != 0){
                addr -= 4;
                store_to_memory( cpu.reg[i], addr, 4);
            }
        }

        SP = addr;
        PC += 2;
        return 0;
    }

    // POP R, reglist
    // reglist: [r7, r6, ... r0]
    // R: include PC
    else if (GET_BITS(inst, 15, 7) == 0b1011110)
    {
        uint8_t r = GET_BITS(inst, 8, 1);
        uint8_t list = GET_BITS(inst, 7, 8);
        uint32_t addr = SP;

        for(int i = 0; i < 8; i++){
            if((list & (1 << i)) != 0){
                load_from_memory( &cpu.reg[i], addr, 4);
                addr += 4;
            }
        }
        
        if(r == 1){
            load_from_memory( &PC, addr, 4);
            PC &= ~1; // Must be aligned

            addr += 4;
        }
        else {
            PC += 2; // TODO TEST
        }

        SP = addr;
        return 0;
    }

    // TODO! CPSIE CPSID ?

    // BKPT immed8
    else if (GET_BITS(inst, 15, 8) == 0b10111110) {

        uint8_t code = GET_BITS(inst, 7, 8);

        // activate interactive debug dialog
        if (code == 0) {
            if ( !is_debug_mode ) debug_dialog(R0);
        }

        // print registers
        else if (code == 1) {
            debug_printRegisters();
        }

        // disassemble
        else if (code == 2) {
            debug_disassemble();
        }

        // timer call
        else if (code == 3) {
            debug_printTimer();
        }

        // print mem between a, b
        else if (code == 4) {
            if (R0 > R1) puts("From > to is not possible");
            else debug_printMemoryBetween(R0, R1);
        }

        // print string from a
        else if (code == 5) {
            debug_printMemoryUntilNull(R0);
        }

        // scanf num
        else if (code == 6) {
            int input;
            printf(">");
            scanf("%d", &input);
            store_to_memory(input, R0, 4);
        }

        // scanf string
        else if (code == 7) {
            char input[100];
            printf(">");
            scanf("%s", input);
            debug_storeString(input, R0);
        }

        // scanf float
        else if (code == 8) {
            union view {
                uint32_t ui;
                float f;
            } v;

            printf(">");
            scanf("%f", &v.f);
            store_to_memory(v.ui, R0, 4);
        }

        // print stack
        else if (code == 9) {
            debug_printMemoryBetween(SP, RAM_MAX);
        }

        else {
            puts("Breakpoint with unknown code");
            return -1;
        }

        PC += 2;
        return 0;
    }

    // STMIA Ln! , reglist
    else if (GET_BITS(inst, 15, 5) == 0b11000) {
        uint8_t rn = GET_BITS(inst, 10, 3);
        uint8_t list = GET_BITS(inst, 7, 8);
        uint32_t addr = cpu.reg[rn];

        for(int i = 0; i < 8; i++){
            if((list & (1 << i)) != 0){
                store_to_memory( cpu.reg[i], addr, 4);
                addr += 4;
            }
        }

        // writeback
        load_from_memory( &cpu.reg[rn], addr-4, 4);

        PC += 2;
        return 0;
    }

    // LDMIA Ln! , reglist
    else if (GET_BITS(inst, 15, 5) == 0b11001) {
        uint8_t rn = GET_BITS(inst, 10, 3);
        uint8_t list = GET_BITS(inst, 7, 8);
        uint32_t addr = cpu.reg[rn];

        for(int i = 0; i < 8; i++){
            if((list & (1 << i)) != 0){
                load_from_memory( &cpu.reg[i], addr, 4);
                addr += 4;
            }
        }

        // writeback
        load_from_memory( &cpu.reg[rn], addr-4, 4);

        PC += 2;
        return 0;
    }


    // B(Cond) inst_address + 4 + signed_offset * 2
    else if (GET_BITS(inst, 15, 4) == 0b1101 && GET_BITS(inst, 11, 4) < 0b1110) {
        uint8_t N = GET_BITS(FLG, FLG_N, 1);
        uint8_t Z = GET_BITS(FLG, FLG_Z, 1);
        uint8_t C = GET_BITS(FLG, FLG_C, 1);
        uint8_t V = GET_BITS(FLG, FLG_V, 1);

        uint8_t cond = GET_BITS(inst, 11, 4);
        int should_branch = 0;
        switch ( cond ) {
            case 0:
                if (Z == 1) should_branch = 1;
                break;
            case 1:
                if (Z == 0) should_branch = 1;
                break;
            case 2:
                if (C == 1) should_branch = 1;
                break;
            case 3:
                if (C == 0) should_branch = 1;
                break;
            case 4:
                if (N == 1) should_branch = 1;
                break;
            case 5:
                if (N == 0) should_branch = 1;
                break;
            case 6:
                if (V == 1) should_branch = 1;
                break;
            case 7:
                if (V == 0) should_branch = 1;
                break;
            case 8:
                if (C == 1 && Z == 0) should_branch = 1;
                break;
            case 9:
                if (C == 0 || Z == 1) should_branch = 1;
                break;
            case 10:
                if (N == V) should_branch = 1;
                break;
            case 11:
                if (N != V) should_branch = 1;
                break;
            case 12:
                if (Z == 0 && N == V) should_branch = 1;
                break;
            case 13:
                if (Z == 1 || N != V) should_branch = 1;
                break;
        }

        if (should_branch == 1) {
            int8_t offset = GET_BITS(inst, 7, 8);

            PC += offset * 2 + 4;
        }
        else {
            PC += 2;
        }

        return 0;
    }

    // SWI immed
    else if (GET_BITS(inst, 15, 8) == 0b11011111) {
        // TODO
        PC += 2;
        return 0;
    }

    // B(NO COND) inst_address + 4 + signed_offset * 2
    else if (GET_BITS(inst, 15, 5) == 0b11100) {
        int16_t offset = GET_BITS(inst, 10, 11);

        // if negative address, fill left side with 1's
        if(GET_BITS(inst, 10, 1) == 1){
            offset <<= 5;
            offset >>= 5;
        }
        PC += offset * 2 + 4;
        return 0;
    }

    // TODO!
    // BLX ( inst+4 + (poff<<12) + unsigned_offset*4 ) &~ 3
    else if(GET_BITS(inst, 15, 5) == 0b11101) {
        int32_t offset = GET_BITS(inst, 10, 10);

        uint16_t prev_inst = rom[PC - 6] | rom[PC - 5] << 8; // !!!
        if(GET_BITS(prev_inst, 15, 5) != 0b11110){
            fprintf(stderr, "BLX: previous instruction is not a branch prefix instruction 0x%08X  0x%04X\n", PC - 4, prev_inst);
            return 1;
        }

        int32_t poff = GET_BITS(prev_inst, 10, 11);

        int32_t toff = (poff << 12) | (offset << 2); // total offset
        toff <<= 10;
        toff >>= 10;

        // toff:
        // 22..=12 poff
        // 11..=2 off
        
        LR = PC + 2; // return to next instr
        LR += 1; // plus one to be compatible with thumb code
        PC = (PC + toff + 4 - 2) & ~3; // -2 because offset relative to prefix
        return 0;
    }
    
    // "This is a branch prefix instruction. it must be followed by a relative bx, blx instruction."
    else if(GET_BITS(inst, 15, 5) == 0b11110) {
        
        // just ignore, and handle in bl,blx
        PC += 2;
        return 0;
    }

    // TODO !
    // BL inst+4 + (poff<<12) + unsigned_offset*2
    else if(GET_BITS(inst, 15, 5) == 0b11111) {
        int32_t offset = GET_BITS(inst, 10, 11);

        uint16_t prev_inst = rom[PC - 2] | rom[PC - 1] << 8; // !!!

        if(GET_BITS(prev_inst, 15, 5) != 0b11110){
            fprintf(stderr, "BL: previous instruction is not a branch prefix instruction 0x%08X  0x%04X\n", PC - 2, prev_inst);
            return 1;
        }

        int32_t poff = GET_BITS(prev_inst, 10, 11);
        int32_t toff = (poff << 12) | (offset << 1) ; // total offset
        toff <<= 10;
        toff >>= 10;

        // toff:
        // 22..=12 poff
        // 11..=1 off
        
        LR = PC + 2; // return to next instr
        LR += 1; // plus one to be compatible with thumb code
        PC += toff + 4 - 2; // -2 because offset relative to prefix
        return 0;
    }

    fprintf(stderr, "invalid instruction 0x%08X 0x%04X\n", PC, inst); // !!!
    return 1;
}

