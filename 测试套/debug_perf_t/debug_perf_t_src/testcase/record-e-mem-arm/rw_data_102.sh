#!/bin/bash
func=./rw_data_102
variable=pthread_data2
addr2=`readelf $func -a|grep $variable|grep OBJ|awk '{print $2}'`
echo 0x$addr2
variable=pthread_char3
addr3=`readelf $func -a|grep $variable|grep OBJ|awk '{print $2}'`
echo 0x$addr3
variable=pthread_data1
addr1=`readelf $func -a|grep $variable|grep OBJ|awk '{print $2}'`
echo 0x$addr1

perf record -e mem:0x$addr2:rw1 -e mem:0x$addr3:rw1 -k ">2" -f $func 10 10
count=`perf report|grep memval|wc -l`
sum=0
./is_big_endian
if [ $? -eq 0 ];then
	sum=4
fi
if [ $count -ne $sum ]; then
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
