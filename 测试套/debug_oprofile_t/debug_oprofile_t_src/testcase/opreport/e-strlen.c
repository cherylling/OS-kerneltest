#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

int err = 0;

int main(int argc, char *argv[])
{
    int i;
    for(i = 0; i < 3; i++) {
        printf("strlen = %u\n", (unsigned)strlen("hello"));
        sleep(1);
    }

    if(!err) {
        printf("test pass!\n");
    }
    else {
        printf("test fail!\n");
    }
    return 0;
}
