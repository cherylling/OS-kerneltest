#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>

int main()
{
    int i = 0;
    for(i=0; i<5; i++)
        sleep(1);
    return 0;
}
