#include <stdio.h>
#include <stdlib.h>

int main()
{
    unsigned short test = 0x1122;
    if(*( (unsigned char*) &test ) == 0x11)
       //printf("big endian\n");
       printf("1");
    else
       //printf("little endian\n");
       printf("0");
    return 0;
}
