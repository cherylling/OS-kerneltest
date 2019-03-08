#include<stdio.h>
#include<pthread.h>
#include<stdlib.h>
static int pthread_data1=1;
static int pthread_data2=0xff000000;
static char pthread_char3=0x1;
static char pthread_char4=0x1;
static char pthread_char5=5;
static char pthread_char6=6;
static char *pthread_p="hello world";
pthread_mutex_t mutex_p;

void *func_pthread_1(void *n)
{
    int i=0,j;
    char k=0;
    j=*((int*)n);
    pthread_mutex_lock(&mutex_p);
    for(i=1;i<=j;i++)
        pthread_data1=pthread_data1+i;
    pthread_mutex_unlock(&mutex_p);
    i=pthread_data2;
    k=pthread_char3;
}

void *func_pthread_2(void *n)
{
    int i=0;
    char k=0;
    int j=*((int*)n);
    pthread_mutex_lock(&mutex_p);
    for(i=1;i<=j;i++)
    {
        pthread_data1=pthread_data1+i;
    }
    pthread_mutex_unlock(&mutex_p);
    i=pthread_data2;
    k=pthread_char3;
}

int main(int argc,char **argv)
{
    int pth_arg_1,pth_arg_2,total,ret;
    pthread_t ptd1,ptd2;
    if(argc!=3)
    {
        printf("please input three params\n");
        return -1;
    }
    pth_arg_1=atoi(argv[1]);
    pth_arg_2=atoi(argv[2]);

    total=pth_arg_1*(1+pth_arg_1)/2+pth_arg_2*(1+pth_arg_2)/2+1;

    pthread_mutex_init(&mutex_p,NULL);
    ret=pthread_create(&ptd1,NULL,func_pthread_1,&pth_arg_1);
    if(ret<0)
    {
        printf("create pthread 1 error\n");
        exit(1);
    }
    ret= pthread_create(&ptd2,NULL,func_pthread_2,&pth_arg_2);
    if(ret<0)
    {
        printf("create pthread 2 error\n");
        exit(1);
    }
    pthread_join(ptd1,NULL);
    pthread_join(ptd2,NULL);
    printf("the total is %d\n",total);
    printf("the pthread_data1 is %d\n",pthread_data1);
    if(total!=pthread_data1)
    {
        printf("mutex fail\n");
        return -1;
    }
    printf("test pass\n");
    return 0;

}










