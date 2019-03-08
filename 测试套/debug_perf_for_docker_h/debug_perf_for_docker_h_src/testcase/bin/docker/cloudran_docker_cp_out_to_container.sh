#!/bin/sh

set -x
source ../../../conf/testconf
source ./init.sh
RET=0

tmp_file="_tmp_data"
min=0
avg=0
max=0
new_image="cp_out_to_con"

function docker_cp_out_to_container()
{
    do_init
    if [ $? -ne 0 ];then
        echo "prepare test: FAIL"
        RET=1
        exit $RET 
    fi
    dd if=/dev/zero of=${CURRENT_DIR}/1m_file bs=1M count=1
    con_id=`docker run -itd --name ${new_image} $ubuntu_image /bin/sh` > /dev/null

    for i in $(seq 1 $loop_num)
    do
        t1=`date +%s.%N`
        docker cp ${CURRENT_DIR}/1m_file ${con_id}:/root  > /dev/null
        t2=`date +%s.%N`
        getTiming ${t1} ${t2} >> $tmp_file
        docker exec -it $con_id rm /root/1m_file > /dev/null
        echo 3 > /proc/sys/vm/drop_caches
        sleep 3
    done

    min=`calc_min_value $tmp_file`
    avg=`calc_avg_value $tmp_file`
    max=`calc_max_value $tmp_file`

    rm -rf ${CURRENT_DIR}/1m_file > /dev/null
    do_uninit
    
}

docker_cp_out_to_container

mkdir -p /tmp/cloudran
cp $tmp_file /tmp/cloudran/cp_out_to_container
rm -rf $tmp_file

echo "min=$min ms" >  $cloudran_report_path
echo "max=$max ms" >> $cloudran_report_path
echo "avg=$avg ms" >> $cloudran_report_path


exit $RET
