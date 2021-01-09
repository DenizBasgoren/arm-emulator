
#include <SDL/SDL.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#include "emulib.h"



#define SCREEN_WIDTH	320
#define SCREEN_HEIGHT	240

static SDL_Surface *screen;
static int32_t xpos = 0;
static int32_t ypos = 0;
static uint32_t XBuf[SCREEN_WIDTH*SCREEN_HEIGHT];

// prototypes
static void updateFrameBuffer(uint32_t *dstPtr, uint32_t *srcPtr);
static int32_t setCursorX(int32_t x);
static int32_t setCursorY(int32_t y);
static void refresh();
static void clean();
static void writePixel(uint32_t color);
static void readPixel(uint32_t *color);
static void readKeyboard(uint32_t *value);


// implementations
static void updateFrameBuffer(uint32_t *dstPtr, uint32_t *srcPtr)
{
    int32_t i, j;

    for(i = 0; i < SCREEN_HEIGHT; i++)
    {
        for(j = 0; j < SCREEN_WIDTH; j++)
        {
            *dstPtr++ = *srcPtr++;
        }
    }
}

static int32_t setCursorX(int32_t x)
{
	if (x < 0 || x >= SCREEN_WIDTH)
		return -1;
	xpos = x;
	return 0;
}

static int32_t setCursorY(int32_t y)
{
	if (y < 0 || y >= SCREEN_HEIGHT)
		return -1;
	ypos = y;
	return 0;
}

static void writePixel(uint32_t color)
{
	XBuf[ypos*SCREEN_WIDTH+xpos] = color;
}

static void readPixel(uint32_t *color)
{
	*color = XBuf[ypos*SCREEN_WIDTH+xpos];
}

static void refresh()
{
	if(SDL_LockSurface(screen) == 0)
	{
		updateFrameBuffer(screen->pixels, XBuf);
	}
	SDL_UnlockSurface(screen);
	SDL_Flip(screen);
}

static void clean()
{
	memset(XBuf, 0, sizeof(XBuf));
	refresh();
}

static void readKeyboard(uint32_t *value) {
	
	SDL_PumpEvents();

	const uint8_t *state = (uint8_t*) SDL_GetKeyState(NULL);

	*value = \
		state[SDLK_a] << 31 |
		state[SDLK_b] << 30 |
		state[SDLK_c] << 29 |
		state[SDLK_d] << 28 |
		state[SDLK_e] << 27 |
		state[SDLK_f] << 26 |
		state[SDLK_g] << 25 |
		state[SDLK_h] << 24 |
		state[SDLK_i] << 23 |
		state[SDLK_j] << 22 |
		state[SDLK_k] << 21 |
		state[SDLK_l] << 20 |
		state[SDLK_m] << 19 |
		state[SDLK_n] << 18 |
		state[SDLK_o] << 17 |
		state[SDLK_p] << 16 |
		state[SDLK_q] << 15 |
		state[SDLK_r] << 14 |
		state[SDLK_s] << 13 |
		state[SDLK_t] << 12 |
		state[SDLK_u] << 11 |
		state[SDLK_v] << 10 |
		state[SDLK_w] << 9 |
		state[SDLK_x] << 8 |
		state[SDLK_y] << 7 |
		state[SDLK_z] << 6 |
		state[SDLK_UP] << 5 |
		state[SDLK_RIGHT] << 4 |
		state[SDLK_DOWN] << 3 |
		state[SDLK_LEFT] << 2 |
		state[SDLK_SPACE] << 1 |
		state[SDLK_ESCAPE];
}


int32_t system_init()
{
    if (SDL_Init(SDL_INIT_VIDEO) != 0)
	{
        printf("Unable to initialize SDL: %s", SDL_GetError());
        return -1;
    }

    screen = SDL_SetVideoMode(SCREEN_WIDTH, SCREEN_HEIGHT, 32, SDL_HWSURFACE);

	return 0;
}

void system_deinit()
{
	SDL_Quit();
}


int32_t load_program(char *path, uint8_t *rom, uint8_t *ram) {
	FILE *infile;
	uint32_t len;
	int32_t errorCode = 0;
	char cmd[512];

	if (rom == NULL || ram == NULL)
	{
		return -1;
	}

	sprintf(cmd, "arm-none-eabi-as -mcpu=cortex-m0 -mthumb %s -o armapp.o", path);
	if (system(cmd) != 0)
	{
		errorCode = -1;
		goto cleanup1;
	}

	sprintf(cmd, "arm-none-eabi-ld -T linker.ld armapp.o -o armapp.elf");
	if (system(cmd) != 0)
	{
		errorCode = -1;
		goto cleanup1;
	}

	sprintf(cmd, "arm-none-eabi-objcopy -O binary -j .text armapp.elf text.bin");
	if (system(cmd) != 0)
	{
		errorCode = -1;
		goto cleanup1;
	}

	sprintf(cmd, "arm-none-eabi-objcopy -O binary -j .data armapp.elf data.bin");
	if (system(cmd) != 0)
	{
		errorCode = -1;
		goto cleanup1;
	}

	// load text to rom
	infile = fopen("text.bin", "rb");
	fseek(infile, 0, SEEK_END);
	len = ftell(infile);
	fseek(infile, 0, SEEK_SET);

	if (fread(rom, 1, len, infile) != len)
	{
		errorCode = -1;
		goto cleanup2;
	}
	fclose(infile);


	// load data to ram
	infile = fopen("data.bin", "rb");
	fseek(infile, 0, SEEK_END);
	len = ftell(infile);
	fseek(infile, 0, SEEK_SET);

	if (fread(ram, 1, len, infile) != len)
	{
		errorCode = -1;
		goto cleanup2;
	}

	printf("Assembled successfully!\n");

	cleanup1:
	fclose(infile);

	cleanup2:
	#if defined(__unix__)
		system("rm armapp.o text.bin data.bin");
	#elif defined(_WIN32) || defined(_WIN64)
		system("del armapp.o text.bin data.bin");
	#endif

	return errorCode;
}

int32_t peripheral_write(uint32_t addr, uint32_t value)
{
	switch(addr)
	{
		case 0x40010000:   //row register
			return setCursorY(value);
		case 0x40010004:   //column register
			return setCursorX(value);
		case 0x40010008:   //color register
			writePixel(value);
			return 0;
		case 0x4001000C:
			refresh();
			return 0;
		case 0x40010010:
			clean();
			return 0;
	}
	return -1;
}

int32_t peripheral_read(uint32_t addr, uint32_t *value)
{
	if (value == NULL)
		return -1;
	switch(addr)
	{
		case 0x4001000C:   //color register
			readPixel(value);
			return 0;
		case 0x40010020:
			readKeyboard(value);
			return 0;
	}
	return -1;
}
