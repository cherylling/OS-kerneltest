#!/bin/bash

. conf.sh

KO=testKprobes_007.ko
grep_dmesg11="pre_handler"
grep_dmesg12="post_handler"
echo_mesg1="Active kprobe failed!"
grep_dmesg2="jprobe_do_fork"
echo_mesg2="Active jprobe failed!"
grep_dmesg31="ret_handler"
grep_dmesg32="entry_handler"
echo_mesg3="Active kretprobe failed!"

set_up
insmod_success $KO || exit 1

ls > /dev/null
if ! grep_mesg "$KO" "$grep_dmesg11" "$echo_mesg1" "$grep_dmesg12" ; then
        clean_up $KO
        exit 1
fi

if ! grep_mesg "$KO" "$grep_dmesg2" "$echo_mesg2" ; then
        clean_up $KO
        exit 1
fi

if ! grep_mesg "$KO" "$grep_dmesg31" "$echo_mesg3" "$grep_dmesg32" ; then
        clean_up $KO
        exit 1
fi

rmmod_ko $KO || exit 1

exit 0
