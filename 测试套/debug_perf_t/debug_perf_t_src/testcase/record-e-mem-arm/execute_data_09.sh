#!/bin/bash
func=./execute_data_09
variable=write_data
addr=`readelf $func -a|grep $variable|awk '{print $2}'`
echo 0x$addr

perf record -e mem:0x$addr:x -f $func 1
perf report|grep memval
if [ $? -eq 0 ];then
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
