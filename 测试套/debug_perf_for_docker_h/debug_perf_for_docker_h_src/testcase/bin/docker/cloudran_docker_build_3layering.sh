#!/bin/sh

set -x
source ../../../conf/testconf
source ./init.sh
RET=0

tmp_file="_tmp_data"
min=0
avg=0
max=0
new_image="3layering_100m"
mkdir -p ${CURRENT_DIR}/build

build_with_no_parent()
{
    build_image=$1
    base_image=$2
    test_file=$3
    test_dir=$4

    if [ -e ${CURRENT_DIR}/build/Dockerfile ]; then
        rm -rf ${CURRENT_DIR}/build/Dockerfile > /dev/null
    fi
    cat > ${CURRENT_DIR}/build/Dockerfile << EOF
FROM $base_image
COPY $test_file /root/$test_file
EOF
    docker build --no-parent -t ${build_image} -f ${CURRENT_DIR}/build/Dockerfile ${CURRENT_DIR}/build > /dev/null
    if [ $? -ne 0 ];then
        echo "docker build --no-parent: FAIL"
        RET=1
        return $RET 
    fi
    echo 3 > /proc/sys/vm/drop_caches

}


function docker_build_3layering()
{
    do_init
    if [ $? -ne 0 ];then
        echo "prepare test: FAIL"
        RET=1
        exit $RET 
    fi

    dd if=/dev/zero of=${CURRENT_DIR}/build/${new_image} bs=1M count=100
    build_with_no_parent layering_1 ${ubuntu_image} ${new_image} layering_1
    if [ $? -ne 0 ];then
        echo "docker build --no-parent 1layering: FAIL"
        exit $RET 
    fi
    build_with_no_parent layering_2 layering_1 ${new_image} layering_2
    if [ $? -ne 0 ];then
        echo "docker build --no-parent 2layering: FAIL"
        exit $RET 
    fi

    if [ -e ${CURRENT_DIR}/build/Dockerfile ]; then
        rm -rf ${CURRENT_DIR}/build/Dockerfile > /dev/null
    fi
    cat > ${CURRENT_DIR}/build/Dockerfile << EOF
FROM layering_2
COPY $new_image /root/layering_3
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
    avg=`calc_avg_value $tmp_file`
    max=`calc_max_value $tmp_file`

    rm -rf ${CURRENT_DIR}/build > /dev/null 2>&1 
    docker rmi layering_2 layering_1 > /dev/null 2>&1
    do_uninit
    
}

docker_build_3layering

mkdir -p /tmp/cloudran
cp $tmp_file /tmp/cloudran/build_3layering
rm -rf $tmp_file

echo "min=$min ms/100MB" >  $cloudran_report_path
echo "max=$max ms/100MB" >> $cloudran_report_path
echo "avg=$avg ms/100MB" >> $cloudran_report_path


exit $RET
