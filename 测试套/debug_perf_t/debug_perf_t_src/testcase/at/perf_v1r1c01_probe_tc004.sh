#!/bin/bash

report_path=/tmp/perf.data
ret=0

dotest()
{
    perf probe -a schedule
    perf probe -a __kmalloc
    perf probe -l > /tmp/perf.data
    perf probe -d schedule
    if [ $? -ne 0 ];then
        {
            echo "perf probe -d schedule command error"
            ret=$((ret+1))
            return 1
        }
    else
        {
            echo "TEST Succeed"
        }
    fi
    perf probe -d __kmalloc
    if [ $? -ne 0 ];then
        {
            echo "perf probe -d __kmalloc command error"
            ret=$((ret+1))
            return 1
        }
    else
        {
            echo "TEST Succeed"
        }
    fi
    perf probe -d cpu_planck
    if [ $? -eq 0 ];then
        {
            echo "perf probe -d cpu_planck command error"
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
