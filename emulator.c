// Deniz Bashgoren  github.com/denizBasgoren
// Cem Belentepe    github.com/theCCB

#include <signal.h>
#include <stdio.h>
#include <time.h>

#include "emulib.h"

// start (in order of documentation), offset ( number of bits from start to direction of 0)
// GET_BITS( 010110, 3, 4 ) == 0110
#define GET_BITS(bits, start, offset) (((bits) >> ((start) - (offset) + 1)) & ((1 << (offset)) - 1))

// set a bit to 1 in given bits
#define SET_BIT(bits, n) ((bits) |= (1 << (n)))

// set a bit to 0 in given bits
#define RESET_BIT(bits,b) ((bits) &= ~(1ULL<<(b)))

// we will refer to values in registers by these shortcuts
#define SP  (cpu.reg[13])
#define LR  (cpu.reg[14])
#define PC  (cpu.reg[15])
#define FLG (cpu.cpsr) // flag register
#define FLG_N (31)
#define FLG_Z (30)
#define FLG_C (29)
#define FLG_V (28)

#define ROM_MAX 0x1FFFFFFF
#define ROM_MIN 0x00000000

#define RAM_MAX 0x3FFFFFFF
#define RAM_MIN 0x20000000

#define PER_MAX 0x5FFFFFFF
#define PER_MIN 0x40000000

// registers
typedef struct {
    int32_t reg[16];
    int32_t cpsr;
}tCPU;

// memory
uint8_t rom[0x200000];
uint8_t ram[0x100000];
tCPU cpu;

int32_t execute_next( int is_debug_mode );
void update_nz_flags(int32_t reg);
void update_vc_flags_in_addition(int32_t o1, int32_t o2, int32_t res);
void update_vc_flags_in_subtraction(int32_t o1, int32_t o2, int32_t res);
void debug_dialog();
void sigint_handler();
void store_to_memory(uint32_t value, uint32_t address);
void load_from_memory(uint32_t *destination, uint32_t address);

//Emulator main function
int32_t main(int32_t argc, char* argv[])
{
    if (argc < 2)
    {
        puts("Usage: emulator path/to/arm_assembly.s [, -debug ]");
        return(1);
    }

    // fill rom with 1s
    memset(rom, 0xFF, sizeof(rom));

    // init SDL
    system_init();

    // load bytes to rom
    if (load_program(argv[1], rom) < 0) return 1;

    // exit gracefully on ctrl+c
    signal(SIGINT, sigint_handler);

    // init ram with 1s
    memset(ram, 0xFF, sizeof(ram));

    // all flags 0.
    // T flag should actually be 1, but we simply ignore it here, since cortex m0 supports thumb only
    FLG = 0;

    LR = 0xFFFFFFFF;

    //First 4 bytes in ROM specifies initializes the stack pointer
    load_from_memory( &SP, ROM_MIN);

    //Following 4 bytes in ROM initializes the PC
    load_from_memory( &PC, ROM_MIN+4);

    // PC always points 4 bytes after current instruction.
    PC += 2;

    // on debug mode, execution breaks after every instruction
    int is_debug_mode = argc == 3 && !strcmp(argv[2], "-debug");

    clock_t t = clock();

    size_t n = 100000000;
    // main loop
    while (n > 0)
    {
        if (execute_next( is_debug_mode )) break;
        n--;
    }
    t = clock()-t;
    double time_elapsed = ((double)(t))/CLOCKS_PER_SEC;
    printf("Elapsed time: %f seconds\n", time_elapsed);
    // Free SDL
    system_deinit();

    return 0;
}


// If zero, set Z. if ms bit = 1, set N
void update_nz_flags(int32_t reg) {
    if(reg == 0) SET_BIT(FLG, FLG_Z);
    else RESET_BIT(FLG, FLG_Z);
    if (reg >= (1 << 31)) SET_BIT(FLG, FLG_N); // reg < 0 ?
    else RESET_BIT(FLG, FLG_N);
}

void update_vc_flags_in_addition(int32_t o1, int32_t o2, int32_t res) {
    if (o1>0 && o2>0 && res<0) SET_BIT(FLG, FLG_V);
    else if (o1<0 && o2<0 && res>0) SET_BIT(FLG, FLG_V);
    else RESET_BIT(FLG, FLG_V);

    if ( 0xFFFFFFFF - o1 < o2 ) SET_BIT(FLG, FLG_C);
    else RESET_BIT(FLG, FLG_C);
}

