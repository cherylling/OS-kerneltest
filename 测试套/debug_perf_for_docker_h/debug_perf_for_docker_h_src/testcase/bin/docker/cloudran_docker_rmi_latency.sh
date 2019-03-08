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
    ping rtos.registry.com -c 1 
    if [ $? -ne 0 ];then
        echo "Connect to rtos.registry.com:FAIL"
        return 1
    fi

    docker login -u docker_tester -p docker_tester rtos.registry.com:5000
    if [ $? -ne 0 ];then
        echo "Login in rtos.registry.com:5000:FAIL"
        return 1
    fi

}

function clean_env()
{
    docker rmi -f `docker images -qa`
    docker logout rtos.registry.com:5000
}

function do_test()
{
    set_env || return 1

    for i in $(seq 1 $loop_num)
    do
        docker pull ${ubuntu_image} > /dev/null
        if [ $? -ne 0 ];then
            echo "docker pull ${ubuntu_image}: FAIL"
            return 1
        fi
        t1=`date +%s.%N`
        docker rmi ${ubuntu_image}
        t2=`date +%s.%N` > /dev/null
        getTiming ${t1} ${t2} >> $tmp_file
        #clear system buff
        echo 3 > /proc/sys/vm/drop_caches
        sleep 3  
    done

    min=`calc_min_value $tmp_file`
    avg=`calc_avg_value $tmp_file`
    max=`calc_max_value $tmp_file`

}

do_test || exit 1
clean_env

mkdir -p /tmp/cloudran
cp $tmp_file /tmp/cloudran/rmi_latency

echo "min=$min ms" >  $cloudran_report_path
echo "max=$max ms" >> $cloudran_report_path
echo "avg=$avg ms" >> $cloudran_report_path


exit $RET   
