/*#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: common_realtime_2.c
##- @Author: y00197803
##- @Date: 2013-4-17
##- @Precon: 
##- @Brief: 
##- @Detail: 起一个尽可能低优先级的实时进程，供perf测试使用
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
#include <sys/wait.h>

int main()
{
    int rc, child, status;
    struct sched_param my_params;

    my_params.sched_priority = sched_get_priority_min(SCHED_FIFO);// 尽可能高的实时优先级
    rc = sched_setscheduler(0,SCHED_FIFO,&my_params);
    if(rc<0)
    {
        perror("sched_setscheduler to SCHED_FIFO error");
        exit(1);
    }
    while(1){
        child = fork();
        switch (child){
            case 0:
                rc=1;
                exit(0);
            case -1:
                printf("fork a chile error");
                break;
            default:
                waitpid(child, &status, 0);
        }
        sleep(10);
    }
    return 0;
}
