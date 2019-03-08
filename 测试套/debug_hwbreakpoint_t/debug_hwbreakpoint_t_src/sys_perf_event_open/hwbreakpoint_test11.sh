#!/bin/bash

#
# test for hw_breakpoint
# Description:
#

kernel_addr=
log1_file=hwbreakpoint1.log
log2_file=hwbreakpoint2.log
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

	./set_breakpoint_w $kernel_addr > $log1_file 2>&1 &
	pid1=$!
	./set_breakpoint $kernel_addr > $log2_file 2>&1 &
        pid2=$!

	sleep 2

	insmod set_mem.ko addr=0x$kernel_addr size=1 >/dev/null
        if [ $? -ne 0 ]; then
                RET=$(($RET+1))
        fi

        sleep 30

        # check the message in log_file
        cat $log1_file |grep "CALLCHAIN LEVEL 0" && cat $log2_file |grep "CALLCHAIN LEVEL 0"
        if [ $? -ne 0 ]; then
                RET=$(($RET+1))
                kill -9 $pid1
		kill -9 $pid2
        fi

	rmmod set_mem
	rmmod kmap_test
	rm $log1_file $log2_file
}

clean()
{
	rmmod alloc_pages
}

setup
do_test
clean

exit $RET
