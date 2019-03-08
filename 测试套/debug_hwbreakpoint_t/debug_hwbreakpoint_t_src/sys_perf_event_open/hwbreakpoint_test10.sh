#!/bin/bash

#
# test for hw_breakpoint
# Description:
#

kernel_addr=
log1_file=hwbreakpoint1.log
log2_file=hwbreakpoint2.log
log3_file=hwbreakpoint3.log
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
	./set_breakpoint $kernel_addr > $log1_file 2>&1 &
	pid1=$!

	./set_breakpoint $kernel_addr > $log2_file 2>&1 &
        pid2=$!

	./set_breakpoint $kernel_addr > $log3_file 2>&1 &
        pid3=$!

	sleep 2

	# read the message nfsstate (addr is $kernel_addr)
	insmod read_mem.ko addr=0x$kernel_addr >/dev/null
	if [ $? -ne 0 ]; then
                RET=$(($RET+1))
        fi

	sleep 30

	# check the message in log_file
	cat $log1_file |grep "CALLCHAIN LEVEL 0" &&
		cat $log2_file |grep "CALLCHAIN LEVEL 0" &&
		cat $log3_file |grep "CALLCHAIN LEVEL 0"
	if [ $? -ne 0 ]; then
		RET=$(($RET+1))
		kill -9 $pid1
		kill -9 $pid2
		kill -9 $pid3
	fi

	rmmod read_mem
	rm $log1_file $log2_file $log3_file
}

clean()
{
	rmmod hwbreakpoint_test07
}

setup
do_test
clean

exit $RET
