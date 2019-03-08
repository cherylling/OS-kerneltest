/*#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2014, Huawei Tech. Co., Ltd.
##- @Suitename: 
##- @Name: 
##- @Author: 
##- @Date: 2014-3-13
##- @Precon:
##- @Brief: 
##- @Detail:
##- @Expect:
#            
##- @Level: Level 1
##- @Auto: True
##- @Modify:
#######################################################################*/
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <signal.h>
#include <string.h>
#include <unistd.h>

#ifdef MMAP_64
unsigned long long int offset=0;
#else
off_t offset=0;
#endif

size_t length=0;

int dev_fd=-1;

char *mmap_addr=NULL;

unsigned long vm_addr=0x40000000;

int SIG_FLAG=0;
void sig_handler(int sig)
{
    if(SIG_FLAG == 1){ 
        printf("receive the SIGSEGV signal as expected\n");
        exit(0);
    }
    else{ 
        printf("receive the SIGSEGV signal not expected\n");
        close(dev_fd);
        munmap(mmap_addr, length);
        exit(1);
    } 
}

void prepare()
{
    if (signal(SIGSEGV, sig_handler) == SIG_ERR)
    {
        printf("signal fail to catch signal\n");
        exit(1);
    }
}


int main(int argc, char **argv)
{
    if(argc != 3){
        printf("%s param error\n", argv[0]);
        printf("usage: %s length offset\n", argv[0]);
        return 1;
    }

    prepare();
    dev_fd = open("/dev/mem", O_RDWR);
    if (dev_fd < 0){
        printf("open /dev/mem O_RDWR error\n");
        return 1;    
    }
    
#ifdef MMAP_64
    offset=strtoull(argv[2], NULL, 16);
#else
    offset=strtoul(argv[2], NULL, 16);
#endif
    length=strtoul(argv[1], NULL, 16);

#ifdef MMAP_64
    mmap_addr = (char *)mmap64((void *)vm_addr, length, PROT_READ|PROT_WRITE, MAP_SHARED|MAP_FIXED, dev_fd, offset);
#else
    mmap_addr = mmap((void *)vm_addr, length, PROT_READ|PROT_WRITE, MAP_SHARED|MAP_FIXED, dev_fd, offset);
#endif
    if (mmap_addr == MAP_FAILED){
        close(dev_fd);
        printf("mmap fail %m \n");
        return 1;
    }
    printf("mmap pass \n");

    memset(mmap_addr, '1', length);

    size_t i=0;
    for(i=0; i<length; i++) {
        if(i%(length/10) == 0) 
            mmap_addr[i]='a';
    }

    for(i=0; i<0x100; i++) {
        if(i%5 == 0) {
            mmap_addr[i]='c';
        }
        if(i%0x10 == 0) {
            printf("%c\n",mmap_addr[i]);
        }
    }

    int ret = mprotect(mmap_addr, length, PROT_READ);
    if (ret < 0){
        printf("mprotect PROT_READ fail unexpected\n");
        close(dev_fd);
        munmap(mmap_addr, length);
        return 1;
    }
    printf("mprotect PROT_READ pass as expected\n");

    mmap_addr[length-4]=0;
    SIG_FLAG=1;

    close(dev_fd);
    munmap(mmap_addr, length);
    printf("%s should get SIGSEGV \n", argv[0]);
    exit(1);
}
