#!/bin/bash

. conf.sh

KO=testKretprobe_005.ko
grep_dmesg1="register_kretprobe pass"
echo_mesg1="register_kretprobe failed!"
grep_dmesg21="ret_handler"
grep_dmesg22="entry_handler"
echo_mesg2="Active_kretprobe failed!"

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
