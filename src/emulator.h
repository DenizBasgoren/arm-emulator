#include <stdint.h>

struct cpu_t {
    int32_t reg[16];
    int32_t cpsr;
};

extern struct cpu_t cpu;


#define ROM_MAX 0x1FFFFFFF
#define ROM_MIN 0x00000000
#define ROM_LEN 0x200000

#define RAM_MAX 0x3FFFFFFF
#define RAM_MIN 0x20000000
#define RAM_LEN 0x100000

#define PER_MAX 0x5FFFFFFF
#define PER_MIN 0x40000000

#define GPU_MAX 0x4000003F
#define GPU_MIN 0x40000000
#define GPU_LEN 0x40

// start (in order of documentation), offset ( number of bits from start to direction of 0)
// GET_BITS( 010110, 3, 4 ) == 0110
#define GET_BITS(bits, start, offset) (((bits) >> ((start) - (offset) + 1)) & ((1 << (offset)) - 1))

// set a bit to 1 in given bits
#define SET_BIT(bits, n) ((bits) |= (1 << (n)))

// set a bit to 0 in given bits
#define RESET_BIT(bits,b) ((bits) &= ~(1ULL<<(b)))

// we will refer to values in registers by these shortcuts
#define R0  (cpu.reg[0])
#define R1  (cpu.reg[1])
#define R2  (cpu.reg[2])
#define R3  (cpu.reg[3])
#define R4  (cpu.reg[4])
#define R5  (cpu.reg[5])
#define R6  (cpu.reg[6])
#define R7  (cpu.reg[7])
#define R8  (cpu.reg[8])
#define R9  (cpu.reg[9])
#define R10  (cpu.reg[10])
#define R11  (cpu.reg[11])
#define R12  (cpu.reg[12])
#define SP  (cpu.reg[13])
#define LR  (cpu.reg[14])
#define PC  (cpu.reg[15])
#define FLG (cpu.cpsr) // flag register
#define FLG_N (31)
#define FLG_Z (30)
#define FLG_C (29)
#define FLG_V (28)

#define GREEN_TERM "\x1b[32m"
#define WHITE_TERM "\x1b[97m"
#define GRAY_TERM "\x1b[37m"


// memory
extern uint8_t rom[ROM_LEN];
extern uint8_t ram[RAM_LEN];
extern uint8_t gpu[0x40];

struct range {
    char exists;
    char* min;
    char* max;
    int len;
    char* real_min;
    char* real;
    char* real_max;
};

struct range rangeOf(int from);

extern int is_debug_mode;