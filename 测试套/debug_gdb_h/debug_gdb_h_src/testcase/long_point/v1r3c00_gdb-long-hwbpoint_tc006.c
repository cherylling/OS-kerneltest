/*#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2014, Huawei Tech. Co., Ltd.
##- @Suitename: 
##- @Name: 
##- @Author: 
##- @Date: 
##- @Precon: 
##- @Brief:
##- @Detail: 
##- @Expect: 
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

int dev_fd=-1;

char *addr=NULL;
unsigned long vm_addr=0x40000000;
unsigned long length;

int SIG_FLAG=0;
void sig_handler(int sig)
{
    if(SIG_FLAG == 1){ 
        printf("receive the SIGSEGV signal as expected\n");
        exit(0);
    }
    else{ 
        printf("receive the SIGSEGV signal not expected\n");
        munmap(addr, length);
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
    if (argc != 2) {
        printf("usage: %s length\n", argv[0]);
        return 1;
    }
    prepare();

    length=strtoul(argv[1], NULL, 16);

    addr = (char *)mmap((void *)vm_addr, length, PROT_READ|PROT_WRITE, MAP_SHARED|MAP_ANONYMOUS|MAP_FIXED, -1, 0);
    if (addr == MAP_FAILED){
        printf("mmap fail %m \n");
        return 1;
    }
    printf("mmap pass \n");
    
    memset(addr, '0', length);
    addr[length-1]=0;
    addr[2]='c';
    addr[length/3*2-2]='a';
    printf("%c\n",addr[length/3*2+3]);
    addr[length/6*5-1]='b';
    addr[length/6*5]='b';
    addr[length/6*5+1]='b';

    printf("set value pass \n");

    char *err_str="dafaga";
    SIG_FLAG=1;

    err_str[1]='x';

    munmap(addr, length);
    printf("%s should get SIGSEGV \n", argv[0]);
    return 1;
}
