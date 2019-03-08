#!/bin/bash

insmod ${TCBIN}../module/kernel_module.ko
cp ${TCBIN}../module/kernel_module.ko /tmp

report_path=/tmp/perf.data
vmlinux_path=/tmp/vmlinux
ret=0

dotest()
{
    dmesg -c
    cat /proc/mykthread_free_enable
    result=`dmesg |awk '{print $3}'`
    dmesg -c
    perf probe -m /tmp/kernel_module.ko planck_free_read
    perf record -e probe:planck_free_read -aR cat /proc/mykthread_free_enable
    re=`dmesg|awk '{print $3}'`
    if [ $result -ne $re ];then
        {
            echo "perf probe -m   function command error"
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
