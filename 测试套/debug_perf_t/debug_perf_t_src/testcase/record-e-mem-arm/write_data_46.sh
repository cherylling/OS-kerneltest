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

func=write_data_46
variable=fork_data
addr=`readelf $func -a|grep $variable|awk '{print $2}'`
echo 0x$addr
perf_data_path=/tmp/perf.data

./$func &
sleep 1
addr=`cat usr_gvar_addr.tmp`
echo "watch addr:" $addr
perf record -o $perf_data_path -e mem:$addr:w -p `pidof $func`

#perf record -e mem:0x$addr:w $opt $func 1
#perf report|grep memval
perf report -i $perf_data_path | grep -E "Event[[:blank:]]count.*:[[:blank:]]1"
if [ $? -ne 0 ];then
    {
        echo test fail
        rm -rf $perf_data_path
        exit 1
    }
else
    {
        echo test pass
        rm -rf $perf_data_path
        exit 0
    }
fi
