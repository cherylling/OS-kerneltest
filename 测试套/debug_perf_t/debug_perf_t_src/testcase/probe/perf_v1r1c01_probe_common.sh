#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: perf_v1r1c01_probe_common.sh
##- @Author: y00197803
##- @Date: 2013-4-17
##- @Precon: 
##- @Brief: functions for perf probe test
##- @Detail: 
#######################################################################*/

######################################################################
##- @Description: readonly filesystem 
#                 perf probe -m xxx $function will fail 
#		
#                 should:perf probe -m $path $function
######################################################################
should_readonly()
{
    echo "test" > /root/test_readonly-$$.tmp >/dev/null 2>&1
    [ $? -eq 0 ] && echo "TFAIL: /root/ can be write" && \
    rm -f /root/test_readonly-$$.tmp && exit 1
    return 0
}
