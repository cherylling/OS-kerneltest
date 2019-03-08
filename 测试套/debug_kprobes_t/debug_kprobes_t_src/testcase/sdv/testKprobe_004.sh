#!/bin/bash

. conf.sh

KO=testKprobe_004.ko
grep_dmesg1_1="pre_handler1"
grep_dmesg1_2="post_handler1"
echo_mesg1_1="disable_kprobe kp1 failed"
echo_mesg1_2="disable_kprobe kp1 succeed"
grep_dmesg2_1="pre_handler2"
grep_dmesg2_2="post_handler2"
echo_mesg2="Active kprobe kp2 failed!"

set_up
echo 0 > /sys/kernel/debug/kprobes/enabled

insmod_success $KO || exit 1

echo 1 > /sys/kernel/debug/kprobes/enabled
if [ $? -ne 0 ];then
        echo "enable kprobe failed!"
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
