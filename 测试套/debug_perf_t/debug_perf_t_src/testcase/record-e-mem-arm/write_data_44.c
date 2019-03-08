#include<stdio.h>
#include<stdlib.h>
#include<pthread.h>
#include <unistd.h>
#include <fcntl.h>

static int pthread_data=0;

void * pthread1(void *arg)
{
    int i=0;
    pthread_data=3;
    sleep(1);
    printf("run in pthread 1\n");
    return NULL;
}

void * pthread2(void *arg)
{
    int j=0;
    pthread_data=5;
    printf("run in pthread 2\n");
    return NULL;
}
int main(int argc ,char **argv)
{
    int ret=0;
    pthread_t ptid1,ptid2;
    FILE *file;
    FILE *file1;

    file = fopen("usr_gvar_addr.tmp", "w+");
    fprintf(file, "%p", &pthread_data);
    fclose(file);
    file1 = fopen("step1.tmp", "w+");
    fclose(file1);

    while((access( "step2.tmp", 0 )) == -1)
    {
        sleep(1);
    }
    sleep(2);

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
