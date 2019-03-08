#include<stdio.h>
#include<stdlib.h>
#include<unistd.h>

#ifdef __aarch64__
#define DEFINE_PREFIX   __attribute__ ((aligned (8)))
#else
#define DEFINE_PREFIX
#endif

DEFINE_PREFIX static int fork_data=1;

int main(int argc,char **argv)
{
    pid_t pid=0;
    FILE *file;

    file = fopen("usr_gvar_addr.tmp", "w+");
    fprintf(file, "%p", &fork_data);
    fclose(file);
    sleep(2);

    pid=fork();
    if(pid==0)
    {
        sleep(1);
        printf("child fork_data addr is %p\n",&fork_data);
        printf("child process return\n");
        return 0;
    }
    else if(pid>0)
    {
        sleep(2);
        fork_data=1;
        printf("parent fork_data addr is %p\n",&fork_data);
        printf("parent process return\n");
        return 0;
    }

}

