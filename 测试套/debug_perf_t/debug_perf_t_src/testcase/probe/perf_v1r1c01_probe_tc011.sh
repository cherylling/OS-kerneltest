#!/bin/bash

insmod ${TCBIN}../module/kernel_module_unexport.ko
cp ${TCBIN}../module/kernel_module_unexport.ko /tmp

report_path=/tmp/perf.data
vmlinux_path=/tmp/vmlinux
ret=0

dotest()
{
    perf probe -m /tmp/kernel_module_unexport.ko planck_free_read_unexport 
    if [ $? -ne 0 ];then
        {
            echo "perf probe -m a unexport  function command error"
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
    rmmod kernel_module_unexport
    rm /tmp/kernel_module_unexport.ko
    perf probe -d planck*
    echo "clean all the dirty file"
}

dotest
doclean
exit $ret
