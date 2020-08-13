#include <stdint.h>


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


int32_t load_program(char *path, uint8_t *rom, uint8_t *ram);

int32_t system_init();

void system_deinit();

int32_t peripheral_write(uint32_t addr, uint32_t value, int n_bytes);

int32_t peripheral_read(uint32_t addr, uint32_t *destination, int n_bytes);
