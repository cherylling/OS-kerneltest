#!/bin/bash
func=./write_data_42
variable=write_data2
addr=`readelf $func -a|grep $variable|awk '{print $2}'`
echo 0x$addr

perf record -e mem:0x$addr:w -k "s:=4||=5" -f $func 1

ret=`perf report|grep memval|wc -l`
if [ $ret -ne 2 ];then
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
