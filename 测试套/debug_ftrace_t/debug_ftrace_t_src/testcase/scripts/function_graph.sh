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
   grep function_graph ${TRACING_PATH}/available_tracers
   if [ $? -ne 0 ];then
       echo "no function_graph in ${TRACING_PATH}/available_tracers"
       exit 1
   fi
   echo 1 > /proc/sys/kernel/ftrace_enabled
}

clean()
{
    echo > ${TRACING_PATH}/trace
    echo 1 > ${TRACING_PATH}/tracing_on
    echo nop > ${TRACING_PATH}/current_tracer
}

do_test()
{
    echo 0 > ${TRACING_PATH}/tracing_on
    echo function_graph > ${TRACING_PATH}/current_tracer 
    echo  __do_fault > ${TRACING_PATH}/set_graph_function
    
    echo  1 > ${TRACING_PATH}/tracing_on 
    sleep 2
    echo  0 > ${TRACING_PATH}/tracing_on 

    echo > ${TRACING_PATH}/set_graph_function
    TRACER_NAME=`cat ${TRACING_PATH}/trace |head -n1|awk -F: '{print $2}'`
    TRACER_NAME=${TRACER_NAME#* }
    if [ x"${TRACER_NAME}" != x"function_graph" ];then
        echo "function_graph tracer test fail"
        clean
        exit 1
    fi
    
    cat ${TRACING_PATH}/trace |grep " us "
    if [ $? -ne 0 ];then
        echo "cannot find function DURATION us in trace with function_graph tracer"
        clean
        exit 1
    fi
        echo "function_graph tracer test pass"
        clean
        exit 0
}

init
do_test
clean
