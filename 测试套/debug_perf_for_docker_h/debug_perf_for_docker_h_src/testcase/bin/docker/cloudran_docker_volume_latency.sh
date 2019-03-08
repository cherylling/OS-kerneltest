#!/bin/sh

set -x
source ../../../conf/testconf
source ./init.sh
RET=0

tmp_file="_tmp_data"
min=0
avg=0
max=0

function set_env()
{
    #pull images 
    do_init
    if [ $? -ne 0 ];then
        echo "prepare test: FAIL"
        return 1
    fi  
}

function clean_env()
{
    #delete docker images
    do_uninit

}

function do_test()
{
    set_env || return 1
    volume_name="myvolume"

    for i in $(seq 1 $loop_num)
    do
        t1=`date +%s.%N`
        docker volume create --name ${volume_name} || return 1 
        t2=`date +%s.%N`
        getTiming ${t1} ${t2} >> $tmp_file
        docker volume rm ${volume_name} || return 1
        #clear system buff
        echo 3 > /proc/sys/vm/drop_caches
        sleep 3  
    done

    min=`calc_min_value $tmp_file`
    avg=`calc_avg_value $tmp_file`
    max=`calc_max_value $tmp_file`

}

do_test || RET=1
clean_env

mkdir -p /tmp/cloudran
cp $tmp_file /tmp/cloudran/volume_create_latency

echo "min=$min ms" >  $cloudran_report_path
echo "max=$max ms" >> $cloudran_report_path
echo "avg=$avg ms" >> $cloudran_report_path


exit $RET   
