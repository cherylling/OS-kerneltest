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
   grep wakeup_rt ${TRACING_PATH}/available_tracers
   if [ $? -ne 0 ];then
       echo "no wakeup_rt in ${TRACING_PATH}/available_tracers"
       exit 1
   fi
   echo 1 > /proc/sys/kernel/ftrace_enabled
}
clean()
{
    echo > ${TRACING_PATH}/trace
    echo 1 > ${TRACING_PATH}/tracing_on
    echo > ${TRACING_PATH}/set_ftrace_filter
    echo nop > ${TRACING_PATH}/current_tracer

}
do_test()
{
    
    echo 0 > ${TRACING_PATH}/tracing_on 
    echo > ${TRACING_PATH}/trace
    echo wakeup_rt > ${TRACING_PATH}/current_tracer 
    echo 1 > ${TRACING_PATH}/tracing_on 
    
    sleep 1
    
    echo 0 > ${TRACING_PATH}/tracing_on 
    TRACER_NAME=`cat ${TRACING_PATH}/trace |head -n1|awk -F: '{print $2}'`
    if [ $TRACER_NAME != "wakeup_rt" ];then
        echo "wakeup_rt tracer test fail"
        clean
        exit 1
    fi
    
    MAX_LATENCY=`cat ${TRACING_PATH}/trace |head -n35 |grep latency |awk -F: '{print $2}'|awk '{print $1}'`
    MAX_LATENCY2=`cat ${TRACING_PATH}/tracing_max_latency`
    if [ $MAX_LATENCY != $MAX_LATENCY2 ];then
        echo "max latency mismatch"
        clean
        exit 1
    fi
        echo "wakeup_rt tracer test pass"
        clean
        exit 0
}
init
do_test

