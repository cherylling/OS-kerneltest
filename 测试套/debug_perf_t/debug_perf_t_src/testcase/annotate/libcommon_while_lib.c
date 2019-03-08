/*#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: common_while_lib.c
##- @Author: y00197803
##- @Date: 2013-4-17
##- @Precon: 1.支持perf功能
#            2.支持expand,addr2line,objdump
#            3.可执行程序编译带-g选项
##- @Brief: perf annotate基本命令可用1
##- @Detail: to make a library like libcommon_while_lib.so libcommon_while_lib.a
##- @Auto:
##- @Modify:
#######################################################################*/
#include <stdio.h>
#include "libcommon_while_lib.h"

void anno_hotspot1(void)
{
    int i, j;
    for (i=0; i<=100; i++){
        j++;
    }
}
