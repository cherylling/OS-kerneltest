#!/bin/bash

insmod ${TCBIN}../module/kernel_module.ko
cp ${TCBIN}../module/kernel_module.ko /tmp

report_path=/tmp/perf.data
vmlinux_path=/tmp/vmlinux
ret=0

dotest()
{
    perf probe -m /tmp/kernel_module.ko planck_free_read 
    perf probe -l|grep planck_free_read
    if [ $? -ne 0 ];then
        {
            echo "perf probe -m  command error"
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
    perf probe -d planck*
    rm /tmp/kernel_module.ko
    rmmod kernel_module 
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
