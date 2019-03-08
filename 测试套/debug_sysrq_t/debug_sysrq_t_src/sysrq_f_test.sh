#!/bin/bash

echo f > /proc/sysrq-trigger
sleep 10
dmesg | tail -500 |  grep "Out of memory"

if [ $? -ne 0  ];then
	echo "Test FAILED: OOM, sysrq f test fialed."
	exit 1
fi

exit 0
