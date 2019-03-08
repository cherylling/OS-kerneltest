#!/bin/bash
TRACING_PATH=/sys/kernel/debug/tracing
MODULE_PATH=$(pwd)
init()
{
   [ -d /sys/kernel/debug -a $(ls /sys/kernel/debug |wc -l) -gt 0 ] && umount /sys/kernel/debug
   mount -t debugfs nodev /sys/kernel/debug
   if [ $? -ne 0 ];then
       echo "mount -t debugfs nodev /sys/kernel/debug fail"
       exit 1
   fi
   grep function $TRACING_PATH/available_tracers
   if [ $? -ne 0 ];then
       echo "function is not in available_tracers"
       exit 1
   fi

}
clean()
{
   echo > $TRACING_PATH/set_graph_function
   echo > $TRACING_PATH/trace
   echo > $TRACING_PATH/set_ftrace_filter
   echo 1 > $TRACING_PATH/tracing_on
   lsmod |grep tracing_off
   if [ $? -eq 0 ];then
       rmmod tracing_off
       if [ $? -ne 0];then
           echo "rmmod tracing_off failed "
           exit 1
       fi
   fi
}

do_test()
{
    
   echo 0 > $TRACING_PATH/tracing_on 
   echo function > $TRACING_PATH/current_tracer 
   echo 1 > $TRACING_PATH/tracing_on
   
   insmod $MODULE_PATH/tracing_off.ko
   if [ $? -ne 0 ];then
       echo "insmod tracing_off.ko fail"
       clean
       exit 1
   fi
   TRACING_ON=`cat $TRACING_PATH/tracing_on`
   if [ $TRACING_ON -ne 0 ];then
       echo "tracing_off func fail"
       clean
       exit 1
   fi
   
   cat $TRACING_PATH/trace |grep "tracing_off testing"
   if [ $? -ne 0 ];then
       echo "cannot find init func \"tracing_off testing\" in trace with function tracer"
       clean
       exit 1
   fi
   
   echo 1 > $TRACING_PATH/tracing_on
   
   rmmod tracing_off
   if [ $? -ne 0 ];then
       echo "rmmod tracing_off fail"
       clean
       exit 1
   fi
   
   TRACING_ON=`cat $TRACING_PATH/tracing_on`
   if [ $TRACING_ON -ne 0 ];then
       echo "tracing_off func fail"
       clean
       exit 1
   fi
   
   cat $TRACING_PATH/trace |grep "tracing_off test end"
   if [ $? -ne 0 ];then
       echo "cannot find exit func \"tracing_off test end\" in trace with function tracer"
       clean
       exit 1
   fi
       echo "tracing_off func test pass"
       clean
       exit 0
}
init
do_test
