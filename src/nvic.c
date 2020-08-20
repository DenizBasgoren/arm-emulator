
#include <stdint.h>

#include "emulator.h"

uint8_t nvic[NVIC_LEN];


struct nvic_entry { // 16 byte each
	// 0
	uint32_t handler;
	// 4
	uint32_t priority;
	// 8
	uint32_t status;
	// 12
	uint8_t _[4];
};

struct nvic {
	// 00
	struct nvic_entry entry[16];
};



int nvic_init() {

}

int nvic_deinit() {

}


int32_t nvic_write(uint32_t addr, uint32_t value, int n_bytes) {

}

int32_t nvic_read(uint32_t addr, uint32_t *destination, int n_bytes) {

}
