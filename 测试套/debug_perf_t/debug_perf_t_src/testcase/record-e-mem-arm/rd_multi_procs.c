#include<stdio.h>
#include<pthread.h>
#include<stdlib.h>
static int pthread_data2=2;
#define MAXPROCS 5800

void func()
{
    int i;
    i=pthread_data2;
}

int main(int argc,char **argv)
{
    int status;
    pid_t *pid;
    pthread_t child[MAXPROCS];

    pid = malloc(MAXPROCS * sizeof(pid_t));
    int i;
    for (i=0;i<MAXPROCS;i++)
    {
        pid[i] = fork();
        switch (pid[i])
        {
        case 0:
            func();
            exit(0);
            break;
        case -1:
            printf("failed at %d times\n", i);
            err(1, "fork failed");
            break;
        default:
            break;
        }
    }
    for (i=0;i<MAXPROCS;i++)
    {
        waitpid(pid[i], &status, 0);
        //printf(" status %d\n", status);
    }
    printf("test pass\n");
    return 0;

}










