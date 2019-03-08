#!/bin/bash

echo m > /proc/sysrq-trigger

dmesg | tail -500 |  grep "SysRq : Show Memory"

if [ $? -ne 0  ];then
	echo "Test FAILED: sysrq m test fialed, no meminfo showed."
	exit 1
fi

exit 0
