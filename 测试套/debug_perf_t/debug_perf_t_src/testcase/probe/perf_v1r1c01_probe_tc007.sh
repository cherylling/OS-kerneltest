#!/bin/bash

report_path=/tmp/report.data
perf_data_path=/tmp/perf.data
vmlinux_path=../config/vmlinux
span_file=../config/perf_probe_schedule_spacing.cfg
ret=0
#cp ${TCBIN}../config/vmlinux /tmp/
dotest()
{
	span=`cat $span_file |sed -n '4p'`
    perf probe -a schedule+$spqn -k $vmlinux_path
    perf record -o $perf_data_path -e probe:schedule -aR sleep 1
    perf report -i $perf_data_path > $report_path
    cat $report_path |grep probe:schedule
    if [ $? -ne 0 ];then
        {
            echo "perf probe -k -a schedule command error"
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
    rm $perf_data_path -rf
    perf probe -d schedule*
#    rm $vmlinux_path -rf
    echo "clean all the dirty file"
}

dotest
doclean
exit $ret
