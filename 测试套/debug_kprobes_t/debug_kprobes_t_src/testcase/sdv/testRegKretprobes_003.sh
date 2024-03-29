#!/bin/bash

. conf.sh

KO=testRegKretprobes_003.ko
grep_dmesg="register_kretprobe pass"

for num in 2 3 
do
	set_up
	insmod_success "$KO num=$num" || exit 1

	if ! grep_mesg "$KO" "$grep_dmesg" "$echo_mesg" ; then
        	clean_up $KO
        	exit 1
	fi

	rmmod_ko $KO || exit 1
done

exit 0
