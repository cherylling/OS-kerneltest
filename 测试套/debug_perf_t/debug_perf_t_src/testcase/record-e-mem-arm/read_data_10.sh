#!/bin/bash
func=./read_data_10
variable=read_char3
addr=`readelf $func -a|grep $variable|awk '{print $2}'`
echo 0x$addr

perf record -e mem:0x$addr:r1 -f $func 1
perf report|grep memval
if [ $? -ne 0 ];then
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
perf report|grep memblock
if [ $? -ne 0 ];then
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
