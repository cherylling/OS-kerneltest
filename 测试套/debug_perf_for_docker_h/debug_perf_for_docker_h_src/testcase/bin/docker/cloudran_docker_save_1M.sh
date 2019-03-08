#!/bin/sh

set -x
source ../../../conf/testconf
source ./init.sh
RET=0

tmp_file="_tmp_data"
min=0
avg=0
max=0

function docker_save_1M()
{
    do_init
    if [ $? -ne 0 ];then
        echo "prepare test: FAIL"
        RET=1
        exit $RET 
    fi

    for i in $(seq 1 100)
    do
        t1=`date +%s.%N`
        docker save -o ${CURRENT_DIR}/busybox.tar ${busybox_image}
        t2=`date +%s.%N`
        getTiming ${t1} ${t2} >> $tmp_file
        rm -rf ${CURRENT_DIR}/busybox.tar > /dev/null 2>&1
        echo 3 > /proc/sys/vm/drop_caches
        sleep 3
    done
    image_size_B=`docker inspect -f {{.Size}} ${busybox_image}` > /dev/null
    image_size_K=$(($image_size_B/1024))

    min=`calc_min_value $tmp_file`
    min=$(($min*1024/$image_size_K))
    avg=`calc_avg_value $tmp_file`
    avg=$(($avg*1024/$image_size_K))
    max=`calc_max_value $tmp_file`
    max=$(($max*1024/$image_size_K))

    do_uninit
    
}

docker_save_1M

mkdir -p /tmp/cloudran
cp $tmp_file /tmp/cloudran/save_1M
rm -rf $tmp_file

echo "min=$min ms/MB" >  $cloudran_report_path
echo "max=$max ms/MB" >> $cloudran_report_path
echo "avg=$avg ms/MB" >> $cloudran_report_path


exit $RET
