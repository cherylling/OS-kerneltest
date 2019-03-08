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

func=./read_data_53
variable=fork_data
addr=`readelf $func -a|grep $variable|awk '{print $2}'`
echo 0x$addr

perf record -e mem:0x$addr:r $opt $func 1
perf report|grep -E "Samples:[[:blank:]]2"
if [ $? -ne 0 ];then
    {
        echo test fail
        exit 1
    }
else
    {
        echo test pass
        exit 0
    }
fi
