#include "emulib.h"

// start (in order of documentation), offset ( number of bits from start to direction of 0)
#define GET_BITS(bits, start, offset) (((bits) >> ((start) - (offset) + 1)) & ((1 << (offset)) - 1))
#define SET_BIT(bits, n) ((bits) |= (1 << (n)))
#define RESET_BIT(a,b) ((a) &= ~(1ULL<<(b)))

#define R0  (cpu.reg[ 0])
#define R1  (cpu.reg[ 1])
#define R2  (cpu.reg[ 2])
#define R3  (cpu.reg[ 3])
#define R4  (cpu.reg[ 4])
#define R5  (cpu.reg[ 5])
#define R6  (cpu.reg[ 6])
#define R7  (cpu.reg[ 7])
#define R8  (cpu.reg[ 8])
#define R9  (cpu.reg[ 9])
#define R10 (cpu.reg[10])
#define R11 (cpu.reg[11])
#define R12 (cpu.reg[12])
#define SP  (cpu.reg[13])
#define LR  (cpu.reg[14])
#define PC  (cpu.reg[15])
#define FLG (cpu.cpsr)      // This register is called the Program Status Register
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



typedef struct {
    int32_t reg[16];
    int32_t cpsr;
}tCPU;

uint8_t rom[0x200000];
uint8_t ram[0x100000];
tCPU cpu;


int32_t execute_next(void);
void update_nz_flags(int32_t reg);
void debug_dialog();

//Emulator main function
int32_t main(int32_t argc, char* argv[])
{
    if (argc < 2)
    {
        fprintf(stderr, "input assembly file not specified\n");
        return(1);
    }

    memset(rom, 0xFF, sizeof(rom));

    system_init();

    if (load_program(argv[1], rom) < 0)
    {
        return(1);
    }

    for(int i = 0; i < 128; i+=2)
    {
        uint16_t inst = rom[i] | rom[i + 1] << 8;
        printf("instruction 0x%08X 0x%04X\n", i, inst);
    }

    memset(ram, 0xFF, sizeof(ram));

    cpu.cpsr = 0;

    cpu.reg[14] = 0xFFFFFFFF;
    //First 4 bytes in ROM specifies initializes the stack pointer
    cpu.reg[13] = rom[0] | rom[1] << 8 | rom[2] << 16 | rom[3] << 24;
    //Following 4 bytes in ROM initializes the PC
    cpu.reg[15] = rom[4] | rom[5] << 8 | rom[6] << 16 | rom[7] << 24;
    cpu.reg[15] += 2;

    while (1)
    {
        if (execute_next()) break;
    }

    system_deinit();

    return(0);
}


void update_nz_flags(int32_t reg) {
        if(reg == 0) SET_BIT(FLG, FLG_Z);
        else RESET_BIT(FLG, FLG_Z);
        if (reg >= (1 << 31)) SET_BIT(FLG, FLG_N);
        else RESET_BIT(FLG, FLG_N);
}