void update_vc_flags_in_subtraction(int32_t o1, int32_t o2, int32_t res) {
    if (o1<0 && o2>0 && res>0) SET_BIT(FLG, FLG_V);
    else if (o1>0 && o2<0 && res<0) SET_BIT(FLG, FLG_V);
    else RESET_BIT(FLG, FLG_V);

    if ( o1 - o2 < 0) SET_BIT(FLG, FLG_C);
    RESET_BIT(FLG, FLG_C);
}

void sigint_handler() {
    puts("Termination");
    exit(0);
}


void store_to_memory(uint32_t value, uint32_t address) {

    // Adress must be divisible by 4. so, truncate last two bits.
    RESET_BIT(address, 0);
    RESET_BIT(address, 1);

    if(address >= ROM_MIN && address <= ROM_MAX) {
        *(uint32_t*)(rom + address - ROM_MIN) = value;
    }
    else if(address >= RAM_MIN && address <= RAM_MAX) {
        *(uint32_t*)(rom + address - RAM_MIN) = value;
    }
    else if(address >= PER_MIN && address <= PER_MAX)
        peripheral_write(address, value);

}

void load_from_memory(uint32_t *destination, uint32_t address) {

    // Adress must be divisible by 4. so, truncate last two bits.
    RESET_BIT(address, 0);
    RESET_BIT(address, 1);
    
    int base;

    if(address >= ROM_MIN && address <= ROM_MAX) {
        base = address - ROM_MIN;
        *destination = *(uint32_t*)(&rom[base]);
    }
    else if(address >= RAM_MIN && address <= RAM_MAX) { 
        base = address - RAM_MIN;   
        *destination = *(uint32_t*)(&rom[base]);
    }
    else if(address >= PER_MIN && address <= PER_MAX)
        peripheral_read(address, destination);
}


