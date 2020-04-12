#include "emulib.h"
#include <SDL/SDL.h>

#define SCREEN_WIDTH	320
#define SCREEN_HEIGHT	240

static SDL_Surface *screen;
static int32_t debug = 0;
static int32_t xpos = 0;
static int32_t ypos = 0;
static uint32_t XBuf[SCREEN_WIDTH*SCREEN_HEIGHT];

static void updateFrameBuffer(uint32_t *dstPtr, uint32_t *srcPtr);
static int32_t setCursorX(int32_t x);
static int32_t setCursorY(int32_t y);
static void refresh();
static void clean();
static void writePixel(uint32_t color);
static void readPixel(uint32_t *color);

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
	if (debug)
		printf("Set cursor column to %d\n", x);
	if (x < 0 || x >= SCREEN_WIDTH)
		return -1;
	xpos = x;
	return 0;
}

static int32_t setCursorY(int32_t y)
{
	if (debug)
		printf("Set cursor row to %d\n", y);
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

int32_t load_program(char *path, uint8_t *rom) {
	FILE *infile;
	uint32_t len;
	char cmd[512];

	if (rom == NULL)
	{
		printf("Invalid ROM memory pointer, please supply one!\n");
		return -1;
	}

	printf("Input program:");
	printf("%s", path);

	printf("\nAssembling...\n");

	sprintf(cmd, "arm-none-eabi-as -mcpu=cortex-m0 -mthumb %s -o armapp.o", path);
	if (system(cmd) != 0)
	{
		return -1;
	}

	printf("\nLinking...\n");

	sprintf(cmd, "arm-none-eabi-ld -T linker.ld armapp.o -o armapp.elf");
	if (system(cmd) != 0)
	{
		return -1;
	}

	printf("Generating binary...\n");

	sprintf(cmd, "arm-none-eabi-objcopy -O binary armapp.elf armapp.bin");
	if (system(cmd) != 0)
	{
		return -1;
	}

	infile = fopen("armapp.bin", "rb");
	fseek(infile, 0, SEEK_END);
	len = ftell(infile);
	fseek(infile, 0, SEEK_SET);

	if (fread(rom, 1, len, infile) != len)
	{
		printf("Assembled file read error!\n");
		fclose(infile);
		return -1;
	}

	fclose(infile);
	printf("Successfully assembled and loaded the program\n");
	printf("Code size: %u bytes, instruction count: %u\n", len, len / 2);

	// REMOVE BINARIES AFTER ROM LOAD
	// sprintf(cmd, "rm ./armapp.*");
	// if (system(cmd) != 0)
	// {
	// 	return -1;
	// }
	// END

	return len;
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
	}
	return -1;
}

void set_debug(int32_t enable)
{
	debug = enable;
}