//Fetches an instruction from ROM, decodes and executes it
int32_t execute_next(void)
{
    uint16_t inst = rom[PC - 2] | rom[PC - 1] << 8;
    PC += 2;
    
    printf("instruction 0x%08X 0x%04X\n", PC - 4, inst);

    // DEBUG INSTRUCTION == 1101 1110 0000 0000
    if (inst == 0xde00) {
        debug_dialog();
        return 0;
    }

    // TODO: operands should be uint32_t or int32_t?

    // todo: check operator precedence: cast, >> 
    // LSL
    else if (GET_BITS(inst, 15, 5) == 0b00000) {
        uint8_t immed = GET_BITS(inst, 10, 5);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint8_t rd = GET_BITS(inst, 2, 3);

        uint32_t rc = (uint32_t) cpu.reg[rm] << immed;
        cpu.reg[rd] = rc;

        update_nz_flags(rc);
        // todo: impl carry, conditions..
        return 0;
    }

    // LSR
    else if (GET_BITS(inst, 15, 5) == 0b00000) {
        uint8_t immed = GET_BITS(inst, 10, 5);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint8_t rd = GET_BITS(inst, 2, 3);

        uint32_t rc = (uint32_t) cpu.reg[rm] >> immed;
        cpu.reg[rd] = rc;

        update_nz_flags(rc);
        // todo: impl carry, conditions..
        return 0;
    }

    // ASR
    else if (GET_BITS(inst, 15, 5) == 0b00010) {
        uint8_t immed = GET_BITS(inst, 10, 5);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint8_t rd = GET_BITS(inst, 2, 3);

        int32_t rc = cpu.reg[rm] >> immed;
        cpu.reg[rd] = rc;

        update_nz_flags(rc);
        // todo: impl carry, conditions..
        return 0;
    }

    // ADD
    else if (GET_BITS(inst, 15, 7) == 0b0001100) {
        uint8_t rm = GET_BITS(inst, 8, 3);
        uint8_t rn = GET_BITS(inst, 5, 3);
        uint8_t rd = GET_BITS(inst, 2, 3);

        uint32_t ra = cpu.reg[rm];
        uint32_t rb = cpu.reg[rn];
        uint32_t rc = ra + rb;
        cpu.reg[rd] = rc;

        update_nz_flags(rc);
        // todo: impl carry, overflo, conditions..
        return 0;
    }

    // SUB
    else if (GET_BITS(inst, 15, 7) == 0b0001101) {
        uint8_t rm = GET_BITS(inst, 8, 3);
        uint8_t rn = GET_BITS(inst, 5, 3);
        uint8_t rd = GET_BITS(inst, 2, 3);

        uint32_t ra = cpu.reg[rm];
        uint32_t rb = cpu.reg[rn];
        uint32_t rc = ra - rb;
        cpu.reg[rd] = rc;

        update_nz_flags(rc);
        // todo: impl carry, overflo, conditions..
        return 0;
    }

    // ADD
    else if (GET_BITS(inst, 15, 7) == 0b0001110) {
        uint8_t immed = GET_BITS(inst, 8, 3);
        uint8_t rn = GET_BITS(inst, 5, 3);
        uint8_t rd = GET_BITS(inst, 2, 3);

        uint32_t ra = cpu.reg[rn];
        uint32_t rc = ra + immed;
        cpu.reg[rd] = rc;

        update_nz_flags(rc);
        // todo: impl carry, overflo, conditions..
        return 0;
    }

    // SUB
    else if (GET_BITS(inst, 15, 7) == 0b0001111) {
        uint8_t immed = GET_BITS(inst, 8, 3);
        uint8_t rn = GET_BITS(inst, 5, 3);
        uint8_t rd = GET_BITS(inst, 2, 3);

        uint32_t ra = cpu.reg[rn];
        uint32_t rc = ra - immed;
        cpu.reg[rd] = rc;

        update_nz_flags(rc);
        // todo: impl carry, overflo, conditions..
        return 0;
    }

    // MOV
    else if (GET_BITS(inst, 15, 5) == 0b00100) {
        uint8_t rd = GET_BITS(inst, 10, 3);
        uint8_t immed = GET_BITS(inst, 7, 8);

        cpu.reg[rd] = immed;

        // nz flags?
        // todo: impl carry, overflo, conditions..
        return 0;
    }

    // CMP
    else if (GET_BITS(inst, 15, 5) == 0b00101) {
        uint8_t rn = GET_BITS(inst, 10, 3);
        uint8_t immed = GET_BITS(inst, 7, 8);

        uint32_t dif = cpu.reg[rn] - immed;

        update_nz_flags(dif);
        // todo: impl carry, overflo, conditions..
        return 0;
    }

    // ADD
    else if (GET_BITS(inst, 15, 5) == 0b00110) {
        uint8_t rd = GET_BITS(inst, 10, 3);
        uint8_t immed = GET_BITS(inst, 7, 8);

        uint32_t ra = cpu.reg[rd];
        ra += immed;

        cpu.reg[rd] = ra;
        update_nz_flags(ra);
        // todo: impl carry, overflo, conditions..
        return 0;
    }

    // SUB
    else if (GET_BITS(inst, 15, 5) == 0b00111) {
        uint8_t rd = GET_BITS(inst, 10, 3);
        uint8_t immed = GET_BITS(inst, 7, 8);

        uint32_t ra = cpu.reg[rd];
        ra -= immed;

        cpu.reg[rd] = ra;
        update_nz_flags(ra);
        // todo: impl carry, overflo, conditions..
        return 0;
    }

    // ANDS
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
    // EORS
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
    // LSLS
    else if (GET_BITS(inst, 15, 10) == 0b0100000010)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint32_t ra = cpu.reg[rd];
        uint32_t rb = cpu.reg[rm];
        uint32_t rc = ra << rb;
        cpu.reg[rd] = rc;
        
        update_nz_flags(rc);
        return 0;
    }
    // LSRS
    else if (GET_BITS(inst, 15, 10) == 0b0100000011)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint32_t ra = cpu.reg[rd];
        uint32_t rb = cpu.reg[rm];
        uint32_t rc = ra >> rb;
        cpu.reg[rd] = rc;
        
        update_nz_flags(rc);
        return 0;
    }
    // ASRS
    else if (GET_BITS(inst, 15, 10) == 0b0100000100)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        int32_t ra = cpu.reg[rd];
        int32_t rb = cpu.reg[rm];
        int32_t rc = ra >> rb;
        cpu.reg[rd] = rc;
        
        update_nz_flags(rc);
        return 0;
    }
    // ADCS
    else if (GET_BITS(inst, 15, 10) == 0b0100000101)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        int32_t ra = cpu.reg[rd];
        int32_t rb = cpu.reg[rm];
        int32_t rc = ra + rb;
        cpu.reg[rd] = rc + GET_BITS(FLG, FLG_C, 1);
        
        update_nz_flags(rc);
        // TODO: Add the carry flag code

        if(ra > 0 && rb > 0 && rc < 0) SET_BIT(FLG, FLG_V);
        else if(ra < 0 && rb < 0 && rc > 0) SET_BIT(FLG, FLG_V);
        else RESET_BIT(FLG, FLG_V);

        return 0;
    }
    // SBCS
    else if (GET_BITS(inst, 15, 10) == 0b0100000110)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        int32_t ra = cpu.reg[rd];
        int32_t rb = cpu.reg[rm];
        int32_t rc = rb - ra;
        cpu.reg[rd] = rc - GET_BITS(FLG, FLG_C, 1);
        
        update_nz_flags(rc);
        // TODO: Add the overflow and carry flag code

        return 0;
    }
    // RORS
    else if (GET_BITS(inst, 15, 10) == 0b0100000111)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint32_t ra = cpu.reg[rd];
        uint32_t rb = cpu.reg[rm] % 32;
        uint32_t rc = (ra >> rb) | (ra << (32 - rb));
        cpu.reg[rd] = rc;
        
        update_nz_flags(rc);
        // TODO: Add the carry flag code

        return 0;
    }
    // TSTS
    else if (GET_BITS(inst, 15, 10) == 0b0100001000)
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

    // todo: NEG is same as MVN??
    // NEG
    else if (GET_BITS(inst, 15, 10) == 0b0100001001)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint32_t ra = cpu.reg[rm];
        uint32_t rc = ~ra;
        cpu.reg[rd] = rc;
        
        update_nz_flags(rc);
        return 0;
    }
    // CMP
    else if (GET_BITS(inst, 15, 10) == 0b0100001010)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        int32_t ra = cpu.reg[rd];
        int32_t rb = cpu.reg[rm];
        int32_t rc = ra - rb;
        
        update_nz_flags(rc);
        // TODO: Add the overflow and carry flag code
        
        return 0;
    }
    // CMN
    else if (GET_BITS(inst, 15, 10) == 0b0100001011)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        int32_t ra = cpu.reg[rd];
        int32_t rb = cpu.reg[rm];
        int32_t rc = ra + rb;
        
        update_nz_flags(rc);
        // TODO: Add the overflow and carry flag code
        
        return 0;
    }
    // ORRS
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
    // MUL
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
    // BICS
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

    // MVNS
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

    // CPY // ???????
    else if (GET_BITS(inst, 15, 10) == 0b0100011000)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint32_t ra = cpu.reg[rm];
        cpu.reg[rd] = ra;
        
        update_nz_flags(ra);
        // TODO; CARRY, V FLAGS
        return 0;
    }

    // ADD
    else if (GET_BITS(inst, 15, 10) == 0b0100010001)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint32_t ra = cpu.reg[rd];
        uint32_t rb = cpu.reg[rm+8];
        
        ra += rb;
        cpu.reg[rd] = ra;
        
        update_nz_flags(ra);
        // TODO; CARRY, V FLAGS

        return 0;
    }

    // MOV
    else if (GET_BITS(inst, 15, 10) == 0b0100011001)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint32_t ra = cpu.reg[rd];
        uint32_t rb = cpu.reg[rm+8];
        
        ra = rb;
        cpu.reg[rd] = ra;
        
        update_nz_flags(ra);
        // TODO; CARRY, V FLAGS

        return 0;
    }

    // ADD
    else if (GET_BITS(inst, 15, 10) == 0b0100010010)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint32_t ra = cpu.reg[rd+8];
        uint32_t rb = cpu.reg[rm];
        
        ra += rb;
        cpu.reg[rd+8] = ra;
        
        update_nz_flags(ra);
        // TODO; CARRY, V FLAGS

        return 0;
    }

    // MOV
    else if (GET_BITS(inst, 15, 10) == 0b0100011010)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint32_t ra = cpu.reg[rd+8];
        uint32_t rb = cpu.reg[rm];
        
        ra = rb;
        cpu.reg[rd+8] = ra;
        
        update_nz_flags(ra);
        // TODO; CARRY, V FLAGS

        return 0;
    }

    // ADD
    else if (GET_BITS(inst, 15, 10) == 0b0100010011)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint32_t ra = cpu.reg[rd+8];
        uint32_t rb = cpu.reg[rm+8];
        
        ra += rb;
        cpu.reg[rd+8] = ra;
        
        update_nz_flags(ra);
        // TODO; CARRY, V FLAGS

        return 0;
    }

    // MOV
    else if (GET_BITS(inst, 15, 10) == 0b0100011011)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint32_t ra = cpu.reg[rd+8];
        uint32_t rb = cpu.reg[rm+8];
        
        ra = rb;
        cpu.reg[rd+8] = ra;
        
        update_nz_flags(ra);
        // TODO; CARRY, V FLAGS

        return 0;
    }

    // CMP
    else if (GET_BITS(inst, 15, 10) == 0b0100010101)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint32_t ra = cpu.reg[rd];
        uint32_t rb = cpu.reg[rm+8];
        
        uint32_t dif = ra - rb;

        update_nz_flags(dif);
        // TODO; CARRY, V FLAGS

        return 0;
    }

    // CMP
    else if (GET_BITS(inst, 15, 10) == 0b0100010110)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint32_t ra = cpu.reg[rd+8];
        uint32_t rb = cpu.reg[rm];
        
        uint32_t dif = ra - rb;

        update_nz_flags(dif);
        // TODO; CARRY, V FLAGS

        return 0;
    }

    // CMP
    else if (GET_BITS(inst, 15, 10) == 0b0100010111)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint32_t ra = cpu.reg[rd+8];
        uint32_t rb = cpu.reg[rm+8];
        
        uint32_t dif = ra - rb;

        update_nz_flags(dif);
        // TODO; CARRY, V FLAGS

        return 0;
    }
    
    // BX
    else if(GET_BITS(inst, 15, 9) == 0b010001110){
        uint8_t rm = GET_BITS(inst, 6, 4);
        PC = cpu.reg[rm];

        return 0;
    }

    // BLX
    else if(GET_BITS(inst, 15, 9) == 0b010001111){
        uint8_t rm = GET_BITS(inst, 6, 4);
        LR = PC;
        PC += cpu.reg[rm];

        return 0;
    }

    // LDR
    else if (GET_BITS(inst, 15, 5) == 0b01001)
    {
        uint8_t rd = GET_BITS(inst, 10, 3);
        uint8_t immed = GET_BITS(inst, 7, 8);
        
        cpu.reg[rd] = *(uint32_t*)(rom + PC + 4 * immed);
        printf("%x, %d -> %X, %x\n", PC,  rd, cpu.reg[rd], immed);
        return 0;
    }

    // STR
    else if (GET_BITS(inst, 15, 7) == 0b0101000)
    {
        uint8_t rm = GET_BITS(inst, 8, 3);
        uint8_t rn = GET_BITS(inst, 5, 3);
        uint8_t rd = GET_BITS(inst, 2, 3);

        uint32_t addr = cpu.reg[rm] + cpu.reg[rn];

        if(addr >= ROM_MIN && addr <= ROM_MAX)
            rom[addr - ROM_MIN] = cpu.reg[rd];
        else if(addr >= RAM_MIN && addr <= RAM_MAX)
            ram[addr - RAM_MIN] = cpu.reg[rd];
        else if(addr >= PER_MIN && addr <= PER_MAX)
            return peripheral_write(addr, cpu.reg[rd]);

        return 0;
    }

    // LDR
    else if (GET_BITS(inst, 15, 7) == 0b0101100)
    {
        uint8_t rm = GET_BITS(inst, 8, 3);
        uint8_t rn = GET_BITS(inst, 5, 3);
        uint8_t rd = GET_BITS(inst, 2, 3);

        uint32_t addr = cpu.reg[rm] + cpu.reg[rn];

        if(addr >= ROM_MIN && addr <= ROM_MAX)
            cpu.reg[rd] = rom[addr - ROM_MIN];
        else if(addr >= RAM_MIN && addr <= RAM_MAX)
            cpu.reg[rd] = ram[addr - RAM_MIN];
        else if(addr >= PER_MIN && addr <= PER_MAX)
            return peripheral_read(addr, &cpu.reg[rd]);

        return 0;
    }

    // STR
    else if (GET_BITS(inst, 15, 5) == 0b01100)
    {
        uint8_t immed = GET_BITS(inst, 10, 5);
        uint8_t rn = GET_BITS(inst, 5, 3);
        uint8_t rd = GET_BITS(inst, 2, 3);

        uint32_t addr = cpu.reg[rn] + 4 * immed;

        if(addr >= ROM_MIN && addr <= ROM_MAX)
            rom[addr - ROM_MIN] = cpu.reg[rd];
        else if(addr >= RAM_MIN && addr <= RAM_MAX)
            ram[addr - RAM_MIN] = cpu.reg[rd];
        else if(addr >= PER_MIN && addr <= PER_MAX){
            printf("%X, %X\n", addr, cpu.reg[rd]);
            return peripheral_write(addr, cpu.reg[rd]);
        }

        return 0;
    }

    // LDR
    else if (GET_BITS(inst, 15, 5) == 0b01101)
    {
        uint8_t immed = GET_BITS(inst, 10, 5);
        uint8_t rn = GET_BITS(inst, 5, 3);
        uint8_t rd = GET_BITS(inst, 2, 3);

        uint32_t addr = cpu.reg[rn] + 4 * immed + 2;

        if(addr >= ROM_MIN && addr <= ROM_MAX)
            cpu.reg[rd] = rom[addr - ROM_MIN];
        else if(addr >= RAM_MIN && addr <= RAM_MAX)
            cpu.reg[rd] = ram[addr - RAM_MIN];
        else if(addr >= PER_MIN && addr <= PER_MAX)
            return peripheral_read(addr, &cpu.reg[rd]);

        return 0;
    }

    // STR
    else if (GET_BITS(inst, 15, 5) == 0b10010)
    {
        uint8_t rd = GET_BITS(inst, 10, 3);
        uint8_t immed = GET_BITS(inst, 7, 8);

        uint32_t addr = SP + 4 * immed;

        if(addr >= ROM_MIN && addr <= ROM_MAX)
            rom[addr - ROM_MIN] = cpu.reg[rd];
        else if(addr >= RAM_MIN && addr <= RAM_MAX)
            ram[addr - RAM_MIN] = cpu.reg[rd];
        else if(addr >= PER_MIN && addr <= PER_MAX)
            return peripheral_write(addr, cpu.reg[rd]);

        return 0;
    }

    // LDR
    else if (GET_BITS(inst, 15, 5) == 0b10011)
    {
        uint8_t rd = GET_BITS(inst, 10, 3);
        uint8_t immed = GET_BITS(inst, 7, 8);

        uint32_t addr = SP + 4 * immed;

        if(addr >= ROM_MIN && addr <= ROM_MAX)
            cpu.reg[rd] = rom[addr - ROM_MIN];
        else if(addr >= RAM_MIN && addr <= RAM_MAX)
            cpu.reg[rd] = ram[addr - RAM_MIN];
        else if(addr >= PER_MIN && addr <= PER_MAX)
            return peripheral_read(addr, &cpu.reg[rd]);

        return 0;
    }

    // ADD
    else if (GET_BITS(inst, 15, 5) == 0b10100)
    {
        uint8_t rd = GET_BITS(inst, 10, 3);
        uint8_t immed = GET_BITS(inst, 7, 8);

        cpu.reg[rd] = PC + immed * 4;

        update_nz_flags(cpu.reg[rd]);

        return 0;
    }

    // ADD
    else if (GET_BITS(inst, 15, 5) == 0b10101)
    {
        uint8_t rd = GET_BITS(inst, 10, 3);
        uint8_t immed = GET_BITS(inst, 7, 8);

        cpu.reg[rd] = SP + immed * 4;

        update_nz_flags(cpu.reg[rd]);

        return 0;
    }

    // ADD
    else if (GET_BITS(inst, 15, 9) == 0b101100000)
    {
        uint8_t immed = GET_BITS(inst, 6, 7);

        SP = SP + immed * 4;

        update_nz_flags(SP);

        return 0;
    }

    // SUB
    else if (GET_BITS(inst, 15, 9) == 0b101100001)
    {
        uint8_t immed = GET_BITS(inst, 6, 7);

        SP = SP - immed * 4;

        update_nz_flags(SP);

        return 0;
    }

    // PUSH
    else if (GET_BITS(inst, 15, 7) == 0b1011010)
    {
        uint8_t r = GET_BITS(inst, 8, 1);
        uint8_t list = GET_BITS(inst, 7, 8);
        uint32_t addr = SP;

        if(r == 1){
            addr -= 4;
            ram[addr] = LR;
        }
        for(int i = 7; i >= 0; i--){
            if((list & (1 << i)) != 0){
                addr -= 4;
                ram[addr] = cpu.reg[i];
            }
        }

        SP = addr;
    }

    // POP
    else if (GET_BITS(inst, 15, 7) == 0b1011110)
    {
        uint8_t r = GET_BITS(inst, 8, 1);
        uint8_t list = GET_BITS(inst, 7, 8);
        uint32_t addr = SP;

        for(int i = 0; i < 8; i++){
            if((list & (1 << i)) != 0){
                ram[addr] = cpu.reg[i];
                addr += 4;
            }
        }
        if(r == 1){
            ram[addr] = PC;
            addr += 4;
        }

        SP = addr;
    }

    // B, COND
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
            PC += offset * 2 + 2;
        }
        return 0;
    }

    // B, NO-COND
    else if (GET_BITS(inst, 15, 5) == 0b11100) {
        int16_t offset = GET_BITS(inst, 10, 11);
        if(GET_BITS(inst, 10, 1) == 1){
            offset <<= 5;
            offset >>= 5;
        }
        PC += offset * 2 + 2;
        return 0;
    }

    // BLX
    else if(GET_BITS(inst, 15, 5) == 0b11101) {
        uint16_t offset = GET_BITS(inst, 10, 10);

        uint16_t prev_inst = rom[PC - 6] | rom[PC - 5] << 8;
        if(GET_BITS(prev_inst, 15, 5) != 0b11110){
            fprintf(stderr, "BLX: previous instruction is not a branch prefix instruction 0x%08X  0x%04X\n", PC - 4, prev_inst);
            return 1;
        }

        int16_t poff = GET_BITS(prev_inst, 10, 11);
        LR = PC;
        PC = (PC + 2 + (poff<<12) + offset*4) & ~3;
        return 0;
    }
    
    // BL
    else if(GET_BITS(inst, 15, 5) == 0b11111) {
        uint16_t offset = GET_BITS(inst, 10, 11);

        uint16_t prev_inst = rom[PC - 6] | rom[PC - 1] << 8;
        // if(GET_BITS(prev_inst, 15, 5) != 0b11110){
        //     return 1;
        //     // fprintf(stderr, "BL: previous instruction is not a branch prefix instruction 0x%08X  0x%04X 0x%04X\n", PC - 4, prev_inst, inst);
        //     // return 1;
        // }

        int16_t poff = GET_BITS(prev_inst, 10, 11);
        LR = PC;
        PC += 2 + (poff<<12) + offset*2;
        return 0;
    }



    fprintf(stderr, "invalid instruction 0x%08X 0x%04X\n", PC - 4, inst);
    return 1;
}


void debug_dialog () {
    printf("%c[2J%c[1;1H", 27, 27);
        printf("\n\nDebug instruction!\n");
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
            printf("%c[2J%c[1;1H", 27, 27);
            puts("\n\nPrint memory from xxxxxxxx to xxxxxxxx (hex)");
            puts("To exit type 0-0");
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
            else { // ???
                printf("instruction unclear");
            }

            printf("\n");
        }
}