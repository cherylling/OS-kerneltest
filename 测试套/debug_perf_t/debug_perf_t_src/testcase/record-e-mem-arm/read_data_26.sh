#!/bin/bash
func=./read_data_26
variable=read_data2
addr=`readelf $func -a|grep $variable|awk '{print $2}'`
echo 0x$addr

perf record -e mem:0x$addr:r -k ">2" -f $func 1
perf report|grep memval
if [ $? -ne 0 ];then
	{
		echo perf read val error
		exit 1
	}
fi
perf report|grep memblock
if [ $? -ne 0 ];then
	{
		echo perf read val error
		exit 1
	}
else
	{
		echo "test passed"
		exit 0
	}
fi
