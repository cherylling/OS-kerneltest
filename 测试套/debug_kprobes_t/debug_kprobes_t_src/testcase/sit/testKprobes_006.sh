#!/bin/bash

. conf.sh

KO=testKprobes_006.ko
grep_dmesg="register_kprobe pass"
echo_mesg="register_kprobe fail"
grep_dmesg11="pre_handler"
grep_dmesg12="post_handler"
echo_mesg1="Active kprobe failed!"
grep_dmesg2="jprobe_do_fork"
echo_mesg21="Active jprobe failed within expectation."
echo_mesg22="Active jprobe succeed without expectation."
grep_dmesg2="jprobe_do_fork"
grep_dmesg31="entry_handler"
grep_dmesg32="ret_handler"
echo_mesg31="Active kretprobe failed within expectation."
echo_mesg32="Active kretprobe succeed without expectation."

set_up
insmod_success $KO || exit 1
if ! grep_mesg "$KO" "$grep_dmesg" "$echo_mesg" ; then
        clean_up $KO
        exit 1
fi

ls > /dev/null
if ! grep_mesg "$KO" "$grep_dmesg11" "$echo_mesg1" "$grep_dmesg12" ; then
        clean_up $KO
        exit 1
fi

if  grep_mesg "$KO" "$grep_dmesg2" "$echo_mesg21" ; then
	echo $echo_mesg22
        clean_up $KO
        exit 1
fi

if  grep_mesg "$KO" "$grep_dmesg31" "$echo_mesg31" "$grep_dmesg32" ; then
	echo $echo_mesg32
        clean_up $KO
        exit 1
fi

rmmod_ko $KO || exit 1

exit 0
