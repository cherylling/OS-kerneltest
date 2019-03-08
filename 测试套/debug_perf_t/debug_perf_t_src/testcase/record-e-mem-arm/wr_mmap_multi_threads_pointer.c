#include<stdio.h>
#include<pthread.h>
#include<stdlib.h>
#include <sys/mman.h>
#include <inttypes.h>
#include <unistd.h>
#include <err.h>
#include <errno.h>
#include <string.h>

#include <sys/param.h>
#include <sys/mount.h>

#include <fcntl.h>
#include <unistd.h>
#include <sys/stat.h>


int gi = 4;
static int *iptr = &gi;
#define MAXTHREADS 2000

void *func(void *n)
{
    int fd;
    int *ret;
    char name[MAXPATHLEN] = "mmap.XXXXXX";
    if ((fd = mkstemp(name)) == -1)
       err(1, "mkstemp %s", name);

    if ((ret = mmap(NULL, 512, PROT_READ | PROT_WRITE, MAP_PRIVATE, fd, 0)) == MAP_FAILED)
        err(1, "mmap failed", name);

    iptr = ret;

    if (close(fd) == -1)
       err(1, "close %d (%s)", fd, name);
    munmap(ret, 512);
    if (unlink(name) == -1)
       err(1, "unlink %s", name);
}

int main(int argc,char **argv)
{
    pthread_t child[MAXTHREADS];

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










