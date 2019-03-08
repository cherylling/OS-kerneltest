#!/bin/sh

set -x
source ../../../conf/testconf
source ./init.sh
RET=0

tmp_file="_tmp_data"
min=0
avg=0
max=0
new_image="1m_layering_image"

function build_new_image()
{
    dd if=/dev/zero of=${CURRENT_DIR}/1m_file bs=1M count=1

    cat > ${CURRENT_DIR}/Dockerfile.1m << EOF
FROM $ubuntu_image
COPY 1m_file /root
EOF

    docker build --no-parent -t ${new_image} -f ${CURRENT_DIR}/Dockerfile.1m ${CURRENT_DIR} > /dev/null
    if [ $? -ne 0 ];then
        echo "docker build 1m_layering_image: FAIL"
        RET=1
        exit $RET 
    fi

    rm -rf  ${CURRENT_DIR}/Dockerfile.1m ${CURRENT_DIR}/1m_file > /dev/null

}

function docker_load_layering_image_1M()
{
    do_init
    if [ $? -ne 0 ];then
        echo "prepare test: FAIL"
        RET=1
        exit $RET 
    fi
    build_new_image
    docker save -o ${CURRENT_DIR}/${new_image}.tar ${new_image} > /dev/null
    if [ $? -ne 0 ];then
        echo "docker save: FAIL"
        RET=1
        exit $RET 
    fi
    image_size_B=`docker inspect -f {{.Size}} ${new_image}` > /dev/null
    image_size_K=$(($image_size_B/1024))
    docker rmi $new_image > /dev/null
    if [ $? -ne 0 ];then
        echo "docker rmi: FAIL"
        RET=1
        exit $RET 
    fi

    for i in $(seq 1 100)
    do
        t1=`date +%s.%N`
        docker load -i ${CURRENT_DIR}/${new_image}.tar
        t2=`date +%s.%N`
        getTiming ${t1} ${t2} >> $tmp_file
        docker rmi ${new_image} > /dev/null
        echo 3 > /proc/sys/vm/drop_caches
        sleep 3
    done

    min=`calc_min_value $tmp_file`
    min=$(($min*1024/$image_size_K))
    avg=`calc_avg_value $tmp_file`
    avg=$(($avg*1024/$image_size_K))
    max=`calc_max_value $tmp_file`
    max=$(($max*1024/$image_size_K))

    rm -rf ${CURRENT_DIR}/${new_image}.tar > /dev/null 2>&1
    do_uninit
    
}

docker_load_layering_image_1M

mkdir -p /tmp/cloudran
cp $tmp_file /tmp/cloudran/load_layering_image_1M
rm -rf $tmp_file

echo "min=$min ms/MB" >  $cloudran_report_path
echo "max=$max ms/MB" >> $cloudran_report_path
echo "avg=$avg ms/MB" >> $cloudran_report_path


exit $RET
