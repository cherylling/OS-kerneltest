#!/bin/bash

echo p > /proc/sysrq-trigger

dmesg | tail -500 |  grep "SysRq : Show Regs"

if [ $? -ne 0  ];then
	echo "Test FAILED: sysrq p test fialed, no regs info showed."
	exit 1
fi

exit 0
