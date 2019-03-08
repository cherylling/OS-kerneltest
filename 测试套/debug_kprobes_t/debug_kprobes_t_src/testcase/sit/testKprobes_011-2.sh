#!/bin/bash

. conf.sh

KO=testJprobe_001.ko
grep_dmesg="register_jprobe pass"
echo_mesg="register_jprobe failed!"

for num in `seq 0 1 100`
do
        set_up
        insmod_success $KO || exit 1

        if ! grep_mesg "$KO" "$grep_dmesg" "$echo_mesg" ; then
                clean_up $KO
                exit 1
        fi

        rmmod_ko $KO || exit 1
done
exit 0

