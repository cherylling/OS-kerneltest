#!/bin/bash
func=./rw_data_68
variable=write_short6
addr=`readelf $func -a|grep $variable|grep OBJ|awk '{print $2}'`
echo 0x$addr

perf record -e mem:0x$addr:rw2 -k "=6" -f $func 1
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
