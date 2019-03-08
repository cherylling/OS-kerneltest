#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>

int gi = 4;
static int *iptr = &gi;

int main()
{
    FILE *file;
    FILE *file1;

    file = fopen("usr_gvar_addr.tmp", "w+");
    fprintf(file, "%p", &iptr);
    fclose(file);
    file1 = fopen("step1.tmp", "w+");
    fclose(file1);

    while((access( "step2.tmp", 0 )) == -1)
    {
        sleep(1);
    }
    sleep(2);
    //read first
    printf("pointer value before write: 0x%x\n", iptr);
    //write then
    int i = 2;
    iptr = &i;
    //++(*iptr);
    return 0;
}
