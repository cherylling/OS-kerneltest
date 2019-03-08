#!/bin/bash
func=./write_data_16
variable=write_char3
addr=`readelf $func -a|grep $variable|awk '{print $2}'`
echo 0x$addr

perf record -e mem:0x$addr:w1 -f $func 1
perf report |grep memval
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
