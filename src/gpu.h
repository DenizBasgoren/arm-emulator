
#ifndef _GPU_H_
#define _GPU_H_

#include <stdint.h>

#include "emulator.h"

extern uint8_t gpu[GPU_LEN];

int gpu_init();

int gpu_deinit();


int32_t gpu_write(uint32_t addr, uint32_t value, int n_bytes);

int32_t gpu_read(uint32_t addr, uint32_t *destination, int n_bytes);


#endif