#!/bin/bash

. conf.sh

KO=testRegJprobes_003.ko
grep_dmesg1="register_jprobes pass"
echo_mesg1="register_jprobes failed!"

set_up
insmod_success "$KO num=3" || exit 1

if ! grep_mesg "$KO" "$grep_dmesg1" "$echo_mesg1" ; then
        clean_up $KO
        exit 1
fi

rmmod_ko $KO || exit 1

exit 0
