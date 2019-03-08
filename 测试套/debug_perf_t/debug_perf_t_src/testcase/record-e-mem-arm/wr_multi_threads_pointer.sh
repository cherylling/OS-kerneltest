#!/bin/bash
source ./record-e-mem_common.sh
source ./record-e-mem_common.sh
exit_if_not_support

func=./wr_multi_threads_pointer
variable=iptr
addr=`readelf $func -a|grep $variable|awk '{print $2}'`
echo 0x$addr

ulimit -s 1024
perf record -e mem:0x$addr:w -f $func 1
ulimit -s 8192
num=`perf report | grep memval | wc -l`
if [ $num -ne 2000 ];then
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
