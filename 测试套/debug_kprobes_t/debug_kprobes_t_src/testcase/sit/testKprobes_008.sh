#!/bin/bash

. conf.sh

KO=testKprobes_008.ko
pre_KO=testKprobes_008-A.ko

set_up
mount_debugfs
insmod_success $pre_KO || exit 1
insmod_success $KO || exit 1

rmmod_ko $pre_KO || exit 1
cat /sys/kernel/debug/kprobes/list | grep "GONE"
if [ $? -ne 0 ];then
	echo "the status failed"
	clean_up $pre_KO
	clean_up $KO
	exit 1
fi

insmod_success $pre_KO || exit 1
cat /sys/kernel/debug/kprobes/list | grep "GONE"
if [ $? -ne 0 ];then
        echo "the status failed"
        clean_up $pre_KO
        clean_up $KO
        exit 1
fi


rmmod_ko $pre_KO || exit 1
rmmod_ko $KO || exit 1

exit 0
