#include <stdint.h>

int32_t load_program(char *path, uint8_t *rom, uint8_t *ram);

int32_t system_init();

void system_deinit();

int32_t peripheral_write(uint32_t addr, uint32_t value);

int32_t peripheral_read(uint32_t addr, uint32_t *value);
