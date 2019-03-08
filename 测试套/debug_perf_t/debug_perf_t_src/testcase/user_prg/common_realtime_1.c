/*#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: common_realtime_1.c
##- @Author: y00197803
##- @Date: 2013-4-17
##- @Precon: 
##- @Brief: 
##- @Detail: 起一个尽可能高优先级的实时进程，供perf测试使用
#            
##- @Expect: 
##- @Level:
##- @Auto:
##- @Modify:
#######################################################################*/

/*********************************************************************
include files, definitions, global variates here
*********************************************************************/
#include <sched.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "opt_perf_t_test.h"

#define TMPFILE "common_realtime_1.tmp"
int main()
{
    int rc;
    struct sched_param my_params;
    FILE *fp;
    int *addr = NULL;

    my_params.sched_priority = sched_get_priority_max(SCHED_FIFO);// 尽可能高的实时优先级
    rc = sched_setscheduler(0,SCHED_FIFO,&my_params);
    if(rc < 0)
    {
        perror("sched_setscheduler to SCHED_FIFO error");
        exit(1);
    }
    while(1){
        fp = fopen(TMPFILE, "w");
        if (fp < 0){
            printf("cannot open file!\n");
            continue;
        }
        fwrite("123", 3, 1, fp);
        fflush(fp);
        fclose(fp);
        unlink(TMPFILE);

        addr = (int *)malloc(BUFFER);
        memset(addr, '1', BUFFER);
        SAFE_FREE(addr)
    };
    return 0;
}
