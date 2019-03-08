#!/bin/bash

cmd_line="/proc/cmdline"
nmi_watchdog_file=/proc/sys/kernel/nmi_watchdog
nmi_orign_status=0

check_nmi_enable()
{
	RET=0

	grep "nmi_watchdog=1" ${cmd_line} || RET=1
	grep "nmi_watchdog=2" ${cmd_line} || RET=2
	grep "nmi_watchdog=panic" ${cmd_line} || RET=3
	grep "nmi_watchdog=nopanic" ${cmd_line} || RET=4	

	if [ ${RET} ];then
		echo "Test SKIP: nmi_watch_dog not enabled, please add nmi_watchdog=xx to bootargs."
		return ${RET}
	fi
	return 0
}

check_panic_on_nmi()
{
	grep "nmi_watchdog=panic" ${cmd_line} && return 1
	return 0
}

enable_nmi()
{
	echo 1 > ${nmi_watchdog_file}
}

disable_nmi()
{
	echo 0 > ${nmi_watchdog_file}
}

restore_nmi_status()
{
	echo ${nmi_orign_status} > ${nmi_watchdog_file}
}

save_nmi_status()
{
	nmi_orign_status=`cat ${nmi_watchdog_file}`
}
