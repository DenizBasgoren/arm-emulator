
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#include "emulator.h"
#include "nvic.h"

uint8_t nvic[NVIC_LEN];

#define N_INTS 16
#define N_PRIORITIES 16

struct nvic_entry { // 16 byte each
	// 0
	uint32_t handler;
	// 4
	uint32_t priority; // 0-15 inclusive, 0=highest priority, 15=default, reset:-3, nmi:-2, exc:-1
	// 8
	uint32_t status; // 0=inactive, 1=pending, 2=active, 3=active+pending
	// 12
	uint8_t _[4];
};

struct nvic {
	// 00
	struct nvic_entry entry[N_INTS];
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

	uint32_t current_stack; // 0=kernel (default), 1=user
};

static kernel_stack_addr = RAM_MAX;
static user_stack_addr = RAM_MAX;



int nvic_init() {
	// set all priorities to 15
	// set all statuses to inactive, except reset, active
	// set all handlers to 0x0

	struct nvic* p = (struct nvic*) &nvic;
	for (int i = 0; i<N_INTS; i++) {
		p->entry[i].handler = 0;
		p->entry[i].priority = N_PRIORITIES - 1;
		p->entry[i].status = 0;
	}
	p->entry[0].status = 2;
	p->current_stack = 0;
	SP = kernel_stack_addr;
}

int nvic_deinit() {
	// nothing here
}

void nvic_print() {
	struct nvic* p = (struct nvic*) &nvic;

	printf("\nIND:\t");
	for (int i = 0; i<N_INTS/2; i++) {
		printf("%2d ", i);
	}

	printf("\nPRI:\t");
	for (int i = 0; i<N_INTS/2; i++) {
		printf("%2d ", p->entry[i].priority);
	}

	printf("\nSTS:\t");
	for (int i = 0; i<N_INTS/2; i++) {
		switch( p->entry[i].status ) {
			case 0:
			printf(" I ");
			break;
			case 1:
			printf(" W ");
			break;
			case 2:
			printf(" A ");
			break;
			case 3:
			printf(" R ");
			break;
		}
	}

	puts("");
}


void nvic_update() {
	// find priority of active (there can be only one at a time)
        // if no active, look for aps. make ap with max priority the active
        // if no aps, find priority of highest pending
        // if it is 

        // algo

        // loop1: find active and pending with max pr
        // loop1 end

        // if active exists,
        ///// if any pending with max pr > active pr
        //////// preempt
        ///// else
        /////// move on (exec next)

        // if active doesnt exist,
        ///// 
}

void nvic_activate(int index) {
	nvic_write(NVIC_MIN + 16*index + 8, 1, 4);
}

void nvic_exit_interrupt() {
	if (PC == 0xFFFFFFF1) {
		// return to kernel mode
	}
	else if ( PC == 0xFFFFFFFD ) {
		// return to user mode

		// change to user stack
		// restore pc, lr, r3, r2, r1, r0
	}

	// for now, ignore difference between kernel and user mode
	// TODO
}

int32_t nvic_write(uint32_t addr, uint32_t value, int n_bytes) {
	if (addr < NVIC_MIN || addr > NVIC_MAX) return -1;
	if (n_bytes != 4 || addr % 4 ) return -1; // only word access

	struct nvic* p = (struct nvic*) &nvic;

	uint32_t offset = addr - NVIC_MIN;

	// stack changer
	if (offset == N_INTS*16) {
		// if is > 1, return -1
		if (value > 1) return -1;

		// if was 0, is 0, do nothing
		else if (value == 0 && p->current_stack == 0) return 0;

		// if was 1, is 1, do nothing
		else if (value == 1 && p->current_stack == 1) return 0;

		// if was 1, is 0:
		else if (value == 0 && p->current_stack == 1) {
			user_stack_addr = SP;
			p->current_stack = 0;
			SP = kernel_stack_addr;
			return 0;
		}

		// if was 0, is 1:
		else if (value == 1 && p->current_stack == 0) {
			kernel_stack_addr = SP;
			p->current_stack = 1;
			SP = user_stack_addr;
			return 0;
		}
	}

	// handlers can be changed freely
	// priority can be changed. if its > 15, fix to 15
	// if writing smth to status, it means activation.

	else {
		// handler
		if (offset % 16 == 0) {
			memcpy(nvic + offset, &value, 4);
		}

		//priority
		else if (offset % 16 == 4) {
			if (value > N_PRIORITIES - 1) value = N_PRIORITIES - 1;
			memcpy(nvic + offset, &value, 4);
		}

		// status
		else if (offset % 16 == 8) {
			if ( *(nvic+offset) == 0) *(nvic+offset) = 1; 
		}

		// can't write to padding bytes
		else return -1;
	}
	
	return 0;

}

int32_t nvic_read(uint32_t addr, uint32_t *destination, int n_bytes) {
	if (destination == NULL ) return -1;
	if (addr < NVIC_MIN || addr > NVIC_MAX) return -1;
	if (n_bytes != 4 || addr % 4 ) return -1; // only word access

	uint32_t offset = addr - NVIC_MIN;

	// current stack reader!
	if (offset == N_INTS*16) {
		memcpy(destination, nvic + addr - NVIC_MIN, 4);
	}
	else { // entries

		// cant read padding bytes
		if ( offset % 16 == 12) return -1;

		// otherwise, all is public
		memcpy(destination, nvic + addr - NVIC_MIN, 4);
	}
	
	return 0;
}
