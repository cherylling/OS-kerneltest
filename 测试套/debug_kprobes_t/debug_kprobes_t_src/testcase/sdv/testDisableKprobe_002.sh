#!/bin/bash

. conf.sh

KO=testDisableKprobe_002.ko
grep_dmesg="disable_kprobe pass"
echo_mesg="disable kprobe test failed!"

set_up
insmod_success $KO || exit 1

if ! grep_mesg "$KO" "$grep_dmesg" "$echo_mesg" ; then
        clean_up $KO
        exit 1
fi

rmmod_ko $KO || exit 1

exit 0
