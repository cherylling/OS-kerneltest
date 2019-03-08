#!/bin/bash

echo q > /proc/sysrq-trigger

dmesg | tail -500 |  grep "Tick Device: mode"

if [ $? -ne 0  ];then
	echo "Test FAILED: sysrq q test fialed, no timer info showed."
	exit 1
fi

exit 0
