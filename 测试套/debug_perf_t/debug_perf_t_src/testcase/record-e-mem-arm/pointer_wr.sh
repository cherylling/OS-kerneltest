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

func=pointer2
variable=iptr
addr=`readelf $func -a|grep $variable|grep OBJ|awk '{print $2}'`
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

#perf record -e mem:0x$addr:w $opt $func
#val=`perf report | grep memval | wc -l`
ret=`perf report -i $perf_data_path | grep -E "Samples:[[:blank:]]1"`
rm $perf_data_path -rf
if [ -z "$ret" ];then
	echo "FAIL:the sum of record wrong"
	exit 1
fi
#write check

echo "TEST PASS"
exit 0
