#!/bin/bash
func=./rw_data_61
variable=write_char2
addr=`readelf $func -a|grep $variable|grep OBJ|awk '{print $2}'`
echo 0x$addr

perf record -e mem:0x$addr:rw4 -f $func 1
ret=`perf report|grep memval|wc -l`
if [ $ret -ne 2 ];then
	{
		echo perf read write val error
		exit 1
	}
    else
        {
            echo perf rw val succeed
            exit 0
        }
fi
echo "TEST PASS"
