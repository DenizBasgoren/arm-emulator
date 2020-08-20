
#ifndef _NVIC_H_
#define _NVIC_H_

#include <stdint.h>

#include "emulator.h"

extern uint8_t nvic[NVIC_LEN];

int nvic_init();

int nvic_deinit();


int32_t nvic_write(uint32_t addr, uint32_t value, int n_bytes);

int32_t nvic_read(uint32_t addr, uint32_t *destination, int n_bytes);


#endif