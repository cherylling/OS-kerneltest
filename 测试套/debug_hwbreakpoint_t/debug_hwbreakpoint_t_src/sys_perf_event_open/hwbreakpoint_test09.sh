#!/bin/bash

#
# test for hw_breakpoint
# Description:
#

kernel_addr=
log_file=hwbreakpoint.log
RET=0

setup()
{
	dmesg -c

	insmod alloc_pages.ko || RET=$(($RET+1))
	
	# Get the addr
	alloc_addr=`dmesg |grep "alloc_pages" |awk -F"=" '{print $2}'`
	if [ $? -ne 0 ]; then
		RET=$(($RET+1))
	fi
}

do_test()
{
        insmod kmap_test.ko p_addr=0x$alloc_addr >/dev/null
        if [ $? -ne 0 ]; then
                RET=$(($RET+1))
        fi

	# Get the addr
        kernel_addr=`dmesg |grep "kmap" |awk -F"addr:" '{print $2}'`
        if [ $? -ne 0 ]; then
                RET=$(($RET+1))
        fi

	# set breakpoint_w at kernel_addr first
	./set_breakpoint_w $kernel_addr > $log_file 2>&1 &
	pid=$!

	sleep 2

	insmod read_mem.ko addr=0x$kernel_addr >/dev/null
	if [ $? -ne 0 ]; then
                RET=$(($RET+1))
        fi

	sleep 30

	# check the message in log_file
	cat $log_file |grep "CALLCHAIN LEVEL 0"
	if [ $? -eq 0 ]; then
		RET=$(($RET+1))
		kill -9 $pid
	fi

	insmod set_mem.ko addr=0x$kernel_addr size=1 >/dev/null
        if [ $? -ne 0 ]; then
                RET=$(($RET+1))
        fi

        sleep 5

        # check the message in log_file
        cat $log_file |grep "CALLCHAIN LEVEL 0"
        if [ $? -ne 0 ]; then
                RET=$(($RET+1))
                kill -9 $pid
        fi

	rmmod read_mem
	rmmod set_mem
	rmmod kmap_test
	rm $log_file
}

clean()
{
	rmmod alloc_pages
}

setup
do_test
clean

exit $RET
