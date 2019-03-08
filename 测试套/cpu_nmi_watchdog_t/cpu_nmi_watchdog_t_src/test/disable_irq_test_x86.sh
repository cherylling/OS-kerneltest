#!/bin/bash

. ./lib.sh

check_nmi_enable
if [ $? -ne 0 ];then
	exit 1
fi

check_panic_on_nmi
if [ $? -ne 0 ];then
	echo "Test SKIPED: nmi_watchdog=panic, need manul test."
        exit 1
fi

save_nmi_status
enable_nmi

insmod disable_irq.ko
sleep 60
dmesg | tail -500 | grep "Watchdog detected hard LOCKUP"
if [ $? -ne 0 ];then
	echo "Test FAILED: no message logged for hard lockup."
	restore_nmi_status
	exit 1
fi

echo "Test PASSED: disable irq test successfully."
restore_nmi_status
exit 0
