#!/bin/bash
func=./read_data_stress
variable=read_char3
addr=`readelf $func -a|grep $variable|awk '{print $2}'`
echo 0x$addr

perf record -e mem:0x$addr:r1 -f $func 1
num=`perf report|grep memval | wc -l`
if [ $num -ne 10000 ];then
	{
		echo perf write val error
		exit 1
	}
else
	{
		echo "test passed"
		exit 0
	}
fi
