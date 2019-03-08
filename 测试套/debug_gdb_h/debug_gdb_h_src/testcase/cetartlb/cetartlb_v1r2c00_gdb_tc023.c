/*#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename:
##- @Name: 
##- @Author: l00191161
##- @Date: 2013-4-26
##- @Precon: 
##- @Brief: 
##- @Detail:
##- @Expect: 
##- @Level: 
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

#include "cetartlb_mmap_addr.h"
int SIG_FLAG=0;
#ifdef MMAP_64
unsigned long long int offset=0;
#else
off_t offset=0;
#endif
size_t length=0;
int tlb_fd=-1;
char *mmap_addr=NULL;
char *mcpy_str="only for write addr!";
void sig_handler(int sig)
{
    if(SIG_FLAG == 1){ 
        printf("receive the SIGSEGV signal as expected\n");
        exit(0);
    }
    else{ 
        printf("receive the SIGSEGV signal not expected\n");
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
    if(argc != 4){
        printf("%s param error\n", argv[0]);
        printf("usage: %s [/dev/cetatlb16M | /dev/cetatlb2M | /dev/cetatlb1G] ADDR LENGTH\n", argv[0]);
        return 1;
    }

    tlb_fd = open(argv[1], O_RDWR);
    if (tlb_fd < 0){
        printf("open %s O_RDWR error\n", argv[1]);
        return 1;    
    }
    
    #ifdef MMAP_64
     offset=strtoull(argv[2], NULL, 16);
#else
    offset=strtoul(argv[2], NULL, 16);
#endif
    length=strtoul(argv[3], NULL, 16);

    prepare();

    printf("test param for mmap :addr 0x%x, length 0x%x, offset 0x%llx\n", ADDR,length,offset);
#ifdef MMAP_64
    mmap_addr = (char *)mmap64((void *)ADDR, length, PROT_EXEC, MAP_SHARED|MAP_FIXED, tlb_fd, offset);
#else
    mmap_addr = mmap((void *)ADDR, length, PROT_EXEC, MAP_SHARED|MAP_FIXED, tlb_fd, offset);
#endif 
    if (mmap_addr == MAP_FAILED){
        close(tlb_fd);
        printf("mmap fail \n");
        return 1;
    }

    printf("mmap pass \n");
    printf("%c \n",mmap_addr[0]);
    int ret = mprotect(mmap_addr, length, PROT_EXEC);
    if (ret < 0){
        printf("mprotect PROT_EXEC fail unexpected\n");
        close(tlb_fd);
        munmap(mmap_addr, length);
        return 1;
    }

    printf("mprotect PROT_EXEC pass as expected\n");
    printf("%c \n",mmap_addr[0]);
    SIG_FLAG=1;
    memcpy(mmap_addr, mcpy_str, strlen(mcpy_str));
    close(tlb_fd);
    munmap(mmap_addr, length);
    printf("%s should get SIGSEGV\n", argv[0]);
    exit(1);
}
