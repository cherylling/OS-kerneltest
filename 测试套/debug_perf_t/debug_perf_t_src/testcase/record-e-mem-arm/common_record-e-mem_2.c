/*######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: common_record-e-mem_2.c
##- @Author: y00197803
##- @Date: 2013-5-10
##- @Brief: 
##- @Detail: 提供数据断点被监控的程序，构造各种场景
##- @Modify:
#######################################################################*/
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <unistd.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <string.h>

#define TMPFILE "get_addr.sh"
#define MMAPFILE "mmap.tmp"
#define POS 1
#define NEG -1
#define ZERO 0
#define INT_SIZE 4

#ifndef SEEK_SET
#define SEEK_SET 0
#endif

#ifndef __GNUC__
    #define __attribute__(x) /* NOTHING */
#endif

FILE *fp = NULL;
int mode = 0;
int *stack_pos_num = NULL, *stack_neg_num = NULL, *stack_zero_num = NULL;
int *heap_pos_num = NULL, *heap_neg_num = NULL, *heap_zero_num = NULL;
int *mmap_pos_num = NULL, *mmap_neg_num = NULL, *mmap_zero_num = NULL, *xxxx = NULL;

void func_on_stack()
{
    int doread __attribute__((unused));

    fprintf(fp, "addr_pos=%p\n", stack_pos_num);
    fprintf(fp, "addr_neg=%p\n", stack_neg_num);
    fprintf(fp, "addr_zero=%p\n", stack_zero_num);

    *stack_pos_num = POS;
    *stack_neg_num = NEG;
    *stack_zero_num = ZERO;
    doread = *stack_pos_num;
    doread = *stack_neg_num;
    doread = *stack_zero_num;
}

void func_on_heap()
{
    int doread __attribute__((unused));

    fprintf(fp, "addr_pos=%p\n", heap_pos_num);
    fprintf(fp, "addr_neg=%p\n", heap_neg_num);
    fprintf(fp, "addr_zero=%p\n", heap_zero_num);

    *heap_pos_num = POS;
    *heap_neg_num = NEG;
    *heap_zero_num = ZERO;
    doread = *heap_pos_num;
    doread = *heap_neg_num;
    doread = *heap_zero_num;
}

void func_on_mmap()
{
    int doread __attribute__((unused));

    fprintf(fp, "addr_pos=%p\n", mmap_pos_num);
    fprintf(fp, "addr_neg=%p\n", mmap_neg_num);
    fprintf(fp, "addr_zero=%p\n", mmap_zero_num);

    *mmap_pos_num = POS;
    *mmap_neg_num = NEG;
    *mmap_zero_num = ZERO;
    doread = *mmap_pos_num;
    doread = *mmap_neg_num;
    doread = *mmap_zero_num;
}

void sig_handler(int signal)
{
    if (signal == SIGUSR1){
        fp = fopen(TMPFILE, "w");
        if (fp < 0){
            printf("TFAIL: cannot open file!\n");
            exit(0);
        }

        switch (mode){
            case 1:
                func_on_stack();
                break;
            case 2:
                func_on_heap();
                break;
            case 3:
                func_on_mmap();
                break;
            default:
                break;
        }
        fclose(fp);
    }
}

int mmap_get_file_ready(char* path)
{
    int fd;
    fd = open(path, O_CREAT|O_RDWR);
    if(fd < 0){
        printf("TFAIL: cannot open file!\n");
        exit(0);
    }
    if (lseek(fd, INT_SIZE, SEEK_SET) != INT_SIZE){
        close(fd);
        printf("TFAIL: lseek error!\n");
        exit(0);
    }
    if (write(fd, "\0", 1) != 1) {
        close(fd);
        printf("TFAIL: write error!\n");
        exit(0);
    }
    return fd;
}
int main(int argc, char**argv)
{
    int pos_num, neg_num, zero_num;

    stack_pos_num = &pos_num;
    stack_neg_num = &neg_num;
    stack_zero_num = &zero_num;

    signal(SIGUSR1, sig_handler);

    mode = atoi(argv[1]);

    /*for malloc (on heap)*/
    heap_pos_num = (int *)malloc(INT_SIZE);
    heap_neg_num = (int *)malloc(INT_SIZE);
    heap_zero_num = (int *)malloc(INT_SIZE);

    /*for mmap*/
    int fd;
    fd = mmap_get_file_ready(MMAPFILE);
    mmap_pos_num = mmap(0, INT_SIZE, PROT_READ|PROT_WRITE, MAP_PRIVATE, fd, 0);
    mmap_neg_num = mmap(0, INT_SIZE, PROT_READ|PROT_WRITE, MAP_PRIVATE, fd, 0);
    mmap_zero_num = mmap(0, INT_SIZE, PROT_READ|PROT_WRITE, MAP_PRIVATE, fd, 0);
    close(fd);

    while(1){
        sleep(2);
    }

    return 0;
}
