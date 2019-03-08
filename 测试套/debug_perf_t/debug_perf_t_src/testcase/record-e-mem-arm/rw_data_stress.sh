#!/bin/bash
func=./rw_data_stress
variable=write_data
addr=`readelf $func -a|grep $variable|grep OBJ|awk '{print $2}'`
echo 0x$addr

perf record -e mem:0x$addr:rw -f $func 1
val=`perf report | grep memval | wc -l`
if [ $val -ne 10000 ];then
	{
		echo perf read write val error
		exit 1
	}
fi
exit 0
echo "TEST PASS"
