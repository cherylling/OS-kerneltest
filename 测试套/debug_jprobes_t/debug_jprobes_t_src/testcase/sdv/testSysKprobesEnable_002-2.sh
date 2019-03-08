#!/bin/bash

. conf.sh

KO=testSysKprobesEnable_002-2.ko
grep_dmesg="register_jprobe pass"
echo_mesg="register_jprobe failed!"
grep_dmesg1="jprobe_do_fork"
echo_mesg1="Active jprobe fail"

set_up
echo 0 > /sys/kernel/debug/kprobes/enabled

insmod_success $KO || exit 1
if ! grep_mesg "$KO" "$grep_dmesg" "$echo_mesg" ; then
        clean_up $KO
        exit 1
fi

ls > /dev/null
if  grep_mesg "$KO" "$grep_dmesg1" "$echo_mesg1" ; then
        clean_up $KO
        exit 1
fi

echo 1 > /sys/kernel/debug/kprobes/enabled
if [ $? -ne 0 ];then
        echo "enable jprobe fail"
	clean_up $KO
        exit 1
fi
ls > /dev/null
if ! grep_mesg "$KO" "$grep_dmesg1" "$echo_mesg1" ; then
        clean_up $KO
        exit 1
fi

rmmod_ko $KO || exit 1

exit 0
