#!/bin/bash
func=./read_data_56
variable=read_data
addr=`readelf $func -a|grep $variable|grep OBJ|awk '{print $2}'`
echo 0x$addr

perf record -e mem:0x$addr:r6 -f $func 1
if [ $? -eq 0 ];then
	{
		echo perf write val error with r6
		exit 1
	}
    else
        {
            echo perf write val pass with r6
            exit 0
        }
fi
