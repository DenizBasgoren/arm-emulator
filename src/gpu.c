
#include <SDL2/SDL.h>
#include <stdint.h>

#include "emulator.h"
#include "emulib.h"
#include "gpu.h"

#define N_SLOTS			4

static SDL_Texture *textures[ N_SLOTS ]; // arr of 4 ptr to texture
uint8_t gpu[GPU_LEN];

// prototypes
static int gpu_clear(int mode );
static int gpu_draw(int mode );
static int gpu_update();


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
	struct gpu* p = (struct gpu*) &gpu;
	if (p->red > 255 || p->green > 255 || p->blue > 255 || p->alpha > 255) return -1;

	int err;
	err = SDL_SetRenderDrawColor(renderer, p->red, p->green, p->blue, p->alpha); // alpha=255 is opaque
	if (err) return -1;

	if (mode == 0)
	{
		err = SDL_RenderClear(renderer);
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
		
		err = SDL_RenderDrawRect(renderer, &target);
	}
	else {
		err = -1;
	}

	if (err) return err;
	
	SDL_RenderPresent(renderer);
	return 0;
}

static int gpu_draw( int mode ) {
							// 0= no clipping, no resizing
							// 1= no clipping, resize
							// 2= clip, no resizing
							// 3= clip, resize
	struct gpu* p = (struct gpu*) &gpu;
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

	struct gpu* p = (struct gpu*) &gpu;
	if (p->selected_slot >= N_SLOTS) return -1;

	// if there was an old one, remove it first
	SDL_Texture* t = textures[p->selected_slot];
	if ( t ) SDL_DestroyTexture( t );
	t = NULL;

	int channel, bytes_per_pixel;
	if ( p->texture_channel == 3 ) {
		channel = SDL_PIXELFORMAT_RGB24;
		bytes_per_pixel = 3;
	}
	else if ( p -> texture_channel == 4) {
		channel = SDL_PIXELFORMAT_RGBA8888;
		bytes_per_pixel = 4;
	}
	else return -1;

	struct range new = rangeOf(p->texture_data_addr);
	if (!new.exists) return -1;

	int bytes_in_texture = p->texture_w * p->texture_h * bytes_per_pixel;

	// if image is larger than available memory
	if ( new.real + bytes_in_texture -1 > new.real_max) return -1;

	textures[p->selected_slot ] = SDL_CreateTexture(
		renderer,
		channel,
		SDL_TEXTUREACCESS_STATIC,
		p->texture_w,
		p->texture_h );
	
	SDL_UpdateTexture( textures[p->selected_slot],
					NULL,
					new.real,
					p->texture_w * bytes_per_pixel );

	return 0;
}



int gpu_init() {
	// place constants
	struct gpu* p = (struct gpu*) &gpu;
	p->const_screen_w = SCREEN_WIDTH;
	p->const_screen_h = SCREEN_HEIGHT;
	p->const_n_slots = N_SLOTS;
}

int gpu_deinit() {
	for (int i = 0; i< N_SLOTS; i++) {
		if (textures[i]) SDL_DestroyTexture(textures[i]);
	}
}



int32_t gpu_write(uint32_t addr, uint32_t value, int n_bytes) {
	if (addr < GPU_MIN || addr > GPU_MAX) return -1;

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
	}

	return 0;
}

int32_t gpu_read(uint32_t addr, uint32_t *destination, int n_bytes) {
	if (destination == NULL ) return -1;
	if (addr < GPU_MIN || addr > GPU_MAX) return -1;

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
	}
	
	return 0;
}
