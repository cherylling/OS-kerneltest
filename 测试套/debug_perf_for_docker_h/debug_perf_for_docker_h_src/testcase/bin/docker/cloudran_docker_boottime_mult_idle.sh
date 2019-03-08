#!/bin/sh

set -x
source ../../../conf/testconf
source ./init.sh
RET=0

tmp_file="_tmp_data"
min=0
avg=0
max=0

function docker_boottime_parallel_idle()
{

    t1=`date +%s.%N`
    for i in $(seq 1 20)
    do
        docker run --net=none --rm ${ubuntu_image} date &
    done
    wait
    t2=`date +%s.%N`
    getTiming ${t1} ${t2} >> $tmp_file
    
}

function normal_value_percentage()
{
    local data_file=$1

    local val=0
    local normal_num=0
    local total_num=`cat $data_file | wc -l`

    for i in $(seq 1 $total_num)
    do
        val=`cat $data_file | sed -n ${i}p`
        if [ $val -le 20000 ];then
            normal_num=$(($normal_num+1))
        fi
    done

    val_per=`echo $normal_num $total_num | awk '{print $1*100/$2}'`
    echo $val_per

}

function docker_boottime_mult_idle()
{
    do_init
    if [ $? -ne 0 ];then
        echo "prepare test: FAIL"
        RET=1
        exit $RET 
    fi

    for n in $(seq 1 100)
    do
        docker_boottime_parallel_idle
    done

    min=`calc_min_value $tmp_file`
    min=$(($min/20))
    avg=`calc_avg_value $tmp_file`
    avg=$(($avg/20))
    max=`calc_max_value $tmp_file`
    max=$(($max/20))
    normal_percentage=`normal_value_percentage $tmp_file`

    do_uninit

}

docker_boottime_mult_idle

mkdir -p /tmp/cloudran
cp $tmp_file /tmp/cloudran/boottime_mult
rm -rf $tmp_file

echo "min=$min ms" >  $cloudran_report_path
echo "max=$max ms" >> $cloudran_report_path
echo "avg=$avg ms" >> $cloudran_report_path
echo "percentage=$normal_percentage %" >> $cloudran_report_path


exit $RET
