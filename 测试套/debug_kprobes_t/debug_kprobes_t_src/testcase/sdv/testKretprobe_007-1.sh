#!/bin/bash

. conf.sh

KO=testKretprobe_007-1.ko
grep_dmesg="register_kretprobe 2 failed"

set_up
insmod_fail "$KO" "$grep_dmesg" || exit 1

num=`dmesg | grep "register_kretprobe pass" | wc -l`
if [ $num -lt 1 ];then
	echo "Set kretprobe failed!"
	clean_up $KO
	exit 1
fi

num=`dmesg | grep "register_kretprobe 2 pass" | wc -l`
if [ $num -ge 1 ];then
        echo "Set kretprobe failed!"
        clean_up $KO
        exit 1
fi

num=`dmesg | grep "register_kretprobe 3 pass" | wc -l`
if [ $num -ge 1 ];then
        echo "Set kretprobe failed!"
        clean_up $KO
        exit 1
fi

exit 0
