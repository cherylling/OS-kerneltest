#!/bin/sh

set -x
source ../../../conf/testconf
source ./init.sh
RET=0

tmp_file="_tmp_data"
min=0
avg=0
max=0

function docker_create()
{
    do_init
    if [ $? -ne 0 ];then
        echo "prepare test: FAIL"
        RET=1
        exit $RET 
    fi

    for i in $(seq 1 1000)
    do
        t1=`date +%s.%N`
        docker create --net=none ${ubuntu_image}
        t2=`date +%s.%N`
        getTiming ${t1} ${t2} >> $tmp_file
        docker rm -f `docker ps -qa` > /dev/null 2>&1
    done

    min=`calc_min_value $tmp_file`
    avg=`calc_avg_value $tmp_file`
    max=`calc_max_value $tmp_file`

    do_uninit
    
}

docker_create

mkdir -p /tmp/cloudran
cp $tmp_file /tmp/cloudran/create
rm -rf $tmp_file

echo "min=$min ms" >  $cloudran_report_path
echo "max=$max ms" >> $cloudran_report_path
echo "avg=$avg ms" >> $cloudran_report_path


exit $RET
