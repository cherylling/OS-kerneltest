#!/bin/bash

. conf.sh

KO=testRegKprobe_010-1.ko
grep_dmesg1="register_kprobe pass"
echo_mesg1="register_kprobe failed!"
grep_dmesg2="pre_handler"
echo_mesg2_1="Disable kprobe succeed."
echo_mesg2_2="Active kprobe failed!"

set_up
insmod_success $KO || exit 1
if ! grep_mesg "$KO" "$grep_dmesg1" "$echo_mesg1" ; then
        clean_up $KO
        exit 1
fi

ls > /dev/null
if grep_mesg "$KO" "$grep_dmesg2" "$echo_mesg2_1" ; then
	echo $echo_mesg2_2
        clean_up $KO
        exit 1
fi

rmmod_ko $KO || exit 1

exit 0
