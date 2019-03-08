#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <pthread.h>

void ninth_floor_func()
{
    int f=0;
    while(1) {
        f++;
        f--;
    }
    return ;
}

void eighth_floor_func()
{
    ninth_floor_func();
    return ;
}
void seventh_floor_func()
{
    eighth_floor_func();
    return ;
}
void sixth_floor_func()
{
    seventh_floor_func();
    return ;
}
void fifthly_floor_func()
{
    sixth_floor_func();
    return ;
}
void fourthly_floor_func()
{
    fifthly_floor_func();
    return ;
}
void third_floor_func()
{
    fourthly_floor_func();
    return ;
}

void second_floor_func()
{
    third_floor_func();
    return ;
}

int first_floor_func()
{
    second_floor_func();
    return 0;
}

void *thread_f9() 
{
    first_floor_func();
    return NULL;
}

void *thread_start() 
{
    int s=0;
    while(1) {
        s++;
        s--;
    }
    return NULL;
}

int main (int argc, char** argv)
{
    unsigned long i = 0;
    int ret = 0;
    pthread_t tinfo[10];
    for (i=0; i<2; i++){
        if(i!=1){
            ret = pthread_create(&tinfo[i], NULL, &thread_start, NULL);
            if (ret != 0) {
                printf("father process pthread_create %d error: %m\n", i);
                exit(1);
            }  
            sleep(1);
        }else {
            ret = pthread_create(&tinfo[i], NULL, &thread_f9, NULL);
            if (ret != 0) {
                printf("father process pthread_create %d error: %m\n", i);
                exit(1);
            }  
        }

    }

    pid_t pid;
    pid=fork();
    if(pid < 0) {
        printf(" fork error\n");
        exit(1);
    }else if(pid == 0) {
        int y=0;
        while(1) {
            y++;
            y--;
        }
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

    sleep(1000);
    int status;
    waitpid(-1, &status, 0);
    exit(0);
}

