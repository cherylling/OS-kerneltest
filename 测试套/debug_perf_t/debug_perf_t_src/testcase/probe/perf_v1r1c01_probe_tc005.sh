#!/bin/bash

report_path=/tmp/perf.data
span_file=../config/perf_probe_schedule_spacing.cfg
ret=0

dotest()
{
    if [ ! -z "`uname -m | grep ppc`" ];then
        span1=`cat $span_file | sed -n '1p'`
        span2=`cat $span_file | sed -n '3p'`
        span3=`cat $span_file | sed -n '4p'`
        SUB=5
    elif [ ! -z "`uname -m | grep aarch64`" ];then
        span1=`cat $span_file | sed -n '1p'`
        span2=`cat $span_file | sed -n '2p'`
        span3=`cat $span_file | sed -n '4p'`
        SUB=5
    elif [ ! -z "`uname -m | grep x86`" ];then
        span1=`cat $span_file | sed -n '1p'`
        span2=`cat $span_file | sed -n '2p'`
        span3=`cat $span_file | sed -n '4p'`
        SUB=5
    else
        span1=`cat $span_file | sed -n '1p'`
        span2=`cat $span_file | sed -n '2p'`
        span3=`cat $span_file | sed -n '3p'`
        span4=`cat $span_file | sed -n '4p'`
        SUB=6
    fi
    
    cpunum=`cat /proc/cpuinfo | grep processor | wc -l`
    perf probe -a schedule+$span1
    perf probe -f -a schedule+$span2
    perf probe -f -a schedule
    perf probe -f -a schedule
    perf probe -f -a schedule+$span3
    
    if [ -z "`uname -m | grep aarch64`" ] && [ -z "`uname -m | grep ppc`" ] && [ -z "`uname -m | grep x86`" ];then
        perf probe -f -a schedule+$span4
    fi
    if [ $cpunum -gt 1 ];then
        perf probe -f -a __kmalloc
        perf probe -f -a __kmalloc
    fi
    perf probe -l > /tmp/perf.data
    count_probe=`cat $report_path |grep probe|wc -l`
    if [ $cpunum -gt 1 ];then
        count_probe=`expr $count_probe - 2`
    fi
    if [ $count_probe -ne $SUB ];then
        {
            echo "perf probe -f -a schedule command error"
            ret=$((ret+1))
            return 1
        }
    else
        {
            echo "TEST Succeed"
            return 0
        }
    fi
}

doclean()
{
    rm $report_path -rf
	[ -e perf.data ] && rm perf.data* -rf
    perf probe -d schedule*
    perf probe -d __kmalloc*
    echo "clean all the dirty file"
}

dorm()
{
	point=`perf probe -l|grep probe |awk '{print $1}'`
	for i in $point
		do
			{
				perf probe -d $i
			}
		done
}
dorm
dotest
doclean
exit $ret
