/*********************************************************************
 @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
 @File name: opt_perf_t_test.c
 @Author1:star<yexinxin@huawei.com> ID:00197803
 @Date: 2013-04-16
 @Description: write your functions here, will be compiled to
     libopt_perf_t_test.a
**********************************************************************/

/*********************************************************************
 include files, definitions, global variates here
**********************************************************************/
#include <stdio.h>
#define __USE_GNU
#include <sched.h>
#include "opt_perf_t_test.h"

/*********************************************************************
 Description: 
**********************************************************************/
int set_cpu (int cpu)
{
    cpu_set_t             mask;

    CPU_ZERO (&mask);
    CPU_SET (cpu, &mask);

    if (-1 == sched_setaffinity (0, sizeof (mask), &mask))
    {
        printf ("Fail : could not set CPU affinity, continuing...\n");
        return 1;
    }
    else
        return 0;
}
