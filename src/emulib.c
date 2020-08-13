
#include <SDL2/SDL.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#include "emulib.h"



#define SCREEN_WIDTH	800
#define SCREEN_HEIGHT	600
#define N_SLOTS			4
#define WINDOW_NAME		"Puhu OS"

extern uint8_t *gpu;
extern uint8_t *ram;

static SDL_Window *window;
static SDL_Renderer *renderer;
static SDL_Texture *textures[ N_SLOTS ]; // arr of 4 ptr to texture
static SDL_Event event;

// prototypes
static int gpu_clear(int mode );
static int gpu_draw(int mode );
static int gpu_update();
// static void readKeyboard(uint32_t *value);

struct gpu {
	// 00
	uint16_t const_screen_w;
	uint16_t const_screen_h;
	uint8_t const_n_slots;
	uint8_t _[11];
	// 10
	uint8_t clear_fn;
	uint8_t draw_fn;
	uint8_t update_fn;
	uint8_t __[13];
	// 20
	uint8_t red; // clear_call
	uint8_t green;
	uint8_t blue;
	uint8_t alpha;
	uint16_t texture_w; // struct texture
	uint16_t texture_h;
	uint32_t texture_data_addr;
	uint8_t texture_channel; // 3 = rgb, 4 = rgba
	uint8_t selected_slot;
	uint8_t ___[2];
	// 30
	uint16_t src_x; // texture pixel position
	uint16_t src_y;
	uint16_t src_w;
	uint16_t src_h;
	uint16_t target_x; // screen pixel position
	uint16_t target_y;
	uint16_t target_w;
	uint16_t target_h;
};


static int gpu_clear( int mode ) // 0 = all 1 = rect
{
	struct gpu* p = (struct gpu*) gpu;
	if (p->red > 255 || p->green > 255 || p->blue > 255 || p->alpha > 255) return -1;

	SDL_SetRenderDrawColor(renderer, p->red, p->green, p->blue, p->alpha); // alpha=255 is opaque
	
	if (mode == 0)
	{
		return SDL_RenderClear(renderer);
	}
	else if (mode == 1)
	{
		SDL_Rect target = {
			p->target_x,
			p->target_y,
			p->target_w,
			p->target_h
		};

		if (target.x + target.w > SCREEN_WIDTH ) return -1;
		if (target.y + target.h > SCREEN_HEIGHT ) return -1;
		

		return SDL_RenderDrawRect(renderer, &target);
	}
	else return -1;
}

static int gpu_draw( int mode ) {
							// 0= no clipping, no resizing
							// 1= no clipping, resize
							// 2= clip, no resizing
							// 3= clip, resize
	struct gpu* p = (struct gpu*) gpu;
	if (p->selected_slot >= N_SLOTS) return -1;

	SDL_Texture* t = textures[p->selected_slot];
	char resize = mode == 1 || mode == 3;
	char clip = mode == 2 || mode == 3;

	SDL_Rect src = {
		p->src_x,
		p->src_y,
		p->src_w,
		p->src_h
	};

	SDL_Rect target = {
		p->target_x,
		p->target_y,
		p->target_w,
		p->target_h
	};

	if (resize) {
		if (target.x + target.w > SCREEN_WIDTH ) return -1;
		if (target.y + target.h > SCREEN_HEIGHT ) return -1;
	}
			
	char err = SDL_RenderCopy(renderer,
				t,
				clip ? &src : NULL,
				resize ? &target : NULL );
	
	if (err) return -1;

	SDL_RenderPresent(renderer);
	return 0;

}

static int gpu_update() {

	struct gpu* p = (struct gpu*) gpu;
	if (p->selected_slot >= N_SLOTS) return -1;

	// if there was an old one, remove it first
	SDL_Texture* t = textures[p->selected_slot];
	if ( t ) SDL_DestroyTexture( t );
	t = NULL;

	int channel, nBytes;
	if ( p->texture_channel == 3 ) {
		channel = SDL_PIXELFORMAT_RGB24;
		nBytes = 3;
	}
	else if ( p -> texture_channel == 4) {
		channel = SDL_PIXELFORMAT_RGBA8888;
		nBytes = 4;
	}
	else return -1;

	if ( p->texture_data_addr - ROM_MIN  +
		p->texture_w * p->texture_h * nBytes > RAM_LEN ) {
			return -1;
	}

	textures[p->selected_slot ] = SDL_CreateTexture(
		renderer,
		channel,
		SDL_TEXTUREACCESS_STATIC,
		p->texture_w,
		p->texture_h );
	
	SDL_UpdateTexture( textures[p->selected_slot],
					NULL,
					p->texture_data_addr - RAM_MIN + ram,
					p->texture_w * nBytes );

	return 0;
}

