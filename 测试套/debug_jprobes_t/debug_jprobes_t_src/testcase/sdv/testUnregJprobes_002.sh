#!/bin/bash

. conf.sh

KO=testUnregJprobes_002.ko
grep_dmesg1="register_jprobes pass"
echo_mesg1="register_jprobes failed!"
#for num in -1 0 1 3 4
for num in 3
do
	set_up
	insmod_success "$KO num=3" || exit 1

	if ! grep_mesg "$KO" "$grep_dmesg1" "$echo_mesg1" ; then
     		clean_up $KO
        	exit 1
	fi

	rmmod_ko $KO || exit 1
done
exit 0
