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
   echo > ${TRACING_PATH}/trace
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
    echo function > ${TRACING_PATH}/current_tracer
    echo do_sys_open > ${TRACING_PATH}/set_ftrace_filter
    if [ $? -ne 0 ];then
         echo 'echo do_sys_open > set_ftrace_filter failed'
         clean
         exit 1
    fi
    echo 1 > ${TRACING_PATH}/tracing_on 
    ls / #make sure do_sys_open is called
    echo 0 > ${TRACING_PATH}/tracing_on
    TRACER_NAME=`head -n1 ${TRACING_PATH}/trace|awk -F: '{print $2}'`
    TRACER_NAME=${TRACER_NAME#* }
    if [ x"${TRACER_NAME}" != x"function" ];then
        echo "function tracer test fail"
        clean
        exit 1
    fi

    cat  ${TRACING_PATH}/trace |grep "do_sys_open" |grep "<-"
    if [ $? -ne 0 ];then
        echo "cannot find function calls do_sys_open in trace with function tracer"
        clean
        exit 1
    fi
    echo "function tracer test pass"
}

init
do_test
if [ $? -ne 0 ];then
	do_test
fi
clean
