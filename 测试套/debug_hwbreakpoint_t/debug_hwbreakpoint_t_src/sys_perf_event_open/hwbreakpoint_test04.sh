#!/bin/bash

#
# test for hw_breakpoint
# Description:
# 	Set breakpoint in out-of-tree module addr,
#	perf_event_open() will pass
#

kernel_addr=
log_file=hwbreakpoint.log
RET=0

setup()
{
	insmod export_hello.ko || RET=$(($RET+1))
	

	# Get the linux_proc_banner addr
	kernel_addr=`cat /proc/kallsyms |grep "__kstrtab_myhello" |awk -F" " '{print $1}'`
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
	insmod use_hello.ko >/dev/null
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

	rmmod use_hello
	rm $log_file
}

clean()
{
	rmmod export_hello
}

setup
do_test
clean

exit $RET
