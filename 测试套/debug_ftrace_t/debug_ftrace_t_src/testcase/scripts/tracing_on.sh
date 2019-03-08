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
   grep function_graph $TRACING_PATH/available_tracers
   if [ $? -ne 0 ];then
       echo "function_graph is not in available_tracers"
       exit 1
   fi
   
}
clean()
{
   echo > $TRACING_PATH/set_graph_function
   echo > $TRACING_PATH/trace
   echo > $TRACING_PATH/set_ftrace_filter
   echo 1 > $TRACING_PATH/tracing_on
   lsmod |grep tracing_on
   if [ $? -eq 0 ];then
       rmmod tracing_on
       if [ $? -ne 0];then
           echo "rmmod tracing_on.ko failed "
           exit 1
       fi
   fi
}
do_test()
{
   echo 0 > $TRACING_PATH/tracing_on
   echo function_graph > $TRACING_PATH/current_tracer
   insmod $MODULE_PATH/tracing_on.ko
   if [ $? -ne 0 ];then
       echo "insmod tracing_on.ko fail"
       clean
       exit 1
   fi
   echo ':mod:tracing_on' > $TRACING_PATH/set_ftrace_filter
   cat $TRACING_PATH/set_ftrace_filter |grep trace_printk_init
   if [ $? -ne 0 ];then
       echo "set tracing_on mod into set_ftrace_filter fail"
       clean
       exit 1
   fi
   cat $TRACING_PATH/set_ftrace_filter |grep trace_printk_exit
   if [ $? -ne 0 ];then
       echo "set tracing_on mod into set_ftrace_filter fail"
       clean
       exit 1
   fi
   cat $TRACING_PATH/trace |grep "tracing_on testing"
   if [ $? -ne 0 ];then
       rmmod tracing_on
       insmod $MODULE_PATH/tracing_on.ko
       cat $TRACING_PATH/trace |grep "tracing_on testing"
       if [ $? -ne 0 ];then
            echo "cannot find init msg \"tracing_on testing\" in trace with function_graph tracer"
            clean
           exit 1
       fi
   fi
   cat $TRACING_PATH/trace |grep "tracing_off testing"
   if [ $? -eq 0 ];then
       echo "find init msg \"tracing_off testing\" in trace with function_graph tracer unexpected"
       clean
       exit 1
   fi
   
   echo 0 > $TRACING_PATH/tracing_on 
   rmmod tracing_on
   if [ $? -ne 0 ];then
      echo "rmmod tracing_on.ko failed"
      clean
      exit 1
   fi
   echo 0 > $TRACING_PATH/tracing_on
   cat $TRACING_PATH/trace |grep "tracing_on test end"
   if [ $? -ne 0 ];then
       echo "cannot find exit msg \"tracing_on test end\" in trace with function_graph tracer"
       clean
       exit 1
   fi
   cat $TRACING_PATH/trace |grep "tracing_off test end"
   if [ $? -eq 0 ];then
       echo "find exit msg \"tracing_off test end\" in trace with function_graph tracer unexpected"
       clean
       exit 1
   fi  
       echo "tracing_on func test pass"
       clean
       exit 0 
}

init
do_test
