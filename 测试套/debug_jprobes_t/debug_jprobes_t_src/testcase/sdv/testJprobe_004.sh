#!/bin/bash

. conf.sh

KO=testJprobe_004.ko
grep_dmesg1="jprobe_do_fork"
echo_mesg1_1="disable jprobe succeed!"
echo_mesg1_2="disable jprobe failed!"
grep_dmesg2="jprobe_do_settime"
echo_mesg2="enable jprobe failed!"

set_up
mount_debugfs
echo 0 > /sys/kernel/debug/kprobes/enabled
insmod_success $KO || exit 1

echo 1 > /sys/kernel/debug/kprobes/enabled
ls > /dev/null
if  grep_mesg "$KO" "$grep_dmesg1" "$echo_mesg1_1" ; then
	echo $echo_mesg1_2
        clean_up $KO
        exit 1
fi
date -s `date | awk '{print $4}'`
if ! grep_mesg "$KO" "$grep_dmesg2" "$echo_mesg2" ; then
        clean_up $KO
        exit 1
fi

rmmod_ko $KO || exit 1

exit 0
