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

func=write_data_44
variable=pthread_data
addr=`readelf $func -a|grep $variable|awk '{print $2}'`
echo 0x$addr
step1=step1.tmp
step2=step2.tmp
perf_data_path=/tmp/perf.data

[ -e $step1 ] && rm -rf $step1
[ -e $step2 ] && rm -rf $step2

./$func &
while([ ! -e $step1 ])
do
    sleep 1
done

addr=`cat usr_gvar_addr.tmp`
echo "watch addr:" $addr
touch $step2
perf record -o $perf_data_path -e mem:$addr:w -p `pidof $func`

#perf record -e mem:0x$addr:w $opt $func 1
#ret=`perf report|grep memval|wc -l`
#ret=`perf report | grep -E "Event[[:blank:]]count.*:[[:blank:]]2"`
#kernel may trigger the watchpoints also, so further grep pthread
ret=`perf report -i $perf_data_path | grep write_data_44 | grep pthread | wc -l`
rm $perf_data_path -rf
if [ $ret -ne 2 ];then
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
