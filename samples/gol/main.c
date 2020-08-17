#define SRC 0x40000030
#define TARGET 0x40000038
#define TXT 0x40000024

#define gpuClear(mod) *(char*)(0x40000010) = mod
#define gpuDraw(mod) *(char*)(0x40000011) = mod
#define gpuUpdate() *(char*)(0x40000012) = 1
#define gpuSlot(n) *(char*)(0x4000002d) = n

#define W 80
#define H 60

#define i8 char
#define i16 short
#define i32 int
#define i64 long long int

i8 slot = 0;

void setColor(i32 color)
{
    i32* c = (void*)(0x40000020);
    *c = color;
}

void setSrc(i16 x, i16 y, i16 w, i16 h)
{
    i16* pos = (void*)SRC;
    pos[0] = x;
    pos[1] = y;
    pos[2] = w;
    pos[3] = h;
}

void setTarget(i16 x, i16 y, i16 w, i16 h)
{
    i16* pos = (void*)TARGET;
    pos[0] = x;
    pos[1] = y;
    pos[2] = w;
    pos[3] = h;
}

void loadTexture(char* data, int w, int h)
{
    i16* wh = (void*)TXT;
    wh[0] = w;
    wh[1] = h;

    i32* addr = (void*)(TXT + 4);
    *addr = (void*)data;
    i8* chn = (void*)(TXT + 8);
    *chn = 4;
    
    gpuUpdate();
}

unsigned int seed = 161600;

int rand()
{    
    seed = seed * 1140671485u + 12820163u;
    return seed;
}

void _start()
{
    int cells[W][H];
    int cells_new[W][H];
    int data[W*H];

    setTarget(0, 0, 800, 600);
    setSrc(0, 0, 80, 60);


    for(int i = 0; i < W; i++)
        for(int j = 0; j < H; j++)
        {
            cells[i][j] = rand() > 0;
            cells_new[i][j] = cells[i][j];
        }

    while(1)
    {
        for(int i = 0; i < W; i++)
            for(int j = 0; j < H; j++)
            {
                cells[i][j] = cells_new[i][j];
                data[j*W+i] = cells[i][j] * 0xFFFFFFFF;
            }

        loadTexture(data, 80, 60);
        gpuDraw(1);
        
        for(int i = 1; i < W-1; i++)
        {
            for(int j = 1; j < H-1; j++)
            {
                int neighbours = cells[i-1][j-1] + cells[i][j-1] + cells[i+1][j-1]
                                +cells[i-1][j] + cells[i+1][j]
                                +cells[i-1][j+1] + cells[i][j+1] + cells[i+1][j+1];
                
                if(cells[i][j] == 1 && (neighbours == 2 || neighbours == 3))
                    cells_new[i][j] = 1;
                else if(cells[i][j] == 0 && neighbours == 3)
                    cells_new[i][j] = 1;
                else
                    cells_new[i][j] = 0;
            }
        }

        for(int i = 0; i < 0x10000; i++);
    }
}