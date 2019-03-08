#!/bin/bash
TRACING_PATH=/sys/kernel/debug/tracing
init()
{
   [ -d /sys/kernel/debug -a $(ls /sys/kernel/debug |wc -l) -gt 0 ] && umount /sys/kernel/debug
   mount -t debugfs nodev /sys/kernel/debug
   if [ $? -ne 0 ];then
       echo "mount -t debugfs nodev /sys/kernel/debug fail"
       exit 1
   fi
   grep function ${TRACING_PATH}/available_tracers
   if [ $? -ne 0 ];then
       echo "no function in ${TRACING_PATH}/available_tracers"
       exit 1
   fi
   echo 1 > /proc/sys/kernel/ftrace_enabled
}

clean()
{
    echo > ${TRACING_PATH}/trace
    echo 1 > ${TRACING_PATH}/tracing_on
    echo > ${TRACING_PATH}/set_event
    echo nop > ${TRACING_PATH}/current_tracer
}

do_test()
{
    echo 0 > ${TRACING_PATH}/tracing_on
    echo irq:* > ${TRACING_PATH}/set_event
    echo function > ${TRACING_PATH}/current_tracer 
    echo 1 > ${TRACING_PATH}/tracing_on 
    
    sleep 3
    
    echo 0 > ${TRACING_PATH}/tracing_on
    TRACER_NAME=`cat ${TRACING_PATH}/trace |head -n1|awk -F: '{print $2}'`
    if [ $TRACER_NAME != "function" ];then
        echo "function tracer test fail"
        clean
        exit 1
    fi
    
    cat ${TRACING_PATH}/trace |tail -n +10 |head -n10 |grep "<-"
    if [ $? -ne 0 ];then
        echo "cannot find function calls <- in trace with function tracer"
        clean
        exit 1
    fi
    PASS_FLAT=1
    TIMEREVENTS=`cat ${TRACING_PATH}/set_event |awk -F: '{print $2}'`
    for i in $TIMEREVENTS
    do
        cat ${TRACING_PATH}/trace | grep $i
        if [ $? -eq 0 ];then
            PASS_FLAT=0
            break
        fi
    done
    
    if [ $PASS_FLAT -ne 0 ];then
        echo "ftrace function tracing irq events test fail"
        clean
        exit 1
    fi
        echo "function tracer tracing irq events test pass"
        clean
        exit 0
}

init
do_test
clean
