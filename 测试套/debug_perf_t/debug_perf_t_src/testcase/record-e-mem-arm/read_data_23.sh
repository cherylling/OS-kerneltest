#!/bin/bash
func=./read_data_23
variable=read_data2
addr=`readelf $func -a|grep $variable|awk '{print $2}'`
echo 0x$addr

perf record -e mem:0x$addr:r -k "<2" -f $func 1
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

