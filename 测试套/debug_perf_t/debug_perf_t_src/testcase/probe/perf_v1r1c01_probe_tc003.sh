#!/bin/bash

report_path=/tmp/perf.data
ret=0

dotest()
{
    perf probe -v 2> /tmp/perf.data
    cat $report_path |grep -i "usage" 
    if [ $? -ne 0 ];then
        {
            echo "perf probe -v command error"
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

dotest
doclean
exit $ret
