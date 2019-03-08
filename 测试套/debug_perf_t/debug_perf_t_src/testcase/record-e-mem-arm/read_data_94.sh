#!/bin/bash
func=./read_data_94
variable=pthread_data2
addr2=`readelf $func -a|grep $variable|grep OBJ|awk '{print $2}'`
echo 0x$addr
variable=pthread_char3
addr3=`readelf $func -a|grep $variable|grep OBJ|awk '{print $2}'`
echo 0x$addr
variable=pthread_data1
addr1=`readelf $func -a|grep $variable|grep OBJ|awk '{print $2}'`
echo 0x$addr

perf record -e mem:0x$addr2:r -e mem:0x$addr3:r -e mem:0x$addr1:r4 -e mem:0x$addr2:w  -e mem:0x$addr1:rw -k "s:>10" -f $func 10 10

if [ $? -eq 0 ];then
	{
		echo "configure above 4 points at the same time test fail"
		exit 1
	}
    else
        {
            echo "configure above 4points at the same time test ok"
            exit 0
        }
fi
echo "TEST PASS"
