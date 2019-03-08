#!/bin/bash

source ${TCBIN}./perf_v1r1c01_probe_common.sh
should_readonly

insmod ${TCBIN}../module/kernel_module.ko
cp ${TCBIN}../module/kernel_module.ko /tmp

report_path=/tmp/perf.data
vmlinux_path=/tmp/vmlinux
ret=0

dotest()
{
    perf probe -m /tmp/test1/kernel_module.ko planck_free_read
    if [ $? -eq 0 ];then
        {
            echo "perf probe -m wrong path  function command error"
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
    rmmod kernel_module
    rm /tmp/kernel_module.ko
    perf probe -d planck*
    echo "clean all the dirty file"
}

dotest
doclean
exit $ret
