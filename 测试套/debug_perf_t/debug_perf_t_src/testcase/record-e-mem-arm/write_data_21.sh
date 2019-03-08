#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: read_data_14.sh
##- @Author: y00197803
##- @Date: 2013-4-17
##- @Precon: 1.not support -e mem:0x$addr:w8 now
##- @Brief: functions for perf record -e mem test
##- @Detail: 
#######################################################################*/
source ./record-e-mem_common.sh
source ./record-e-mem_common.sh
exit_if_not_support

func=./write_data_21
variable=write_data2
addr=`readelf $func -a|grep $variable|awk '{print $2}'`
echo 0x$addr

perf record -e mem:0x$addr:w8 -f $func 1
perf report|grep memval
if [ $? -ne 0 ];then
    {
        echo test fail
        exit 1
    }
else
    {
        echo test pass
        exit 0
    }
fi
