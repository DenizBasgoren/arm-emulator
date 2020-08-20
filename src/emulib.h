
#ifndef _EMULIB_H_
#define _EMULIB_H_

#include <SDL2/SDL.h>
#include <stdint.h>

int32_t load_program(char *rom_path, char *ram_path, uint8_t *rom, uint8_t *ram);

int32_t system_init();

void system_deinit();

extern SDL_Window *window;
extern SDL_Renderer *renderer;

#define WINDOW_NAME		"Puhu OS"
#define SCREEN_WIDTH	800
#define SCREEN_HEIGHT	600


#endif