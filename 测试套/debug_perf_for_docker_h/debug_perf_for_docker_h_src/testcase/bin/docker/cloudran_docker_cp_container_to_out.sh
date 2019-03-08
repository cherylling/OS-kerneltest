#!/bin/sh

set -x
source ../../../conf/testconf
source ./init.sh
RET=0

tmp_file="_tmp_data"
min=0
avg=0
max=0
new_image="cp_con_to_out"
mkdir -p ${CURRENT_DIR}/build

function build_new_image()
{
    dd if=/dev/zero of=${CURRENT_DIR}/1m_file bs=1M count=1

    cat > ${CURRENT_DIR}/Dockerfile.1m << EOF
FROM $ubuntu_image
COPY 1m_file /root
EOF

    docker build -t ${new_image} -f ${CURRENT_DIR}/Dockerfile.1m ${CURRENT_DIR} > /dev/null
    if [ $? -ne 0 ];then
        echo "docker build 1m_layering_image: FAIL"
        RET=1
        exit $RET
    fi

    rm -rf  ${CURRENT_DIR}/Dockerfile.1m ${CURRENT_DIR}/1m_file > /dev/null

}


function docker_cp_container_to_out()
{
    do_init
    if [ $? -ne 0 ];then
        echo "prepare test: FAIL"
        RET=1
        exit $RET 
    fi
    build_new_image
    con_id=`docker run -itd --net=none --name ${new_image} ${new_image} /bin/sh` > /dev/null

    for i in $(seq 1 $loop_num)
    do
        t1=`date +%s.%N`
        docker cp ${con_id}:/root/1m_file $CURRENT_DIR
        t2=`date +%s.%N`
        getTiming ${t1} ${t2} >> $tmp_file
        rm -rf ${CURRENT_DIR}/1m_file > /dev/null
        echo 3 > /proc/sys/vm/drop_caches
        sleep 3
    done

    min=`calc_min_value $tmp_file`
    avg=`calc_avg_value $tmp_file`
    max=`calc_max_value $tmp_file`

    docker rm -f $new_image > /dev/null 2>&1
    docker rmi $new_image > /dev/null 2>&1
    do_uninit
    
}

docker_cp_container_to_out

mkdir -p /tmp/cloudran
cp $tmp_file /tmp/cloudran/cp_container_to_out
rm -rf $tmp_file

echo "min=$min ms" >  $cloudran_report_path
echo "max=$max ms" >> $cloudran_report_path
echo "avg=$avg ms" >> $cloudran_report_path


exit $RET
