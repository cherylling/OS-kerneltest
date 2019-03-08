#!/bin/bash

report_path=/tmp/perf.data
ret=0

dotest()
{
    perf probe -a schedule
    perf probe -f -a schedule
    perf probe -f -a schedule
    perf probe -f -a schedule
    perf probe -f -a schedule
    perf probe -f -a schedule
    perf probe -f -a schedule
    perf probe -f -a schedule
    perf probe -f -a schedule
    perf probe -f -a schedule
    perf probe -l > /tmp/perf.data 2>&1

    count_probe=`cat $report_path |grep probe:schedule|wc -l`
    if [ $count_probe -ne 10 ];then
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