// static void readKeyboard(uint32_t *value) {
	
// 	SDL_PumpEvents();

// 	const uint8_t *state = (uint8_t*) SDL_GetKeyState(NULL);

// 	*value = \
// 		state[SDLK_a] << 31 |
// 		state[SDLK_b] << 30 |
// 		state[SDLK_c] << 29 |
// 		state[SDLK_d] << 28 |
// 		state[SDLK_e] << 27 |
// 		state[SDLK_f] << 26 |
// 		state[SDLK_g] << 25 |
// 		state[SDLK_h] << 24 |
// 		state[SDLK_i] << 23 |
// 		state[SDLK_j] << 22 |
// 		state[SDLK_k] << 21 |
// 		state[SDLK_l] << 20 |
// 		state[SDLK_m] << 19 |
// 		state[SDLK_n] << 18 |
// 		state[SDLK_o] << 17 |
// 		state[SDLK_p] << 16 |
// 		state[SDLK_q] << 15 |
// 		state[SDLK_r] << 14 |
// 		state[SDLK_s] << 13 |
// 		state[SDLK_t] << 12 |
// 		state[SDLK_u] << 11 |
// 		state[SDLK_v] << 10 |
// 		state[SDLK_w] << 9 |
// 		state[SDLK_x] << 8 |
// 		state[SDLK_y] << 7 |
// 		state[SDLK_z] << 6 |
// 		state[SDLK_UP] << 5 |
// 		state[SDLK_RIGHT] << 4 |
// 		state[SDLK_DOWN] << 3 |
// 		state[SDLK_LEFT] << 2 |
// 		state[SDLK_SPACE] << 1 |
// 		state[SDLK_ESCAPE];
// }


int32_t system_init()
{

	if (SDL_Init( SDL_INIT_TIMER | SDL_INIT_VIDEO | SDL_INIT_AUDIO | SDL_INIT_EVENTS)) {
		printf("No SDL :c %s", SDL_GetError());
	}

 	window = SDL_CreateWindow(WINDOW_NAME,
                        300, // position
                        100,
                        SCREEN_WIDTH, SCREEN_HEIGHT,
                        SDL_WINDOW_RESIZABLE);
	
	if ( window == NULL ) return -1;

	renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);

	if ( renderer == NULL ) return -1;

	// place constants
	struct gpu* p = (struct gpu*) gpu;
	p->const_screen_w = SCREEN_WIDTH;
	p->const_screen_h = SCREEN_HEIGHT;
	p->const_n_slots = N_SLOTS;

	return 0;
}

void system_deinit()
{
	for (int i = 0; i< N_SLOTS; i++) {
		if (textures[i]) SDL_DestroyTexture(textures[i]);
	}
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);

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

int32_t peripheral_write(uint32_t addr, uint32_t value, int n_bytes)
{
	if (addr >= GPU_MIN && addr <= GPU_MAX) {
		switch(addr - GPU_MIN)
		{
			// constants
			case 0x0:
			case 0x2:
			case 0x4:
				return -1; // cant write to constant area

			// functions
			case 0x10:
				return gpu_clear(value);
			case 0x11:
				return gpu_draw(value);
			case 0x12:
				return gpu_update();
			
			// parameters
			default:
				memcpy( gpu + addr - GPU_MIN, &value, n_bytes);
				return 0;
		}
	}
	
	// writing to non writable area
	return -1;
}

int32_t peripheral_read(uint32_t addr, uint32_t *destination, int n_bytes)
{
	if (destination == NULL) return -1;

	if (addr >= GPU_MIN && addr <= GPU_MAX) {
		switch(addr - GPU_MIN)
		{
			// functions
			case 0x10:
			case 0x11:
			case 0x12:
				return -1;
			
			// parameters
			default:
				memcpy(destination, gpu + addr - GPU_MIN, n_bytes);
				return 0;
		}
	}
	else if (1) { // TODO! Change to keyboard
		switch(addr)
		{
			case 0x40010020:
				// readKeyboard(destination);
				return 0;
		}
	}

	return -1;
}
