#include<stdio.h>
#include<stdlib.h>
#include<pthread.h>

#ifdef __aarch64__
#define DEFINE_PREFIX   __attribute__ ((aligned (8)))
#else
#define DEFINE_PREFIX
#endif

DEFINE_PREFIX static int pthread_data=0;

void * pthread1(void *arg)
{
    int i=0;
    i=pthread_data;
    sleep(1);
    printf("run in pthread 1\n");
    return NULL;
}

void * pthread2(void *arg)
{
    int j=0;
    j=pthread_data;
    printf("run in pthread 2\n");
    return NULL;
}
int main(int argc ,char **argv)
{
    int ret=0;
    pthread_t ptid1,ptid2;
    ret=pthread_create(&ptid1,NULL,pthread1,NULL);
    if(ret!=0)
    {
        printf("create pthread error\n");
        return -1;
    }
    ret=pthread_create(&ptid2,NULL,pthread2,NULL);
    if(ret!=0)
    {
        printf("create pthread 2 error\n");
        return -1;
    }
    pthread_join(ptid1,NULL);
    pthread_join(ptid2,NULL);
    printf("main function return\n");
}
