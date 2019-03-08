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
   lsmod |grep trace_printk
   if [ $? -eq 0 ];then
      rmmod trace_printk
   fi

}
clean()
{
   echo > $TRACING_PATH/set_graph_function
   echo > $TRACING_PATH/trace
   echo > $TRACING_PATH/set_ftrace_filter
   echo 1 > $TRACING_PATH/tracing_on
   lsmod |grep trace_printk
   if [ $? -eq 0 ];then
      rmmod trace_printk
      if [ $? -ne 0 ];then
         echo "rmmod trace_printk fail"
      exit 1
      fi
   fi 
}
do_test()
{
   echo > $TRACING_PATH/trace
   echo function_graph > $TRACING_PATH/current_tracer
   echo 1 > $TRACING_PATH/tracing_on
   
   insmod $MODULE_PATH/trace_printk.ko
   if [ $? -ne 0 ];then
       echo "insmod trace_printk.ko fail"
       clean
       exit 1
   fi
   echo ':mod:trace_printk' > $TRACING_PATH/set_ftrace_filter
   echo 0 > $TRACING_PATH/tracing_on
   cat $TRACING_PATH/set_ftrace_filter |grep trace_printk_init
   if [ $? -ne 0 ];then
       echo "set trace_printk mod into set_ftrace_filter fail"
       clean
       exit 1
   fi
   cat $TRACING_PATH/set_ftrace_filter |grep trace_printk_exit
   if [ $? -ne 0 ];then
       echo "set trace_printk mod into set_ftrace_filter fail"
       clean
       exit 1
   fi
   TRACER_NAME=`cat $TRACING_PATH/trace |head -n1|awk -F: '{print $2}'`
   if [ $TRACER_NAME != "function_graph" ];then
      echo "function_graph tracer test fail"
      clean
      exit 1
   fi
   cat $TRACING_PATH/trace |grep "trace_printk testing"
   if [ $? -ne 0 ];then
       rmmod trace_printk
       echo 1 > $TRACING_PATH/tracing_on
       insmod $MODULE_PATH/trace_printk.ko
       cat $TRACING_PATH/trace |grep "trace_printk testing"
       if [ $? -ne 0 ];then
            echo "cannot find init msg \"trace_printk testing\" in trace with function_graph tracer"
            clean
            exit 1
       fi
       echo 0 > $TRACING_PATH/tracing_on
   fi
  
   echo 1 > $TRACING_PATH/tracing_on 
   rmmod trace_printk
   if [ $? -ne 0 ];then
         echo "rmmod trace_printk fail"
         clean
         exit 1
   fi
   echo 0 > $TRACING_PATH/tracing_on

   cat $TRACING_PATH/trace |grep "trace_printk test end"
   if [ $? -ne 0 ];then
      echo "cannot find exit msg \"trace_printk test end\" in trace with function_graph tracer"
      clean
      exit 1
   fi
      echo "trace_printk function test pass"
      clean
      exit 0
}

init
do_test
