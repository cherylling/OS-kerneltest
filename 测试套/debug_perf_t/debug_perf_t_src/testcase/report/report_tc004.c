/*######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: report_tc004.c
##- @Author: y00197803
##- @Date: 2013-4-17
##- @Precon: 1.支持perf功能
##- @Brief: perf report --symfs
##- @Detail: 1.编写一个进程test，进程中有函数func
#            2.perf record ./test
#            3.perf report --symfs=/tmp > log1
#            4.perf report --symfs=. > log2，其中.目录下必须按照编译时的结构存有可执行程序
##- @Expect: log1中无法找到符号，log2中可以找到符号
##- @Level: Level 1
##- @Auto:
##- @Modify:
#######################################################################*/
#include <stdio.h>

static int s_cnt1, s_cnt2;

void hotspot_2(){
    int i;
    for(i = 0; i<=100; i++){
        s_cnt2++;
    }
}

void hotspot_1(){
    int i;
    while(1){
        hotspot_2();
        for(i = 0; i<=100; i++){
            s_cnt1++;
        }
    }
}
int main()
{
    hotspot_1();
    printf("report_tc004: s_cnt1=%d, s_cnt2=%d\n", s_cnt1, s_cnt2);
    return 0;
}
