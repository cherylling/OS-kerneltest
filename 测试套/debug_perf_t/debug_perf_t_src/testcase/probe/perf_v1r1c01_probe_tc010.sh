#!/bin/bash

insmod ${TCBIN}../module/kernel_module.ko
cp ${TCBIN}../module/kernel_module.ko /tmp

report_path=/tmp/perf.data
vmlinux_path=/tmp/vmlinux
ret=0

dotest()
{
    perf probe -m /tmp/kernel_module.ko planck_free 
    if [ $? -eq 0 ];then
        {
            echo "perf probe -m a not exsit function command error"
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
    rm /tmp/kernel_module.ko
    rmmod kernel_module
    perf probe -d planck*
    echo "clean all the dirty file"
}

dotest
doclean
exit $ret
