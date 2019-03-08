#!/bin/bash
source ./record-e-mem_common.sh
source ${TCBIN}./common_perf.sh

exit_if_not_support

# linux 3.11 delete 'perf record -f'
# commit: 4a4d371a4dfbd3b84a7eab8d535d4c7c3647b09e
# patch name: perf record: Remove -f/--force option
perf_vcmp 3 11
if [ $? -eq 1 ];then
       opt=""
else
       opt="-f"
fi

func=./pointer
variable=iptr
addr=`readelf $func -a|grep $variable|grep OBJ|awk '{print $2}'`
echo 0x$addr

perf record -e mem:0x$addr:r $opt $func
#val=`perf report | grep memval | wc -l`
val=`perf report | grep -E "Samples:[[:blank:]]1" | wc -l`
if [ $val -ne 1 ];then 
	echo "FAIL:the sum of record wrong"
	exit 1
fi
#read check

echo "TEST PASS"
exit 0
