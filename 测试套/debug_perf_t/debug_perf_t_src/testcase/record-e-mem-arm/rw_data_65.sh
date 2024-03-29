#!/bin/bash
func=./rw_data_65
variable=write_char2
addr=`readelf $func -a|grep $variable|grep OBJ|awk '{print $2}'`
echo 0x$addr

perf record -e mem:0x$addr:rw1 -k "=0x2" -f $func 1
perf report|grep memval
if [ $? -ne 0 ];then
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
