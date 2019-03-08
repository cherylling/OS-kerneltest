#!/bin/bash

. ./lib.sh

test_nmi_irq()
{
	cat /proc/interrupts | grep NMI > irq_orig
	sleep 60
	cat /proc/interrupts | grep NMI > irq_new

	diff irq_orig irq_new
	if [ $? -eq 0 ];then
		rm -rf irq_orig  irq_new
		return 1
	fi
	rm -rf irq_orig  irq_new
	return 0
}


check_nmi_enable
if [ $? -ne 0 ];then
	exit 1
fi

save_nmi_status
enable_nmi

test_nmi_irq
if [ $? -ne 0 ];then
	echo "Test FAILED: NMI irq not increased."
	restore_nmi_status
	exit 1
fi

echo "Test PASSED: NMI irq responed successfully."
restore_nmi_status
exit 0
