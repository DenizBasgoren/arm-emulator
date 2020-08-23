
#include <stdio.h>
#include <string.h>
#include <stdint.h>

#include "emulator.h"
#include "emulib.h"
#include "gpu.h"
#include "nvic.h"

SDL_Window *window;
SDL_Renderer *renderer;

// static void readKeyboard(uint32_t *value);


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
                        SDL_WINDOWPOS_CENTERED, // position
                        SDL_WINDOWPOS_CENTERED,
                        SCREEN_WIDTH, SCREEN_HEIGHT,
                        SDL_WINDOW_RESIZABLE);
	
	if ( window == NULL ) return -1;

	renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);

	if ( renderer == NULL ) return -1;

	// peripherals
	gpu_init();
	nvic_init();

	return 0;
}

void system_deinit()
{
	// peripherals
	gpu_deinit();
	nvic_deinit();

    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);

	SDL_Quit();
}


int32_t load_program(char *rom_path, char *ram_path, uint8_t *rom, uint8_t *ram) {
	FILE *infile;
	uint32_t len;
	char cmd[512];

	if (rom == NULL || ram == NULL) return -1;

	// load text to rom
	infile = fopen(rom_path, "rb");
	fseek(infile, 0, SEEK_END);
	len = ftell(infile);
	fseek(infile, 0, SEEK_SET);

	if (fread(rom, 1, len, infile) != len)
	{
		fclose(infile);
		return -1;
	}
	fclose(infile);


	// load data to ram
	infile = fopen(ram_path, "rb");
	fseek(infile, 0, SEEK_END);
	len = ftell(infile);
	fseek(infile, 0, SEEK_SET);

	if (fread(ram, 1, len, infile) != len)
	{
		fclose(infile);
		return -1;
	}
	fclose(infile);

	printf("Loaded successfully!\n");
	return 0;
}
