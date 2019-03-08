#!/bin/bash
func=./read_data_97
variable=pthread_data2
addr2=`readelf $func -a|grep $variable|grep OBJ|awk '{print $2}'`
echo 0x$addr2
variable=pthread_char3
addr3=`readelf $func -a|grep $variable|grep OBJ|awk '{print $2}'`
echo 0x$addr3
variable=pthread_data1
addr1=`readelf $func -a|grep $variable|grep OBJ|awk '{print $2}'`
echo 0x$addr1

perf record -e mem:0x$addr2:r1 -e mem:0x$addr3:r2 -k "s:>2" -f $func 10 10
perf report|grep memval
if [ $? -eq 0 ]; then
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
