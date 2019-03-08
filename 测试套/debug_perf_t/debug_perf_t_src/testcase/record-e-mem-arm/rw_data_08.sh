#!/bin/bash
func=./rw_data_08
variable=write_test_1
addr=`readelf $func -a|grep $variable|awk '{print $2}'`
echo 0x$addr

perf record -e mem:0x$addr:x -f $func 1
perf report|grep memval
if [ $? -ne 0 ];then
    {
        echo "test fail"
        exit 1
    }
else
    {
        echo test pass
        exit 0
    }
fi
