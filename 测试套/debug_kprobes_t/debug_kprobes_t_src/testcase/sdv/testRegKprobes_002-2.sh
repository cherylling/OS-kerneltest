#!/bin/bash

. conf.sh

KO=testRegKprobes_002-2.ko
grep_dmesg1="register_kprobes pass"
echo_mesg1="register_kprobes failed!"

set_up
insmod_success $KO || exit 1
if ! grep_mesg "$KO" "$grep_dmesg1" "$echo_mesg1" ; then
        clean_up $KO
        exit 1
fi

rmmod_ko $KO || exit 1

exit 0
