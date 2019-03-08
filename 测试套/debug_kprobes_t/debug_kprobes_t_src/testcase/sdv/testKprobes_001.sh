#!/bin/bash

. conf.sh

KO=testKprobes_001.ko
grep_dmesg1="register_probes pass"
echo_mesg1="register_probes failed!"
grep_dmesg21="pre_handler"
grep_dmesg22="post_handler"
echo_mesg2="Active_kprobe failed!"
grep_dmesg3="jprobe_do_fork"
echo_mesg3="Active_jprobe failed!"
grep_dmesg41="entry_handler"
grep_dmesg42="ret_handler"
echo_mesg4="Active_kretprobe failed!"

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

if ! grep_mesg "$KO" "$grep_dmesg3" "$echo_mesg3" ; then
        clean_up $KO
        exit 1
fi

if ! grep_mesg "$KO" "$grep_dmesg41" "$echo_mesg4" "$grep_dmesg42" ; then
        clean_up $KO
        exit 1
fi

rmmod_ko $KO || exit 1

exit 0
