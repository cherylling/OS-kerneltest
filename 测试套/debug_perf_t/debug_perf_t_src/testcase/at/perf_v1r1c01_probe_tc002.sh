#!/bin/bash

report_path=/tmp/perf.data
ret=0

dotest()
{
    perf probe -a schedule
    perf probe -a cpu_down
    perf probe -l > /tmp/perf.data
    #perf record -e probe:schedule -aR sleep 1
    #perf report > $report_path
    cat $report_path |grep "probe:schedule" && cat $report_path |grep "probe:cpu_idle" 
    if [ $? -eq 0 ];then
        {
            echo "can not add a probe or perf probe -l error"
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
    perf probe -d schedule
    perf probe -d cpu_down
    echo "clean all the dirty file"
}

dotest
doclean
exit $ret
