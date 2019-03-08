#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>

int main()
{
    if(!fork())
    {
        printf("child \n");
        exit(0);
    }
    sleep(20);
    exit(0);
}
