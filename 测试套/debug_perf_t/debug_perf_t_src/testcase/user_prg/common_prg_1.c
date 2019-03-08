/*#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: common_prg_1
##- @Author: y00197803
##- @Date: 2013-4-17
##- @Precon: 
##- @Brief: 
##- @Detail: 1. do fork and print
#            
##- @Expect: 
##- @Level:
##- @Auto:
##- @Modify:
#######################################################################*/
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
int main()
{
    int pid, status, i;
    pid = fork();
    switch(pid){
        case 0:
            printf("TINFO : I'm child\n");
            for (i=0;i <=100000000; i++){
            }
            exit(0);
        case -1:
            printf("TFAIL : should not go here\n");
            break;
        default:
            wait(&status);
            printf("TINFO : I'm parent\n");
            break;
    }
    return 0;
}
