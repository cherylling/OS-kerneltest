#!/bin/bash

#
# test for hw_breakpoint
# Description:
# 	Set breakpoint in const mem addr,
#	perf_event_open() will pass
#

kernel_addr=
log_file=hwbreakpoint.log
RET=0

setup()
{
	dmesg -c

	insmod hwbreakpoint_test07.ko || RET=$(($RET+1))
	
	# Get the addr
	kernel_addr=`dmesg |grep "const_str_addr" |awk -F"=" '{print $2}'`
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
	insmod read_mem.ko addr=0x$kernel_addr >/dev/null
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

	rmmod read_mem
	rm $log_file
}

clean()
{
	rmmod hwbreakpoint_test07
}

setup
do_test
clean

exit $RET
