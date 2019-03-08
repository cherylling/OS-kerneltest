#include<stdio.h>
#include<pthread.h>
#include<stdlib.h>
int gi = 4;
static int *iptr = &gi;
#define MAXTHREADS 2000

void *func(void *n)
{
    printf("pointer value is 0x%x\n", iptr);
}

int main(int argc,char **argv)
{
    pthread_t child[MAXTHREADS];

    int i, ret;
    for (i=0;i<MAXTHREADS;i++)
    {
        ret = pthread_create(&child[i], NULL, func, NULL);
        if (ret != 0)
        {
            printf("pthread_create failed at %d times\n", i);
            exit(1);
        }
    }
    for (i=0;i<MAXTHREADS;i++)
    {
        ret = pthread_join(child[i], NULL);
    }
    printf("test pass\n");
    return 0;

}










