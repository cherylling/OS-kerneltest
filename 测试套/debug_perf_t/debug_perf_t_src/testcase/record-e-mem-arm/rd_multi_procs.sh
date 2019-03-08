#!/bin/bash
source ./record-e-mem_common.sh
source ./record-e-mem_common.sh
exit_if_not_support

func=./rd_multi_procs
variable=pthread_data2
addr=`readelf $func -a|grep $variable|awk '{print $2}'`
echo 0x$addr

perf record -e mem:0x$addr:r -f $func 
num=`perf report | grep memval | wc -l`
if [ $num -ne 5800 ];then
	echo perf read val error
	exit 1
fi

perf report | grep memval | grep -v 0x2
if [ $? -eq 0 ];then
	echo perf read val error
	exit 1
fi

echo "test passed"
exit 0
