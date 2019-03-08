#!/bin/sh

set -x
source ../../../conf/testconf
source ./init.sh
RET=0

tmp_file="_tmp_data"
min=0
avg=0
max=0
new_image="exec_image"
mkdir -p ${CURRENT_DIR}/build

function docker_exec()
{
    do_init
    if [ $? -ne 0 ];then
        echo "prepare test: FAIL"
        RET=1
        exit $RET 
    fi
    if [ -e ${CURRENT_DIR}/build/Dockerfile ]; then
        rm -rf ${CURRENT_DIR}/build/Dockerfile > /dev/null
    fi
    cat > ${CURRENT_DIR}/build/Dockerfile << EOF
FROM $ubuntu_image
RUN echo 123 > /home/test1
EOF
    docker build -t ${new_image} -f ${CURRENT_DIR}/build/Dockerfile ${CURRENT_DIR}/build > /dev/null
    if [ $? -ne 0 ];then
        echo "docker build: FAIL"
        RET=1
        exit $RET 
    fi
    con_id=`docker run -itd --net=none --name ${new_image} ${new_image} /bin/sh` > /dev/null

    for i in $(seq 1 100)
    do
        t1=`date +%s.%N`
        t2=`docker exec -it $con_id date +%s.%N`
        getTiming ${t1} ${t2} >> $tmp_file
        echo 3 > /proc/sys/vm/drop_caches
        sleep 3
    done

    min=`calc_min_value $tmp_file`
    avg=`calc_avg_value $tmp_file`
    max=`calc_max_value $tmp_file`

    rm -rf ${CURRENT_DIR}/build > /dev/null 2>&1
    docker rm -f $new_image > /dev/null 2>&1
    docker rmi $new_image > /dev/null 2>&1
    do_uninit
    
}

docker_exec

mkdir -p /tmp/cloudran
cp $tmp_file /tmp/cloudran/exec
rm -rf $tmp_file

echo "min=$min ms" >  $cloudran_report_path
echo "max=$max ms" >> $cloudran_report_path
echo "avg=$avg ms" >> $cloudran_report_path


exit $RET
