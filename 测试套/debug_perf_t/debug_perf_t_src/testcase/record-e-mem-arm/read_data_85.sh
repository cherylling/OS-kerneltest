#!/bin/bash
func=./read_data_85
variable=write_short6
addr=`readelf $func -a|grep $variable|grep OBJ|awk '{print $2}'`
echo 0x$addr

perf record -e mem:0x$addr:r2 -k "s:>0" -f $func 1
perf report|grep memval
if [ $? -eq 0 ];then
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
