#!/bin/bash

. conf.sh

KO=testJprobe_003.ko
grep_dmesg1="jprobe_do_fork"
echo_mesg1="Active jprobe failed!"
grep_dmesg2="jprobe_do_settime"
echo_mesg2="disable jprobe succeed!"

set_up
mount_debugfs
insmod_success $KO || exit 1

cat /sys/kernel/debug/kprobes/list | grep "do_sys_settimeofday+0x0    \[DISABLED\]" && \
cat /sys/kernel/debug/kprobes/list | grep "do_fork+0x0" > /dev/null
if [ $? -ne 0 ];then
        echo "jprobe status failed!"
        clean_up $KO
        exit 1
fi
 
ls > /dev/null
if ! grep_mesg "$KO" "$grep_dmesg1" "$echo_mesg1" ; then
        clean_up $KO
        exit 1
fi

date -s `date | awk '{print $4}'`
if  grep_mesg "$KO" "$grep_dmesg2" "$echo_mesg2" ; then
        clean_up $KO
        exit 1
fi

rmmod_ko $KO || exit 1

exit 0
