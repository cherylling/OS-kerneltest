#!/bin/sh

set -x
source ../../../conf/testconf
source ./init.sh
RET=0

tmp_file="_tmp_data"
min=0
avg=0
max=0
new_image="1layering_500m"
mkdir -p ${CURRENT_DIR}/build

function docker_build_1layering_500M()
{
    do_init
    if [ $? -ne 0 ];then
        echo "prepare test: FAIL"
        RET=1
        exit $RET 
    fi

    dd if=/dev/zero of=${CURRENT_DIR}/build/${new_image} bs=1M count=500
    if [ -e ${CURRENT_DIR}/build/Dockerfile ]; then
        rm -rf ${CURRENT_DIR}/build/Dockerfile > /dev/null
    fi
    cat > ${CURRENT_DIR}/build/Dockerfile << EOF
FROM $ubuntu_image
COPY $new_image /root/
EOF

    for i in $(seq 1 $loop_num)
    do
        t1=`date +%s.%N`
        docker build --no-parent -t ${new_image} -f ${CURRENT_DIR}/build/Dockerfile ${CURRENT_DIR}/build > /dev/null
        t2=`date +%s.%N`
        getTiming ${t1} ${t2} >> $tmp_file
        docker rmi $new_image > /dev/null
        echo 3 > /proc/sys/vm/drop_caches
        sleep 3
    done

    min=`calc_min_value $tmp_file`
    min=$(($min/5))
    avg=`calc_avg_value $tmp_file`
    avg=$(($avg/5))
    max=`calc_max_value $tmp_file`
    max=$(($max/5))

    rm -rf ${CURRENT_DIR}/build > /dev/null 2>&1 
    do_uninit
    
}

docker_build_1layering_500M

mkdir -p /tmp/cloudran
cp  $tmp_file /tmp/cloudran/build_1layering_500M
rm -rf $tmp_file

echo "min=$min ms/100MB" >  $cloudran_report_path
echo "max=$max ms/100MB" >> $cloudran_report_path
echo "avg=$avg ms/100MB" >> $cloudran_report_path


exit $RET
