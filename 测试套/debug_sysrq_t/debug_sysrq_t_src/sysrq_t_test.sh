#!/bin/bash

echo t > /proc/sysrq-trigger

dmesg | tail -500 |  grep "runnable tasks:"

if [ $? -ne 0  ];then
	echo "Test FAILED: sysrq t test fialed, no tasks listed."
	exit 1
fi

exit 0
