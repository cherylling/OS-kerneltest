#!/bin/bash

. conf.sh

KO=testKprobes_011.ko
grep_dmesg11="pre_handler"
grep_dmesg12="post_handler"
echo_mesg1="active kprobe failed!"
grep_dmesg2="jprobe_do_fork"
echo_mesg2="active jprobe failed!"
grep_dmesg31="entry_handler"
grep_dmesg32="ret_handler"
echo_mesg3="active kretprobe failed!"

insmod_success $KO || exit 1

### active
for num in `seq 0 1 100`
do
	set_up

	ls > /dev/null
	if ! grep_mesg "$KO" "$grep_dmesg11" "$echo_mesg1" "$grep_dmesg12" ; then
                clean_up $KO
                exit 1
        fi

	if ! grep_mesg "$KO" "$grep_dmesg2" "$echo_mesg2" ; then
                clean_up $KO
                exit 1
        fi

	if ! grep_mesg "$KO" "$grep_dmesg31" "$echo_mesg3" "$grep_dmesg32" ; then
                clean_up $KO
                exit 1
        fi
done
	
rmmod_ko $KO || exit 1

exit 0
