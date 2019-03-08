#!/bin/sh

set -x
source ../../../conf/testconf
source ./init.sh
RET=0

tmp_file="_tmp_data"
min=0
avg=0
max=0


function normal_value_percentage()
{
    local data_file=$1

    local val=0
    local normal_num=0
    local total_num=`cat $data_file | wc -l`

    for i in $(seq 1 $total_num)
    do
        val=`cat $data_file | sed -n ${i}p`
        if [ $val -le 1000 ];then
            normal_num=$(($normal_num+1))
        fi
    done

    val_per=`echo $normal_num $total_num | awk '{print $1*100/$2}'`
    echo $val_per

}

function docker_reboottime_single_idle()
{
    do_init
    if [ $? -ne 0 ];then
        echo "prepare test: FAIL"
        RET=1
        exit $RET 
    fi

    con_id=`docker run --net=none -itd ${ubuntu_image}` > /dev/null

    for i in $(seq 1 2000)
    do
        t1=`date +%s.%N`
        docker restart $con_id > /dev/null 2>&1
        t2=`date +%s.%N`
        getTiming ${t1} ${t2} >> $tmp_file
    done

    for n in $(seq 1 3)
    do
        del_max_value $tmp_file
    done

    min=`calc_min_value $tmp_file`
    avg=`calc_avg_value $tmp_file`
    max=`calc_max_value $tmp_file`
    normal_percentage=`normal_value_percentage $tmp_file`

    docker rm -f $con_id > /dev/null 2>&1
    do_uninit
    
}

docker_reboottime_single_idle

mkdir -p /tmp/cloudran
cp $tmp_file /tmp/cloudran/reboottime_single
rm -rf $tmp_file

echo "min=$min ms" >  $cloudran_report_path
echo "max=$max ms" >> $cloudran_report_path
echo "avg=$avg ms" >> $cloudran_report_path
echo "percentage=$normal_percentage %" >> $cloudran_report_path


exit $RET
