#include "emulib.h"

typedef struct {
    int32_t reg[16];
    int32_t cpsr;
}tCPU;

uint8_t rom[0x200000];
uint8_t ram[0x100000];
tCPU cpu;


int32_t execute_next(void);


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



//Fetches an instruction from ROM, decodes and executes it
int32_t execute_next(void)
{

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

    uint16_t inst = rom[PC - 2] | rom[PC - 1] << 8;
    PC += 2;

    // ANDS
    if (GET_BITS(inst, 15, 10) == 0b0100'0000'00)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint32_t ra = cpu.reg[rd];
        uint32_t rb = cpu.reg[rm];
        uint32_t rc = ra & rb;
        cpu.reg[rd] = rc;
        
        if(rc == 0) SET_BIT(FLG, FLG_Z);
        else RESET_BIT(FLG, FLG_Z);
        if (rc >= (1 << 31)) SET_BIT(FLG, FLG_N);
        else RESET_BIT(FLG, FLG_N);

        fprintf(stderr, "ANDS r%u,r%u\n", rd, rm);
        return 0;
    }
    // EORS
    else if (GET_BITS(inst, 15, 10) == 0b0100'0000'01)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint32_t ra = cpu.reg[rd];
        uint32_t rb = cpu.reg[rm];
        uint32_t rc = ra ^ rb;
        cpu.reg[rd] = rc;
        
        if(rc == 0) SET_BIT(FLG, FLG_Z);
        else RESET_BIT(FLG, FLG_Z);
        if (rc >= (1 << 31)) SET_BIT(FLG, FLG_N);
        else RESET_BIT(FLG, FLG_N);

        fprintf(stderr, "EORS r%u,r%u\n", rd, rm);
        return 0;
    }
    // LSLS
    else if (GET_BITS(inst, 15, 10) == 0b0100'0000'10)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint32_t ra = cpu.reg[rd];
        uint32_t rb = cpu.reg[rm];
        uint32_t rc = ra << rb;
        cpu.reg[rd] = rc;
        
        if(rc == 0) SET_BIT(FLG, FLG_Z);
        else RESET_BIT(FLG, FLG_Z);
        if (rc >= (1 << 31)) SET_BIT(FLG, FLG_N);
        else RESET_BIT(FLG, FLG_N);

        fprintf(stderr, "LSLS r%u,r%u\n", rd, rm);
        return 0;
    }
    // LSRS
    else if (GET_BITS(inst, 15, 10) == 0b0100'0000'11)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint32_t ra = cpu.reg[rd];
        uint32_t rb = cpu.reg[rm];
        uint32_t rc = ra >> rb;
        cpu.reg[rd] = rc;
        
        if(rc == 0) SET_BIT(FLG, FLG_Z);
        else RESET_BIT(FLG, FLG_Z);
        if (rc >= (1 << 31)) SET_BIT(FLG, FLG_N);
        else RESET_BIT(FLG, FLG_N);

        fprintf(stderr, "LSRS r%u,r%u\n", rd, rm);
        return 0;
    }
    // ASRS
    else if (GET_BITS(inst, 15, 10) == 0b0100'0001'00)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        int32_t ra = cpu.reg[rd];
        int32_t rb = cpu.reg[rm];
        int32_t rc = ra >> rb;
        cpu.reg[rd] = rc;
        
        if(rc == 0) SET_BIT(FLG, FLG_Z);
        else RESET_BIT(FLG, FLG_Z);
        if (rc < 0) SET_BIT(FLG, FLG_N);
        else RESET_BIT(FLG, FLG_N);

        fprintf(stderr, "ASRS r%u,r%u\n", rd, rm);
        return 0;
    }
    // ADCS
    else if (GET_BITS(inst, 15, 10) == 0b0100'0001'01)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        int32_t ra = cpu.reg[rd];
        int32_t rb = cpu.reg[rm];
        int32_t rc = ra + rb;
        cpu.reg[rd] = rc + GET_BITS(FLG, FLG_C, 1);
        
        if(rc == 0) SET_BIT(FLG, FLG_Z);
        else RESET_BIT(FLG, FLG_Z);
        if (rc < 0) SET_BIT(FLG, FLG_N);
        else RESET_BIT(FLG, FLG_N);

        // TODO: Add the carry flag code

        if(ra > 0 && rb > 0 && rc < 0) SET_BIT(FLG, FLG_V);
        else if(ra < 0 && rb < 0 && rc > 0) SET_BIT(FLG, FLG_V);
        else RESET_BIT(FLG, FLG_V);

        fprintf(stderr, "ADCS r%u,r%u\n", rd, rm);
        return 0;
    }
    // SBCS
    else if (GET_BITS(inst, 15, 10) == 0b0100'0001'10)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        int32_t ra = cpu.reg[rd];
        int32_t rb = cpu.reg[rm];
        int32_t rc = rb - ra;
        cpu.reg[rd] = rc - GET_BITS(FLG, FLG_C, 1);
        
        if(rc == 0) SET_BIT(FLG, FLG_Z);
        else RESET_BIT(FLG, FLG_Z);
        if (rc < 0) SET_BIT(FLG, FLG_N);
        else RESET_BIT(FLG, FLG_N);

        // TODO: Add the overflow and carry flag code

        fprintf(stderr, "SBCS r%u,r%u\n", rd, rm);
        return 0;
    }
    // RORS
    else if (GET_BITS(inst, 15, 10) == 0b0100'0001'11)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint32_t ra = cpu.reg[rd];
        uint32_t rb = cpu.reg[rm] % 32;
        uint32_t rc = (ra >> rb) | (ra << (32 - rb));
        cpu.reg[rd] = rc;
        
        if(rc == 0) SET_BIT(FLG, FLG_Z);
        else RESET_BIT(FLG, FLG_Z);
        if (rc >= (1 << 31)) SET_BIT(FLG, FLG_N);
        else RESET_BIT(FLG, FLG_N);

        // TODO: Add the carry flag code

        fprintf(stderr, "RORS r%u,r%u\n", rd, rm);
        return 0;
    }
    // TSTS
    else if (GET_BITS(inst, 15, 10) == 0b0100'0010'00)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint32_t ra = cpu.reg[rd];
        uint32_t rb = cpu.reg[rm];
        uint32_t rc = ra & rb;
        cpu.reg[rd] = rc;
        
        if(rc == 0) SET_BIT(FLG, FLG_Z);
        else RESET_BIT(FLG, FLG_Z);
        if (rc >= (1 << 31)) SET_BIT(FLG, FLG_N);
        else RESET_BIT(FLG, FLG_N);

        fprintf(stderr, "TSTS r%u,r%u\n", rd, rm);
        return 0;
    }
    // NEG !!!!!
    else if (GET_BITS(inst, 15, 10) == 0b0100'0010'01)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint32_t ra = cpu.reg[rm];
        uint32_t rc = ~ra;
        cpu.reg[rd] = rc;
        
        if (rc == 0) SET_BIT(FLG, FLG_Z);
        else RESET_BIT(FLG, FLG_Z);
        if (rc >= (1 << 31)) SET_BIT(FLG, FLG_N);
        else RESET_BIT(FLG, FLG_N);
        

        fprintf(stderr, "NEG r%u,r%u\n", rd, rm);
        return 0;
    }
    // CMP
    else if (GET_BITS(inst, 15, 10) == 0b0100'0010'10)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        int32_t ra = cpu.reg[rd];
        int32_t rb = cpu.reg[rm];
        int32_t rc = ra - rb;
        
        if(rc == 0) SET_BIT(FLG, FLG_Z);
        else RESET_BIT(FLG, FLG_Z);
        if (rc < 0) SET_BIT(FLG, FLG_N);
        else RESET_BIT(FLG, FLG_N);

        // TODO: Add the overflow and carry flag code
        
        fprintf(stderr, "CMP r%u,r%u\n", rd, rm);
        return 0;
    }
    // CMN
    else if (GET_BITS(inst, 15, 10) == 0b0100'0010'11)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        int32_t ra = cpu.reg[rd];
        int32_t rb = cpu.reg[rm];
        int32_t rc = ra + rb;
        
        if(rc == 0) SET_BIT(FLG, FLG_Z);
        else RESET_BIT(FLG, FLG_Z);
        if (rc < 0) SET_BIT(FLG, FLG_N);
        else RESET_BIT(FLG, FLG_N);

        // TODO: Add the overflow and carry flag code
        
        fprintf(stderr, "CMN r%u,r%u\n", rd, rm);
        return 0;
    }
    // ORRS
    else if (GET_BITS(inst, 15, 10) == 0b0100'0011'00)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint32_t ra = cpu.reg[rd];
        uint32_t rb = cpu.reg[rm];
        uint32_t rc = ra | rb;
        cpu.reg[rd] = rc;
        
        if(rc == 0) SET_BIT(FLG, FLG_Z);
        else RESET_BIT(FLG, FLG_Z);
        if (rc >= (1 << 31)) SET_BIT(FLG, FLG_N);
        else RESET_BIT(FLG, FLG_N);

        fprintf(stderr, "ORRS r%u,r%u\n", rd, rm);
        return 0;
    }
    // BICS
    else if (GET_BITS(inst, 15, 10) == 0b0100'0011'10)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint32_t ra = cpu.reg[rd];
        uint32_t rb = cpu.reg[rm];
        uint32_t rc = ra & ~rb;
        cpu.reg[rd] = rc;
        
        if(rc == 0) SET_BIT(FLG, FLG_Z);
        else RESET_BIT(FLG, FLG_Z);
        if (rc >= (1 << 31)) SET_BIT(FLG, FLG_N);
        else RESET_BIT(FLG, FLG_N);

        fprintf(stderr, "BICS r%u,r%u\n", rd, rm);
        return 0;
    }

    // MVNS
    else if (GET_BITS(inst, 15, 10) == 0b0100'0011'11)
    {
        uint8_t rd = GET_BITS(inst, 2, 3);
        uint8_t rm = GET_BITS(inst, 5, 3);
        uint32_t ra = cpu.reg[rm];
        uint32_t rc = ~ra;
        cpu.reg[rd] = rc;
        
        if (rc == 0) SET_BIT(FLG, FLG_Z);
        else RESET_BIT(FLG, FLG_Z);
        if (rc >= (1 << 31)) SET_BIT(FLG, FLG_N);
        else RESET_BIT(FLG, FLG_N);
        

        fprintf(stderr, "MVNS r%u,r%u\n", rd, rm);
        return 0;
    }
    
    fprintf(stderr, "invalid instruction 0x%08X 0x%04X\n", PC - 4, inst);
    return 1;
}
