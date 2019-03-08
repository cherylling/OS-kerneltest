#!/bin/bash

. conf.sh

KO=testKprobe_001.ko
grep_dmesg1="register_kprobe pass"
echo_mesg1="register_kprobe failed!"
grep_dmesg21="pre_handler"
grep_dmesg22="post_handler"
echo_mesg2="Active_kprobe failed!"

set_up
insmod_success $KO || exit 1
if ! grep_mesg "$KO" "$grep_dmesg1" "$echo_mesg1" ; then
        clean_up $KO
        exit 1
fi

ls > /dev/null
if ! grep_mesg "$KO" "$grep_dmesg21" "$echo_mesg2" "$grep_dmesg22" ; then
        clean_up $KO
        exit 1
fi
 
rmmod_ko $KO || exit 1

exit 0
