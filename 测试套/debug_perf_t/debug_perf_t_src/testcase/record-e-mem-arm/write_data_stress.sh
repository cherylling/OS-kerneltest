#!/bin/bash
func=./write_data_stress
variable=write_char3
addr=`readelf $func -a | grep $variable | awk '{print $2}'`
echo 0x$addr

perf record -e mem:0x$addr:w1 -f $func 1
num=`perf report | grep memval | wc -l`
if [ $num -ne 10000 ];then
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
