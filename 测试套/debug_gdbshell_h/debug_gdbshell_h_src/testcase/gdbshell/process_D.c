#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>

int main()
{
    if(!vfork());
    sleep(50);
    exit(0);
}
