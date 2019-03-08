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
    int r_data;
    pid=fork();
    if(pid==0)
    {
        sleep(1);
        fork_data=2;
        r_data=fork_data;
        printf("child process return\n");
        return 0;
    }
    else if(pid>0)
    {
        sleep(2);
        r_data=fork_data;
        printf("parent process return\n");
        return 0;
    }

}

