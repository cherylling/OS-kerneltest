#!/bin/sh

rtos_image="rtos.registry.com:5000/docker-fs-kvm-x64:v2r1c00spc105b010"
busybox_image="rtos.registry.com:5000/busybox:latest"
ubuntu_image="rtos.registry.com:5000/ubuntu:latest"

CURRENT_DIR=$(cd `dirname $0` && pwd)

loop_num=30

do_init()
{
    echo "Start to do init..."
    ping rtos.registry.com -c 1
    if [ $? -eq 0 ];then
        docker login -u docker_tester -p docker_tester rtos.registry.com:5000
        docker pull ${rtos_image} > /dev/null
        if [ $? -ne 0 ];then
            echo "docker pull ${rtos_image}: FAIL"
            return 1
        fi
        docker pull ${busybox_image} > /dev/null
        if [ $? -ne 0 ];then
            echo "docker pull ${busybox_image}: FAIL"
            return 1
        fi
        docker pull ${ubuntu_image} > /dev/null
        if [ $? -ne 0 ];then
            echo "docker pull ${ubuntu_image}: FAIL"
            return 1
        fi
        docker logout rtos.registry.com:5000
    else
        echo "ping rtos.registry.com:FAIL"
        return 1
    fi
    echo "End to do init..."

}

do_uninit()
{
    echo "Start to do uninit..."
    docker rm -f `docker ps -qa` > /dev/null 2>&1
    docker rmi -f ${rtos_image} > /dev/null 2>&2
    docker rmi -f ${busybox_image} > /dev/null 2>&1 
    docker rmi -f ${ubuntu_image} > /dev/null 2>&1
    echo "End to do uninit..."

}

function getTiming()
{
    local start=$1
    local end=$2

    local start_s=$(echo $start | cut -d '.' -f 1 | tr -d -c '0-9 \n')
    local start_ns=$(echo $start | cut -d '.' -f 2 | tr -d -c '0-9 \n')
    local end_s=$(echo $end | cut -d '.' -f 1 | tr -d -c '0-9 \n')
    local end_ns=$(echo $end | cut -d '.' -f 2 | tr -d -c '0-9 \n')

    local s_dx_ms=$(((10#$end_s - 10#$start_s) * 1000))
    local ns_dx_ms=$(((10#$end_ns - 10#$start_ns)/10#1000000))
    time=$((10#$s_dx_ms + 10#$ns_dx_ms))
    echo "$time"

}

function calc_min_value()
{
    local data_file=$1
    local val=0
    local value_num=`cat $data_file | wc -l`
    min_value=`cat $data_file | sed -n 1p`
    for j in $(seq 2 $value_num)
    do
        val=`cat $data_file | sed -n ${j}p`
        if [ $val -lt $min_value ];then
            min_value=$val
        fi
    done
    echo "$min_value"

}

function calc_avg_value()
{
    local data_file=$1
    local val=0
    local sum=0
    local value_num=`cat $data_file | wc -l`
    for k in $(seq 1 $value_num)
    do
        val=`cat $data_file | sed -n ${k}p`
        sum=$(($sum+$val))
    done
    avg_value=$(($sum/$value_num))
    echo "$avg_value"

}

function calc_max_value()
{
    local data_file=$1
    local val=0
    local value_num=`cat $data_file | wc -l`
    max_value=`cat $data_file | sed -n 1p`
    for l in $(seq 2 $value_num)
    do
        val=`cat $data_file | sed -n ${l}p`
        if [ $val -gt $max_value ];then
            max_value=$val
        fi
    done
    echo "$max_value"

}

function del_max_value()
{
    local data_file=$1
    local val=0
    local value_num=`cat $data_file | wc -l`
    max_value=`cat $data_file | sed -n 1p`
    for m in $(seq 2 $value_num)
    do
        val=`cat $data_file | sed -n ${m}p`
        if [ $val -gt $max_value ];then
            max_value=$val
        fi
    done
    sed -i "/${max_value}/"d $data_file

}
