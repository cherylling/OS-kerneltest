#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <pthread.h>

void *thread_start() 
{
    sleep(30);
    return NULL;
}

int main (int argc, char** argv)
{
    unsigned long i = 0;
    int ret = 0;
    pthread_t tinfo[10];
    for (i=0; i<10; i++){
        ret = pthread_create(&tinfo[i], NULL, &thread_start, NULL);
        if (ret != 0) {
            printf("father process pthread_create %d error: %m\n", i);
            exit(1);
        }  
    }

    pid_t pid;
    pid=fork();
    if(pid < 0) {
        printf(" fork error\n");
        exit(1);
    }else if(pid == 0) {
        sleep(30);
        exit(1);
    } else {
    }
    
    while(i>0) {
         i--; 
        ret = pthread_join(tinfo[i], NULL);
        if (ret != 0) {
             fprintf(stderr, "pthread_join %d error: %m, child thread return value %s\n", i,strerror (ret));
        }
    }

    sleep(10);
    int status;
    waitpid(-1, &status, 0);
    exit(0);
}

