#!/bin/bash
func=./write_data_03
variable=write_data
addr=`readelf $func -a|grep $variable|grep OBJ|awk '{print $2}'`
echo 0x$addr

perf record -e mem:0x$addr:w3 -f $func 1
if [ $? -eq 0 ];then
	{
		echo perf write val error with w3
		exit 1
	}
    else
        {
            echo perf write val pass with w3
            exit 0
        }
fi
