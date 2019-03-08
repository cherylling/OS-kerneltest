#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <pthread.h>

void ninth_floor_func()
{
    sleep(1000);
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

static void *thread_f9() 
{
    first_floor_func();
    exit(0);
}

static void *thread_fz() 
{
    pid_t subpid;
    subpid=fork();
    if(subpid < 0) {
        printf("fz fork error\n");
        exit(1);
    }else if(subpid == 0) {
        exit(1);
    }else {
    }
    sleep(1000);
    exit(0);
}

static void *thread_ft() 
{
    int a;
    scanf("please input a num:%d", &a);
    printf("you input num is %d\n", a);
    exit(0);
}

static void *thread_fd() 
{
    if(!vfork());
    sleep(1000);
    exit(0);
}

static void *thread_fr() 
{
    int f1=0;
    while(1) {
        f1++;
        f1--;
    }
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
        switch(i) {
        case 0:
        case 2:
        case 4:
        case 6:
        case 8:
            ret = pthread_create(&tinfo[i], NULL, &thread_start, NULL);
            if (ret != 0) {
                printf("father process pthread_create %d error: %m\n", i);
                exit(1);
            }  
            break;
        case 1:
            ret = pthread_create(&tinfo[i], NULL, &thread_fr, NULL);
            if (ret != 0) {
                printf("father process pthread_create %d error: %m\n", i);
                exit(1);
            }  
            break;
        case 3:
            ret = pthread_create(&tinfo[i], NULL, &thread_fd, NULL);
            if (ret != 0) {
                printf("father process pthread_create %d error: %m\n", i);
                exit(1);
            }  
            break;
        case 5:
            ret = pthread_create(&tinfo[i], NULL, &thread_ft, NULL);
            if (ret != 0) {
                printf("father process pthread_create %d error: %m\n", i);
                exit(1);
            }  
            break;
        case 7:
            ret = pthread_create(&tinfo[i], NULL, &thread_fz, NULL);
            if (ret != 0) {
                printf("father process pthread_create %d error: %m\n", i);
                exit(1);
            }  
            break;
        case 9:
            ret = pthread_create(&tinfo[i], NULL, &thread_f9, NULL);
            if (ret != 0) {
                printf("father process pthread_create %d error: %m\n", i);
                exit(1);
            }  
            break;
        default:
            break;
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

