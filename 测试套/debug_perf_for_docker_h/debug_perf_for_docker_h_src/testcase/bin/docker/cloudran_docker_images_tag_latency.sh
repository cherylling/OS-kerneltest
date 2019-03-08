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

    for i in $(seq 1 $loop_num)
    do
        new_tag=tag_test_$i
        t1=`date +%s.%N`
        docker tag ${ubuntu_image} ${new_tag} 
        t2=`date +%s.%N` > /dev/null
        getTiming ${t1} ${t2} >> $tmp_file
        docker images | grep ${new_tag}
        if [ $? -eq 0 ];then
            docker rmi -f ${new_tag}
        else
            msg_err "Failed to tag images[loop num:${i}]"
            return 1
        fi
        #clear system buff
        echo 3 > /proc/sys/vm/drop_caches
        sleep 3 
    done

    min=`calc_min_value $tmp_file`
    avg=`calc_avg_value $tmp_file`
    max=`calc_max_value $tmp_file`

    clean_env
    
}

do_test || RET=1
clean_env

mkdir -p /tmp/cloudran
cp $tmp_file /tmp/cloudran/images_tag_latency

echo "min=$min ms" >  $cloudran_report_path
echo "max=$max ms" >> $cloudran_report_path
echo "avg=$avg ms" >> $cloudran_report_path


exit $RET   
