#!/bin/bash

#
# test for hw_breakpoint
# Description:
# 	Set breakpoint in static mem addr,
#	perf_event_open() will pass
#

kernel_addr=
log_file=hwbreakpoint.log
RET=0

setup()
{
	dmesg -c

	insmod hwbreakpoint_test05.ko || RET=$(($RET+1))
	
	# Get the addr
	kernel_addr=`dmesg |grep "static_str_addr" |awk -F"=" '{print $2}'`
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
	insmod set_mem.ko addr=0x$kernel_addr size=4096 >/dev/null
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

	rmmod set_mem
	rm $log_file
}

clean()
{
	rmmod hwbreakpoint_test05
}

setup
do_test
clean

exit $RET
