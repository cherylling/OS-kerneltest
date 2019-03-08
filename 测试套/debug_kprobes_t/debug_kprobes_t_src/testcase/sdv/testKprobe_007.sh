#!/bin/bash

. conf.sh

KO=testKprobe_007.ko
grep_dmesg11="pre_handler"
grep_dmesg12="post_handler"
echo_mesg1="Active_kprobe failed!"

set_up
insmod_success $KO || exit 1

ls > /dev/null
if ! grep_mesg "$KO" "$grep_dmesg11" "$echo_mesg1" "$grep_dmesg12" ; then
        clean_up $KO
        exit 1
fi

rmmod_ko $KO || exit 1

exit 0
