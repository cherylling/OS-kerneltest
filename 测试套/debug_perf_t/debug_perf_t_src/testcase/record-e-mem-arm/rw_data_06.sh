#!/bin/bash
func=./rw_data_06
variable=write_data
addr=`readelf $func -a|grep $variable|grep OBJ|awk '{print $2}'`
echo 0x$addr

perf record -e mem:0x$addr:rw -f $func 1
val=`perf report|grep memval|head -n 1|awk -F : '{print $2}'|awk '{print $1}'|awk -F x '{print $2}'`
if [ $val -ne 1 ];then
	{
		echo perf read write val error
		exit 1
	}
fi
val=`perf report|grep memval|head -n 2|awk -F : '{print $2}'|awk '{print $1}'|awk -F x '{print $2}'`
if [ $val -ne 2 ];then
	{
		echo perf read write val error
		exit 1
	}
fi
echo "TEST PASS"
