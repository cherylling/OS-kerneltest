#include<stdio.h>
#include<pthread.h>
#include<stdlib.h>
static int pthread_data2=2;
#define MAXTHREADS 2000

pthread_mutex_t mutex;

void *func(void *n)
{
    int i;
    pthread_mutex_lock(&mutex);
    i=pthread_data2;
    pthread_mutex_unlock(&mutex);
}

int main(int argc,char **argv)
{
    pthread_t child[MAXTHREADS];
    pthread_mutex_init(&mutex, NULL);
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










