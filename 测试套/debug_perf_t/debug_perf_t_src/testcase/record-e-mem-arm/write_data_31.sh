#!/bin/bash
func=./write_data_31
variable=write_data2
addr=`readelf $func -a|grep $variable|awk '{print $2}'`
echo 0x$addr

perf record -e mem:0x$addr:w -k "=5" -f $func 1
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
