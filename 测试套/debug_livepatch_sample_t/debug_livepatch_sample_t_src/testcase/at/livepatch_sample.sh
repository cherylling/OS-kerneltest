#!/bin/bash

RET=0

klp_ko="livepatch_sample.ko"

if [ ! -f $klp_ko ]; then
	echo "can't find $klp_ko, build failed ?"
	exit 1
fi

## check before insmod
cat /proc/cmdline | grep "this has been live patched"
if [ $? -eq 0 ]; then
	exit 1
fi

###insmod
insmod $klp_ko
if [ $? -ne 0 ]; then
	ARCH=`uname -m`
	if [ $ARCH == "ppc" ];then
		dmesg | tail -n 5 | grep "less than limit"
		if [ $? -eq 0 ]; then
			echo "SUCCESS" && exit 0
		else
			echo "FAIL" && exit 1
		fi
	else
		echo "`dmesg | tail -n 1`"
		exit 1
	fi
fi

## check before patch
cat /proc/cmdline | grep "this has been live patched"
if [ $? -eq 0 ]; then
	exit 1
fi

###enable
name=`echo $klp_ko | awk -F'.' '{print $1}'`
klp_ko_name=`echo ${name//-/_}`
echo 1 > /sys/kernel/livepatch/$klp_ko_name/enabled

### check atfer patch
cat /proc/cmdline | grep "this has been live patched"
if [ $? -ne 0 ]; then
	exit 1
fi


cat /proc/livepatch/state | grep "enabled"
if [ $? -ne 0 ]; then
	exit 1
fi

###disable
echo 0 > /sys/kernel/livepatch/$klp_ko_name/enabled

### check atfer disable
cat /proc/cmdline | grep "this has been live patched"
if [ $? -eq 0 ]; then
	exit 1
fi

cat /proc/livepatch/state | grep "disabled"
if [ $? -ne 0 ]; then
	exit 1
fi

###rmmod
rmmod $klp_ko

### check atfer disable
cat /proc/cmdline | grep "this has been live patched"
if [ $? -eq 0 ]; then
	exit 1
fi

exit 0
