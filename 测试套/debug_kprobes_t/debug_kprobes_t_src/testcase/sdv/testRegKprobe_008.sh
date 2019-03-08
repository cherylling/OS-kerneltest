#!/bin/bash

. conf.sh

KO=testRegKprobe_008.ko
grep_dmesg1="register_kprobe pass"
echo_mesg1="register_kprobe failed!"

for num in 0 
do
	set_up
	insmod_success "$KO p_offset=$num" || exit 1
	if ! grep_mesg "$KO" "$grep_dmesg1" "$echo_mesg1" ; then
        	clean_up $KO
        	exit 1
	fi

	rmmod_ko $KO || exit 1
done
exit 0
