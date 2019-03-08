#!/bin/bash
func=./write_data_28
variable=write_data2
addr=`readelf $func -a|grep $variable|awk '{print $2}'`
echo 0x$addr

perf record -e mem:0x$addr:w -k "<5" -f $func 1
variable=write_char6
addr=`readelf $func -a|grep $variable|awk '{print $2}'`
echo 0x$addr

#perf record -e mem:0x$addr:w -k "<5" -f $func 1
perf record -e mem:0x$addr:w -f $func 1
perf report|grep memval
if [ $? -ne 0 ];then
	{
		echo perf write val error
        perf report
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
        perf report
		exit 1
	}
else
	{
		echo "test passed"
		exit 0
	}
fi
