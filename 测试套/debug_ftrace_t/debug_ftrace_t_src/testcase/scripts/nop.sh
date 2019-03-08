#!/bin/bash
#!/bin/bash
TRACING_PATH=/sys/kernel/debug/tracing
init()
{
   [ -d /sys/kernel/debug -a $(ls /sys/kernel/debug |wc -l) -gt 0 ]  && umount /sys/kernel/debug
   mount -t debugfs nodev /sys/kernel/debug
   if [ $? -ne 0 ];then
       echo "mount -t debugfs nodev /sys/kernel/debug fail"
       exit 1
   fi
   grep nop ${TRACING_PATH}/available_tracers
   if [ $? -ne 0 ];then
       echo "no nop in ${TRACING_PATH}/available_tracers"
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
   echo 0 >  ${TRACING_PATH}/tracing_on
   echo > ${TRACING_PATH}/trace
   echo nop > ${TRACING_PATH}/current_tracer 
   echo 1 > ${TRACING_PATH}/tracing_on 
   sleep 1
   echo 0 > ${TRACING_PATH}/tracing_on 
   TRACER_NAME=`cat ${TRACING_PATH}/trace |head -n1|awk -F: '{print $2}'`
   if [ $TRACER_NAME != "nop" ];then
       echo "nop tracer test fail"
       clean
       exit 1
   fi

   #MAX_LATENCY=`cat ${TRACING_PATH}/trace |head -n35 |grep latency |awk -F: '{print $2}'|awk '{print $1}'`
   #MAX_LATENCY2=`cat ${TRACING_PATH}tracing_max_latency`
   #if [ $MAX_LATENCY != $MAX_LATENCY2 ];then
   #    echo "max latency mismatch"
   #    clean
   #    exit 1
   #fi
   
   #cat ${TRACING_PATH}/trace |head -n35 |grep "=> started at:"
   #if [ $? -ne 0 ];then
   #    echo "cannot find => started at: in trace with nop tracer"
   #    clean
   #    exit 1
   #fi
   
   #cat ${TRACING_PATH}/trace |head -n35 |grep "=> ended at:"
   #if [ $? -ne 0 ];then
   #    echo "cannot find => ended at: in trace with nop tracer"
   #     clean
   #    exit 1
   #fi
       echo "nop tracer test pass"
       clean
       exit 0
}
init
do_test
