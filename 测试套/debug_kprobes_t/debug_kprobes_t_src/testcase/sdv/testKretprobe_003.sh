#!/bin/bash

. conf.sh

KO=testKretprobe_003.ko
grep_dmesg11="ret_handler1"
grep_dmesg12="entry_handler1"
echo_mesg1="Active_kretprobe failed!"

grep_dmesg21="ret_handler2"
grep_dmesg22="entry_handler2"
echo_mesg21="Disable_kretprobe succeed!"
echo_mesg2="Disable_kretprobe failed!"

set_up
mount_debugfs
insmod_success $KO || exit 1

cat /sys/kernel/debug/kprobes/list | grep "cpuinfo_open+0x0    \[DISABLED\]" && \
cat /sys/kernel/debug/kprobes/list | grep "do_fork+0x0"
if [ $? -ne 0 ];then
        echo "enable kretprobe failed!"
        clean_up $KO
        exit 1
fi

ls > /dev/null
if ! grep_mesg "$KO" "$grep_dmesg11" "$echo_mesg1" "$grep_dmesg12" ; then
        clean_up $KO
        exit 1
fi
 
cat /proc/cpuinfo > /dev/null
if grep_mesg "$KO" "$grep_dmesg21" "$echo_mesg21" ; then
	echo $echo_mesg22
        clean_up $KO
        exit 1
fi

if grep_mesg "$KO" "$grep_dmesg22" "$echo_mesg21" ; then
        echo $echo_mesg22
        clean_up $KO
        exit 1
fi


rmmod_ko $KO || exit 1

exit 0
