#!/bin/bash

#
# test for hw_breakpoint
# Description:
# 	Set breakpoint in kernel module addr, perf_event_open()
# 	will pass
#

kernel_addr=
log_file=hwbreakpoint.log
RET=0

setup()
{
	# test for nfsd modules
	modprobe nfsd

	# Get the addr
	kernel_addr=`cat /proc/kallsyms |grep nfsdstats |awk -F" " '{print $1}'`
	if [ $? -ne 0 ]; then
		RET=$(($RET+1))
	fi
}

do_test()
{
	# set breakpoint at kernel_addr first
	./set_breakpoint $kernel_addr > $log_file 2>&1 &
	pid=$!
	sleep 2

	# read the message nfsstate (addr is $kernel_addr)
	nfsstat >/dev/null
	if [ $? -ne 0 ]; then
                RET=$(($RET+1))
        fi

	sleep 30

	# check the message in log_file
	cat $log_file |grep "CALLCHAIN LEVEL 0"
	if [ $? -ne 0 ]; then
		RET=$(($RET+1))
		kill -9 $pid
	fi

	rm $log_file
}

setup
do_test

exit $RET
