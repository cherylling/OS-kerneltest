#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <pthread.h>

static void *thread_fd() 
{
    if(!vfork());
    sleep(1000);
    exit(0);
}

static void *thread_start() 
{
    sleep(1000);
    exit(0);
}

int main (int argc, char** argv)
{
    unsigned long i = 0;
    int ret = 0;
    pthread_t tinfo[10];
    for (i=0; i<10; i++){
        if(i!=9) {
            ret = pthread_create(&tinfo[i], NULL, &thread_start, NULL);
            if (ret != 0) {
                printf("father process pthread_create %d error: %m\n", i);
                exit(1);
            }  
        } else {
            ret = pthread_create(&tinfo[i], NULL, &thread_fd, NULL);
            if (ret != 0) {
                printf("father process pthread_create %d error: %m\n", i);
                exit(1);
            }  
        }
    }

     void *res;
     while(i>0) {
         i--; 
         ret = pthread_join(tinfo[i], &res);
        if (ret != 0) {
            printf("pthread_join %d error: %m, child thread return value %s\n", i,(char *)res);
        } else {
            if(strcmp((char *)res, "0") != 0){
                printf("pthread_join %d pass, but child thread return value error :%s\n", i,(char *)res);
            } else {
                printf("pthread_join %d pass, child thread return value PASS\n", i);
            }
        }
    }
    exit(0);
}

