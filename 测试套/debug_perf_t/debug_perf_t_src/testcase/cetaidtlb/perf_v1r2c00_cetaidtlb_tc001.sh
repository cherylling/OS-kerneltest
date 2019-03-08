#!/bin/bash
#======================================================
# Author: dingzengjian - d00228505
# 
# Last modified: 2013-12-21 15:11
# 
# Filename: perf_v1r2c00_cetaidtlb_tc001.sh
# 
# Description:  
#    DTS2013121010510 
#======================================================

RET=0
setenv(){
	exe=cs_test
	repeat_time=10000
	default_total=`cat /proc/meminfo | grep HugePages_Total | awk '{print $2}'`
	default_free=`cat /proc/meminfo | grep HugePages_Free | awk '{print $2}'`
	page_will_use=10
	if [ "x${default_total}" != "x${default_free}" ];then
		echo "FAIL: Somebody is using hugepage"
		return 1
	fi

	echo $page_will_use > /proc/sys/vm/nr_hugepages
}

do_test(){
	# bootup 10 time exe to use all pages
	for i in `seq $page_will_use`
	do
		./$exe & 
	done

	for i in `seq $repeat_time`
	do
		./$exe & >/dev/null 2>&1
		pid=$!
		perf record -p $pid  > /dev/null 2>&1
	done
}
cleanup(){
	killall $exe 
	while [ 1 ]
	do
		ps -eo pid,cmd | grep -v grep | grep $exe
		if [ $? -ne 0 ];then
			break
		fi
	done

	echo $default_total > /proc/sys/vm/nr_hugepages
}

setenv && do_test
RET=$?
cleanup
exit $RET

