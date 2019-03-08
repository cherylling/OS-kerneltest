#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <pthread.h>

#include <sys/sysinfo.h>

unsigned long alloc_size=0;

 static void *thread_start() 
{
    char *addr;
    addr = (char *)malloc(alloc_size);
    if(addr == NULL)
    {
        printf("malloc error\n");
        exit(1); //memleak
    }
    sleep(5);
    memset(addr, 0, alloc_size);
    sleep(120);
    free(addr);
    exit(0);
}

int main (int argc, char** argv)
{
    struct sysinfo *sys_buf;
    sys_buf = (struct sysinfo *)malloc(sizeof(struct sysinfo));
    int ret = sysinfo(sys_buf);
    if(ret != 0){
        printf("information on overall system statistics fail \n");
        return 1;
    }

    char *heap_size;

    long long malloc_size = sys_buf->freeram * sys_buf->mem_unit ;

    alloc_size=malloc_size/10;
    unsigned long i = 0;

    int threads_num=5;
    pthread_t tinfo[5];
    for (i=0; i<threads_num; i++){
        ret = pthread_create(&tinfo[i], NULL, &thread_start, NULL);
        if (ret != 0) {
            printf("pthread_create %d error: %m\n", i);
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

