#!/bin/bash
######################################################################
# Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
# File name:   perf_v1r2c00_record-e_common.sh
# Author1:     y00197803
# Date:        2013-04-16
# Description: FIX ME, Tell me what this program will do
######################################################################

######################################################################
# Description: must create the directory TCTMP
#    arg1: file name:event.report, eg:cpu-clock.report
#    arg2: event to check, eg:cpu-clock
#    arg3: command
######################################################################
check_event_keyinfo()
{
	local rc=0
	report=$1
	event_chk=$2
	if [ "$event_chk" == "cpu-migrations" -o "$event_chk" == "migrations" ];then
		cpuNum=`cat /proc/cpuinfo | grep -i "processor[[:blank:]]\{1,\}:[[:blank:]]\{1,\}[[:digit:]]" | wc -l`
		[ $cpuNum -le 2 ] && return 0
	fi

	echo "$event_chk" | grep "^LLC-.*"
	if [ $? -eq 0 ];then
		uname -a | grep "x86"
		if [ $? -eq 0 ];then
			return 0
		fi
	fi

	cd ${TCTMP}
	for element in "Samples:" Overhead Command Shared Object Symbol $3;do
		grep ${element} $report > /dev/null 2>&1
		if [ $? -ne 0 ];then
			echo "TINFO: event ${event_chk} missing element ${element}"
			rc=$((rc + 1))
		fi
	done
	return $rc
}

######################################################################
# Description: check events
######################################################################
check_event_event()
{
	local rc=0
	report=$1
	event_chk=$2
	if [ "$event_chk" == "cpu-migrations" -o "$event_chk" == "migrations" ];then
		cpuNum=`cat /proc/cpuinfo | grep -i "processor[[:blank:]]\{1,\}:[[:blank:]]\{1,\}[[:digit:]]" | wc -l`
		[ $cpuNum -le 2 ] && return 0
	fi

	echo "$event_chk" | grep "^LLC-.*"
	if [ $? -eq 0 ];then
		uname -a | grep "x86"
		if [ $? -eq 0 ];then
			return 0
		fi
	fi

	cd ${TCTMP}
	grep $event_chk $report >/dev/null 2>&1
	if [ $? -eq 0 ];then
		echo "TPASS: event ${event_chk} checked"
	else
		echo "TINFO: event ${event_chk} missing element ${event_chk}"
		rc=$((rc + 1))
	fi
	return $rc
}
