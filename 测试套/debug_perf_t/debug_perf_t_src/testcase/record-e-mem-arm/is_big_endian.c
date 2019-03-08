#include <stdio.h>
#include <stdlib.h>

int main()
{
    unsigned short test = 0x1122;
    if(*( (unsigned char*) &test ) == 0x11)
       //printf("big endian\n");
       return 0;
    else
       //printf("little endian\n");
       return 1;
}
