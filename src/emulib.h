#include <stdint.h>

int32_t load_program(char *rom_path, char *ram_path, uint8_t *rom, uint8_t *ram);

int32_t system_init();

void system_deinit();

int32_t peripheral_write(uint32_t addr, uint32_t value, int n_bytes);

int32_t peripheral_read(uint32_t addr, uint32_t *destination, int n_bytes);
