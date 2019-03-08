#!/bin/bash
func=./write_data_03
variable=write_data
addr=`readelf $func -a|grep $variable|grep OBJ|awk '{print $2}'`
echo 0x$addr

perf record -e mem:0x$addr:w -f $func 1
perf report|grep memval
if [ $? -ne 0 ];then
	{
		echo perf write val error
		exit 1
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
