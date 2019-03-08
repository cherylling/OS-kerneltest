#!/bin/bash

. conf.sh

KO=testKretprobe_007.ko
grep_dmesg11="ret_handler1"
grep_dmesg12="entry_handler1"
echo_mesg1="Active_kretprobe 1 failed!"
grep_dmesg21="ret_handler2"
grep_dmesg22="entry_handler2"
echo_mesg2="Active_kretprobe 2 failed!"
grep_dmesg31="ret_handler3"
grep_dmesg32="entry_handler3"
echo_mesg3="Active_kretprobe 3 failed!"

set_up
insmod_success $KO || exit 1

num=`dmesg | grep "register_kretprobe pass" | wc -l`
if [ $num -ne 3 ];then
	echo "Set kretprobe failed!"
	clean_up $KO
	exit 1
fi

ls > /dev/null
if ! grep_mesg "$KO" "$grep_dmesg11" "$echo_mesg1" "$grep_dmesg12" ; then
        clean_up $KO
        exit 1
fi
ls > /dev/null
if ! grep_mesg "$KO" "$grep_dmesg21" "$echo_mesg2" "$grep_dmesg22" ; then
        clean_up $KO
        exit 1
fi
ls > /dev/null
if ! grep_mesg "$KO" "$grep_dmesg31" "$echo_mesg3" "$grep_dmesg32" ; then
        clean_up $KO
        exit 1
fi

rmmod_ko $KO || exit 1

exit 0
