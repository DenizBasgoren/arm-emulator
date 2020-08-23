
#ifndef _NVIC_H_
#define _NVIC_H_

#include <stdint.h>

#include "emulator.h"

// INTERRUPTS:
// 0 = reset
// 1 = nmi
// 2 = exception
// 3 = systick
// 4 = pendsv
// 5 = syscall
// 6 = file system (reserved)
// 7 = gpu (reserved)
// 8 = keyboard (reserved)
// 9 = mouse (reserved)
// 10 = synth (reserved)

extern uint8_t nvic[NVIC_LEN];

int nvic_init();

int nvic_deinit();

void nvic_print();

void nvic_activate();

void nvic_update();

void nvic_exit_interrupt();

int32_t nvic_write(uint32_t addr, uint32_t value, int n_bytes);

int32_t nvic_read(uint32_t addr, uint32_t *destination, int n_bytes);


#endif