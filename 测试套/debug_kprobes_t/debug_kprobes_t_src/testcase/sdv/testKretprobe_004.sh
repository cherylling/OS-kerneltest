#!/bin/bash

. conf.sh

KO=testKretprobe_004.ko
grep_dmesg1_1="ret_handler1"
grep_dmesg1_2="entry_handler1"
echo_mesg1_1="Disable kretprobe failed!"
echo_mesg1_2="Disable kretprobe succeed!"
grep_dmesg2_1="ret_handler2"
grep_dmesg2_2="entry_handler2"
echo_mesg2="Active kretprobe failed!"

set_up
mount_debugfs
echo 0 > /sys/kernel/debug/kprobes/enabled
insmod_success $KO || exit 1

echo 1 > /sys/kernel/debug/kprobes/enabled
if [ $? -ne 0 ];then
        echo "enable kretprobe failed!"
        clean_up $KO
        exit 1
fi
 
ls > /dev/null
if grep_mesg "$KO" "$grep_dmesg1_1" "$echo_mesg1_2"; then
        echo $echo_mesg1_1
        clean_up $KO
        exit 1
fi

if grep_mesg "$KO" "$grep_dmesg1_2" "$echo_mesg1_2"; then
        echo $echo_mesg1_1
        clean_up $KO
        exit 1
fi

cat /proc/cpuinfo > /dev/null
if ! grep_mesg "$KO" "$grep_dmesg2_1" "$echo_mesg2" "$grep_dmesg2_2"; then
        clean_up $KO
        exit 1
fi

rmmod_ko $KO || exit 1

exit 0
