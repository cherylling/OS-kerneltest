#!/bin/bash
func=./read_data_93
variable=pthread_data2
addr2=`readelf $func -a|grep $variable|grep OBJ|awk '{print $2}'`
echo 0x$addr
variable=pthread_char3
addr3=`readelf $func -a|grep $variable|grep OBJ|awk '{print $2}'`
echo 0x$addr
variable=pthread_data1
addr1=`readelf $func -a|grep $variable|grep OBJ|awk '{print $2}'`
echo 0x$addr

perf record -e mem:0x$addr2:r -e mem:0x$addr3:r -e mem:0x$addr1:r4 -e mem:0x$addr2:w  -k "s:>10" -f $func 10 10
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
