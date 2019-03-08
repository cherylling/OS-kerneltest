#!/bin/bash

echo 0 > /sys/kernel/debug/kprobes/enabled
if [ $? -ne 0 ];then
	echo "enable kprobe fail"
	exit 1
fi

echo 1 > /sys/kernel/debug/kprobes/enabled
if [ $? -ne 0 ];then
        echo "enable kprobe fail"
        exit 1
fi

echo "yes" > /sys/kernel/debug/kprobes/enabled
if [ $? -ne 0 ];then
        echo "enable kprobe fail"
        exit 1
fi

echo -1 > /sys/kernel/debug/kprobes/enabled
if [ $? -eq 0 ];then
        echo "enable kprobe fail"
        exit 1
fi

echo 2 > /sys/kernel/debug/kprobes/enabled
if [ $? -eq 0 ];then
        echo "enable kprobe fail"
        exit 1
fi

exit 0
