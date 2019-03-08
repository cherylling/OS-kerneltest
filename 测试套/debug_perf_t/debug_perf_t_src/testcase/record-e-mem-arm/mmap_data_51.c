#include<stdio.h>
#include<stdlib.h>
#include<sys/mman.h>
#include<string.h>
#include<sys/types.h>
#include<sys/stat.h>
#include<fcntl.h>

int main(int argc,char **argv)
{
    int fd=0;
    char *p=NULL;
    fd=open("/tmp/test.data",O_CREAT|O_RDWR);
    if(fd<0)
    {
        printf("open file error\n");
        return -1;
    }
    p=mmap((void*)3221225422,40,PROT_READ|PROT_WRITE,MAP_SHARED,fd,0);
    printf("the file mmap addr p is %p\n",p);
    sleep(40);
    close(fd);
    printf("before\n");
    *(p+2)='$';
    printf("hello\n");
    char i=*(p+5)  ;
    printf("%d\n",i);
    return 0;
}
