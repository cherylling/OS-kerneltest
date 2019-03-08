#include <stdio.h>
#include <stdlib.h>
int gi = 4;
static int *iptr = &gi;

int main()
{
    FILE *file;

    file = fopen("usr_gvar_addr.tmp", "w+");
    fprintf(file, "%p", &iptr);
    fclose(file);
    sleep(2);

    //read first
    printf("pointer value before write: 0x%x\n", iptr);
    //write then
    int i = 2;
    iptr = &i;
    //++(*iptr);
    return 0;
}

