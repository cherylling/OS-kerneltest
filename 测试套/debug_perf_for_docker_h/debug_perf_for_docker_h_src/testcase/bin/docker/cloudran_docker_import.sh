#!/bin/sh

set -x
source ../../../conf/testconf
source ./init.sh
RET=0

tmp_file="_tmp_data"
min=0
avg=0
max=0
new_image="import_image"

function docker_import()
{
    do_init
    if [ $? -ne 0 ];then
        echo "prepare test: FAIL"
        RET=1
        exit $RET 
    fi
    con_id=`docker run -itd $ubuntu_image /bin/sh` > /dev/null
    docker export -o ${CURRENT_DIR}/ubuntu.tar $con_id > /dev/null

    for i in $(seq 1 $loop_num)
    do
        t1=`date +%s.%N`
        cat ${CURRENT_DIR}/ubuntu.tar | docker import - $new_image
        t2=`date +%s.%N`
        getTiming ${t1} ${t2} >> $tmp_file
        docker rmi $new_image > /dev/null
        echo 3 > /proc/sys/vm/drop_caches
        sleep 3
    done
    image_size_M=110

    min=`calc_min_value $tmp_file`
    min=$(($min*100/$image_size_M))
    avg=`calc_avg_value $tmp_file`
    avg=$(($avg*100/$image_size_M))
    max=`calc_max_value $tmp_file`
    max=$(($max*100/$image_size_M))

    docker rm -f $con_id > /dev/null 2>&1
    rm -rf ${CURRENT_DIR}/ubuntu.tar > /dev/null 2>&1
    do_uninit
    
}

docker_import

mkdir -p /tmp/cloudran
cp $tmp_file /tmp/cloudran/import
rm -rf $tmp_file

echo "min=$min ms/100MB" >  $cloudran_report_path
echo "max=$max ms/100MB" >> $cloudran_report_path
echo "avg=$avg ms/100MB" >> $cloudran_report_path


exit $RET
