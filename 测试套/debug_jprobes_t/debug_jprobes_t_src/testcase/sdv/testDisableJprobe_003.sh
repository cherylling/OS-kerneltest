#!/bin/bash

. conf.sh

KO=testDisableJprobe_003.ko
grep_dmesg="disable_jprobe pass"
echo_mesg="disable jprobe test fail!"

set_up
insmod_success $KO || exit 1

if ! grep_mesg "$KO" "$grep_dmesg" "$echo_mesg" ; then
        clean_up $KO
        exit 1
fi

rmmod_ko $KO || exit 1

exit 0
