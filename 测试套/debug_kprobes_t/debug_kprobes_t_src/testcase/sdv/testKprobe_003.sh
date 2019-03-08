#!/bin/bash

. conf.sh

KO=testKprobe_003.ko
grep_dmesg1_1="pre_handler1"
grep_dmesg1_2="post_handler1"
echo_mesg1="Active kprobe kp1 failed!"
grep_dmesg2_1="pre_handler2"
grep_dmesg2_2="post_handler2"
echo_mesg2_1="disable_kprobe kp2 failed"
echo_mesg2_2="disable_kprobe kp2 succeed"

set_up
mount_debugfs
insmod_success $KO || exit 1

cat /sys/kernel/debug/kprobes/list | grep "do_fork+0x0" && \
cat /sys/kernel/debug/kprobes/list | grep "cpuinfo_open+0x0    \[DISABLED\]"
if [ $? -ne 0 ];then
        echo "kprobe status error"
        clean_up $KO
        exit 1
fi
 
ls > /dev/null
if ! grep_mesg "$KO" "$grep_dmesg1_1" "$echo_mesg1" "$grep_dmesg1_2"; then
        clean_up $KO
        exit 1
fi

cat /proc/cpuinfo > /dev/null
if grep_mesg "$KO" "$grep_dmesg2_1" "$echo_mesg2_2"; then
        echo $echo_mesg2_1
        clean_up $KO
        exit 1
fi

if grep_mesg "$KO" "$grep_dmesg2_2" "$echo_mesg2_2"; then
        echo $echo_mesg2_1
        clean_up $KO
        exit 1
fi

rmmod_ko $KO || exit 1

exit 0