//Fetches an instruction from ROM, decodes and executes it
int32_t execute_next( int is_debug_mode )
{
    uint16_t inst = rom[PC - 2] | rom[PC - 1] << 8;
    PC += 2;
    // at this point, PC = current inst + 4

    if (is_debug_mode) {
        printf("\n\nInstruction 0x%08X 0x%04X\n", PC - 4, inst);
        debug_dialog();
    }
    
    // this bit sequence is invalid according to thumb isa, so we use it as impl-defined debug statement
    // to include debug statement, put ".hword 0xde00" in your asm code
    if (inst == 0xde00) {
        debug_dialog();
        return 0;
    }


    // LSL Rd, Rm, immed
    else if (GET_BITS(inst, 15, 5) == 0b00000) {
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

        return 0;
    }

    // LSR Rd, Rm, immed
    else if (GET_BITS(inst, 15, 5) == 0b00000) {
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

        return 0;
    }

    // ADD Rd, Rn, Rm
    else if (GET_BITS(inst, 15, 7) == 0b0001100) {
        uint8_t rm = GET_BITS(inst, 8, 3);
        uint8_t rn = GET_BITS(inst, 5, 3);
        uint8_t rd = GET_BITS(inst, 2, 3);

        uint32_t ra = cpu.reg[rn];
        uint32_t rb = cpu.reg[rm];
        uint32_t rc = ra + rb;
        cpu.reg[rd] = rc;

        update_nz_flags(rc);
        update_vc_flags_in_addition(ra,rb,rc);

        return 0;
    }

    // SUB Rd, Rn, Rm
    else if (GET_BITS(inst, 15, 7) == 0b0001101) {
        uint8_t rm = GET_BITS(inst, 8, 3);
        uint8_t rn = GET_BITS(inst, 5, 3);
        uint8_t rd = GET_BITS(inst, 2, 3);

        uint32_t ra = cpu.reg[rn];
        uint32_t rb = cpu.reg[rm];
        uint32_t rc = ra - rb;
        cpu.reg[rd] = rc;

        update_nz_flags(rc);
        update_vc_flags_in_subtraction(ra,rb,rc);

        return 0;
    }

    // ADD Rd, Rn, immed
    else if (GET_BITS(inst, 15, 7) == 0b0001110) {
        uint8_t immed = GET_BITS(inst, 8, 3);
        uint8_t rn = GET_BITS(inst, 5, 3);
        uint8_t rd = GET_BITS(inst, 2, 3);

        uint32_t ra = cpu.reg[rn];
        uint32_t rc = ra + immed;
        cpu.reg[rd] = rc;

        update_nz_flags(rc);
        update_vc_flags_in_addition(ra,immed, rc);

        return 0;
    }

    // SUB Rd, Rn, immed
    else if (GET_BITS(inst, 15, 7) == 0b0001111) {
        uint8_t immed = GET_BITS(inst, 8, 3);
        uint8_t rn = GET_BITS(inst, 5, 3);
        uint8_t rd = GET_BITS(inst, 2, 3);

        uint32_t ra = cpu.reg[rn];
        uint32_t rc = ra - immed;
        cpu.reg[rd] = rc;

        update_nz_flags(rc);
        update_vc_flags_in_subtraction(ra,immed,rc);

        return 0;
    }

    // MOV Rd, immed
    else if (GET_BITS(inst, 15, 5) == 0b00100) {
        uint8_t rd = GET_BITS(inst, 10, 3);
        uint8_t immed = GET_BITS(inst, 7, 8);

        cpu.reg[rd] = immed;

        update_nz_flags( cpu.reg[rd] );
        return 0;
    }

    // CMP Rm, immed
    else if (GET_BITS(inst, 15, 5) == 0b00101) {
        uint8_t rn = GET_BITS(inst, 10, 3);
        uint8_t immed = GET_BITS(inst, 7, 8);

        uint32_t ra = cpu.reg[rn];
        uint32_t dif = ra - immed;

        update_nz_flags(dif);
        update_vc_flags_in_subtraction(ra,immed,dif);

        return 0;
    }

    // ADD Rd, immed
    else if (GET_BITS(inst, 15, 5) == 0b00110) {
        uint8_t rd = GET_BITS(inst, 10, 3);
        uint8_t immed = GET_BITS(inst, 7, 8);

        uint32_t ra = cpu.reg[rd];
        uint32_t rc = ra + immed;

        cpu.reg[rd] = rc;
        update_nz_flags(rc);
        update_vc_flags_in_addition(ra,immed,rc);

        return 0;
    }

    // SUB Rd, immed
    else if (GET_BITS(inst, 15, 5) == 0b00111) {
        uint8_t rd = GET_BITS(inst, 10, 3);
        uint8_t immed = GET_BITS(inst, 7, 8);

        uint32_t ra = cpu.reg[rd];
        uint32_t rc = ra - immed;

        cpu.reg[rd] = rc;
        update_nz_flags(rc);
        update_vc_flags_in_subtraction(ra,immed,rc); 

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
        uint32_t rc = ra + rb + carry;

        cpu.reg[rd] = rc;
        
        update_nz_flags(rc);
        update_vc_flags_in_addition(ra, rb+carry, rc);

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
        uint32_t rc = ra - rb - carry;

        cpu.reg[rd] = rc;
        
        update_nz_flags(rc);
        update_vc_flags_in_subtraction(ra, rb+carry, rc);

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
        return 0;
    }

    // CMP Rd, Rm
    else if (GET_BITS(inst, 15, 10) == 0b0100001010)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint32_t ra = cpu.reg[rd];
        uint32_t rb = cpu.reg[rm];
        uint32_t rc = ra - rb;
        
        update_nz_flags(rc);
        update_vc_flags_in_subtraction(ra,rb,rc);
 
        return 0;
    }

    // CMN Rd, Rm
    else if (GET_BITS(inst, 15, 10) == 0b0100001011)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint32_t ra = cpu.reg[rd];
        uint32_t rb = cpu.reg[rm];
        uint32_t rc = ra + rb;
        
        update_nz_flags(rc);
        update_vc_flags_in_addition(ra,rb,rc);
 
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
        
        uint32_t dif = ra - rb;

        update_nz_flags(dif);
        update_vc_flags_in_subtraction(ra,rb,dif);

        return 0;
    }

    // CMP Hn, Lm
    else if (GET_BITS(inst, 15, 10) == 0b0100010110)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint32_t ra = cpu.reg[rd+8];
        uint32_t rb = cpu.reg[rm];
        
        uint32_t dif = ra - rb;

        update_nz_flags(dif);
        update_vc_flags_in_subtraction(ra,rb,dif);

        return 0;
    }

    // CMP Hn, Hm
    else if (GET_BITS(inst, 15, 10) == 0b0100010111)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint32_t ra = cpu.reg[rd+8];
        uint32_t rb = cpu.reg[rm+8];
        
        uint32_t dif = ra - rb;

        update_nz_flags(dif);
        update_vc_flags_in_subtraction(ra,rb,dif);

        return 0;
    }
    
    // BX Rm
    else if(GET_BITS(inst, 15, 9) == 0b010001110){
        uint8_t rm = GET_BITS(inst, 6, 4);
        PC = cpu.reg[rm];

        return 0;
    }

    // BLX Rm
    else if(GET_BITS(inst, 15, 9) == 0b010001111){
        uint8_t rm = GET_BITS(inst, 6, 4);

        // here, temp is needed, because if cpu.reg[rm] == lr, we lose the value in lr
        uint32_t temp = PC;
        PC = cpu.reg[rm];
        LR = temp;

        return 0;
    }

    // LDR Ld, [ pc, immed * 4 ]
    else if (GET_BITS(inst, 15, 5) == 0b01001)
    {
        uint8_t rd = GET_BITS(inst, 10, 3);
        uint8_t immed = GET_BITS(inst, 7, 8);
        
        load_from_memory( &cpu.reg[rd], PC + immed * 4);
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

        store_to_memory( cpu.reg[rd], addr);

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

        load_from_memory( &cpu.reg[rd], addr);

        return 0;
    }

    // STR Ld, [Ln, immed * 4]
    // page 65
    else if (GET_BITS(inst, 15, 5) == 0b01100)
    {
        uint8_t immed = GET_BITS(inst, 10, 5);
        uint8_t rn = GET_BITS(inst, 5, 3);
        uint8_t rd = GET_BITS(inst, 2, 3);

        uint32_t addr = cpu.reg[rn] + 4 * immed;

        store_to_memory( cpu.reg[rd], addr);

        return 0;
    }

    // LDR Ld, [Ln, immed*4 ]
    // page 65
    else if (GET_BITS(inst, 15, 5) == 0b01101)
    {
        uint8_t immed = GET_BITS(inst, 10, 5);
        uint8_t rn = GET_BITS(inst, 5, 3);
        uint8_t rd = GET_BITS(inst, 2, 3);

        uint32_t addr = cpu.reg[rn] + 4 * immed;

        load_from_memory( &cpu.reg[rd], addr);

        return 0;
    }

    // STR Ld, [sp, immed*4]
    else if (GET_BITS(inst, 15, 5) == 0b10010)
    {
        uint8_t rd = GET_BITS(inst, 10, 3);
        uint8_t immed = GET_BITS(inst, 7, 8);

        uint32_t addr = SP + immed * 4;

        store_to_memory( cpu.reg[rd], addr);


        return 0;
    }

    // LDR Ld, [sp, immed*4]
    else if (GET_BITS(inst, 15, 5) == 0b10011)
    {
        uint8_t rd = GET_BITS(inst, 10, 3);
        uint8_t immed = GET_BITS(inst, 7, 8);

        uint32_t addr = SP + immed * 4;

        load_from_memory( &cpu.reg[rd], addr);

        return 0;
    }

    // ADD Ld, pc, immed*4
    // ld = pc + immed*4 (page 75)
    else if (GET_BITS(inst, 15, 5) == 0b10100)
    {
        uint8_t rd = GET_BITS(inst, 10, 3);
        uint8_t immed = GET_BITS(inst, 7, 8);
        uint32_t immed_times_4 = immed * 4;

        cpu.reg[rd] = PC + immed_times_4;

        // Adress must be divisible by 4. so, truncate last two bits.
        RESET_BIT(cpu.reg[rd], 0);
        RESET_BIT(cpu.reg[rd], 1);

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
        RESET_BIT(cpu.reg[rd], 0);
        RESET_BIT(cpu.reg[rd], 1);

        return 0;
    }

    // ADD sp, immed*4
    // sp += immed * 4
    else if (GET_BITS(inst, 15, 9) == 0b101100000)
    {
        uint8_t immed = GET_BITS(inst, 6, 7);
        uint32_t immed_times_4 = immed * 4;
        SP = SP + immed_times_4;

        return 0;
    }

    // SUB sp, immed*4
    else if (GET_BITS(inst, 15, 9) == 0b101100001)
    {
        uint8_t immed = GET_BITS(inst, 6, 7);
        uint32_t immed_times_4 = immed * 4;
        SP = SP - immed_times_4;

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
            store_to_memory(LR, addr);
        }

        for(int i = 7; i >= 0; i--){
            if((list & (1 << i)) != 0){
                addr -= 4;
                store_to_memory( cpu.reg[i], addr);
            }
        }

        SP = addr;
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
                load_from_memory( &cpu.reg[i], addr);
                addr += 4;
            }
        }
        if(r == 1){
            load_from_memory( &PC, addr);
            addr += 4;
        }

        SP = addr;
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

            // if negative address, fill left side with 1's
            if(GET_BITS(inst, 7, 1) == 1){
                offset <<= 8;
                offset >>= 8;
            }
            PC += offset * 2 + 2;
        }
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
        PC += offset * 2 + 2; // +2 more will be added on the next cycle
        return 0;
    }

    // BLX ( inst+4 + (poff<<12) + unsigned_offset*4 ) &~ 3
    else if(GET_BITS(inst, 15, 5) == 0b11101) {
        int32_t offset = GET_BITS(inst, 10, 10);

        uint16_t prev_inst = rom[PC - 6] | rom[PC - 5] << 8;
        if(GET_BITS(prev_inst, 15, 5) != 0b11110){
            fprintf(stderr, "BLX: previous instruction is not a branch prefix instruction 0x%08X  0x%04X\n", PC - 4, prev_inst);
            return 1;
        }

        int32_t poff = GET_BITS(prev_inst, 10, 11);

        // if negative address, fill left side with 1's
        if(GET_BITS(poff, 10, 1) == 1){
            poff <<= 21;
            poff >>= 21;
        }
        
        LR = PC;
        PC = (PC + (poff<<12) + offset*4) & ~3; // NOTE: -2, because offset is rel to prefix instruction, not this one
        return 0;
    }
    
    // "This is a branch prefix instruction. it must be followed by a relative bx, blx instruction."
    else if(GET_BITS(inst, 15, 5) == 0b11110) {
        
        // just ignore, and handle in bl,blx
        return 0;
    }

    // BL inst+4 + (poff<<12) + unsigned_offset*2
    else if(GET_BITS(inst, 15, 5) == 0b11111) {
        int32_t offset = GET_BITS(inst, 10, 11);

        uint16_t prev_inst = rom[PC - 6] | rom[PC - 5] << 8;

        if(GET_BITS(prev_inst, 15, 5) != 0b11110){
            fprintf(stderr, "BLX: previous instruction is not a branch prefix instruction 0x%08X  0x%04X\n", PC - 4, prev_inst);
            return 1;
        }

        int32_t poff = GET_BITS(prev_inst, 10, 11);

        // if negative address, fill left side with 1's
        if(GET_BITS(poff, 10, 1) == 1){
            poff <<= 21;
            poff >>= 21;
        }

        LR = PC;
        PC += (poff<<12) + offset*2; // NOTE: -2, because offset is rel to prefix instruction, not this one
        return 0;
    }

    fprintf(stderr, "invalid instruction 0x%08X 0x%04X\n", PC - 4, inst);
    return 1;
}


void debug_dialog () {
    printf("%c[2J%c[1;1H", 27, 27);
        printf("Debug instruction!\n");
        for (int i = 0; i<16; i++) {
            printf("R%d %s \t hex %x \n", i,
            i == 13 ? "(SP)" :
            i == 14 ? "(LR)" :
            i == 15 ? "(PC)" : "",
            cpu.reg[i]
            );
        }

        uint32_t from, to;
        while(1) {
            puts("\n\nPrint memory from xxxxxxxx to xxxxxxxx (hex)");
            puts("To go to the next instruction, type 0-0");
            puts("eg. \"12fa0257-13000000\" ");

            scanf("%x-%x", &from, &to );
            printf("Memory %x - %x (inclusive): (%d bytes)\n", from, to, to-from+1);

            if (from == 0 && to == 0 ) break;
            if (from < ROM_MAX) {
                for (; from <= to; from++) {
                    printf("%x ", rom[from] );
                }
            }
            else if (from < RAM_MAX) {
                for(; from <= to; from++) {
                    printf("%x ", ram[from - RAM_MIN]);
                }
            }
            else {
                printf("instruction unclear");
            }

            printf("\n");
        }
}