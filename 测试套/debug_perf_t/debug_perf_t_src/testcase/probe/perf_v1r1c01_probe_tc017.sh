#!/bin/bash

report_path=/tmp/perf.data
vmlinux_path=/tmp/vmlinux
ret=0
cp ${TCBIN}../config/vmlinux /tmp/
dotest()
{
    perf probe -a hellowrold -k $vmlinux_path
    if [ $? -eq 0 ];then
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
	[ -e perf.data ] && rm perf.data* -rf
    perf probe -d schedule*
    rm $vmlinux_path
    echo "clean all the dirty file"
}

dotest
doclean
exit $ret
