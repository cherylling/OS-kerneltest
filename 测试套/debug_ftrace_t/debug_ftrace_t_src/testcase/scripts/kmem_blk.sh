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
   grep blk ${TRACING_PATH}/available_tracers
   if [ $? -ne 0 ];then
       echo "no blk in ${TRACING_PATH}/available_tracers"
       exit 1
   fi
   echo 1 > /proc/sys/kernel/ftrace_enabled
}

clean()
{
    echo > ${TRACING_PATH}/trace
    echo 1 > ${TRACING_PATH}/tracing_on
    echo nop > ${TRACING_PATH}/current_tracer
    echo > ${TRACING_PATH}/set_event
}
do_test()
{
    echo 0 > ${TRACING_PATH}/tracing_on 
    echo kmem:* > ${TRACING_PATH}/set_event
    echo blk > ${TRACING_PATH}/current_tracer 
    echo 1 > ${TRACING_PATH}/tracing_on 
    
    sleep 1
    
    echo 0 > ${TRACING_PATH}/tracing_on 
    TRACER_NAME=`cat ${TRACING_PATH}/trace |head -n1|awk -F: '{print $2}'`
    if [ $TRACER_NAME != "blk" ];then
        echo "blk tracer test fail"
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
        echo "ftrace blk tracing kmem events test fail"
        clean
        exit 1
    fi
    
        echo "blk tracer tracing kmem events test pass"
        clean
        exit 0

}
init
do_test
