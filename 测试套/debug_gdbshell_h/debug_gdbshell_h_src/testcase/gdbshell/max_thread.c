#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <pthread.h>
#include <sys/stat.h>
#include <fcntl.h>

void *thread_start() 
{
    sleep(1000);
    return NULL;
}

int main (int argc, char** argv)
{
    unsigned long i = 0;
    int ret = 0;
    pthread_t tinfo[1024];
    for (i=0; i<1024; i++){
        ret = pthread_create(&tinfo[i], NULL, &thread_start, NULL);
        if (ret != 0) {
            printf("father process pthread_create %d error: %m\n", i);
            break;
//            exit(1);   
        }  
    }

    int fd;
    fd=open("/tmp/max_thread.log", O_RDWR|O_CREAT);
    if (fd < 0) {
        printf("open fail \n");
        exit(1);
    }
 
    char buf[8];
    memset(buf, 0, 8);
    sprintf(buf,"%d\n", i-1);
    ret = write(fd, buf, sizeof(buf));
    if (ret < 0) {
        printf("write error\n");
        exit(1);
    }

    pid_t pid;
    pid=fork();
    if(pid < 0) {
        printf(" fork error\n");
        exit(1);
    }else if(pid == 0) {
        int x=0;
        while(1){
            x++;
            x--;
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

