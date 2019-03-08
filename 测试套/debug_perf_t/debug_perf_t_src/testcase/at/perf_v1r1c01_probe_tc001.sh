#!/bin/bash

report_path=/tmp/report.data
perf_data_path=/tmp/perf.data
ret=0

dotest()
{
    perf probe -a schedule
    perf record -o $perf_data_path -e probe:schedule -aR sleep 1
    perf report -i $perf_data_path > $report_path
    cat $report_path |grep "probe:schedule"
    if [ $? -ne 0 ];then
        {
            echo "can not add a probe in -a"
            ret=$((ret+1))
            return 1
        }
    else
        {
            echo "TEST Succeed"
            return 0
        }
    fi
    cat $report_path |grep "100.00%"
    if [ $? -eq 0 ]; then
        {
            echo perf read write val error
            ret=$((ret+1))
        }
    else
        {
            echo perf rw val succeed
        }
    fi
    perf record -e probe:schedule sleep 1
    if [ $? -ne 0 ];then
        {
            echo perf record fail
            ret=$((ret+1))
        }
    fi

    perf report|grep "100.00%"
    if [ $? -ne 0 ]; then
        {
            echo perf read write val error
            ret=$((ret+1))
        }
    else
        {
            echo perf rw val succeed
        }
    fi
}

doclean()
{
    rm $report_path -rf
    rm $perf_data_path -rf
    perf probe -d schedule
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
