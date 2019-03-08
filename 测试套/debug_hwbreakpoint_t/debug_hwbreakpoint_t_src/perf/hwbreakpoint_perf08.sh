#!/bin/bash
#**********************************************************************
#    This testsuite uses perf_even_open() to test hwbreakpoint, but It
#    is not enough because someone use it by perf or gdb and so on.
#    So I write the perf_test which is a repetitive test including
#    hwbreakpoint_test 01,02...11.
#**********************************************************************
. ./hwbreakpoint_perf.conf

kernel_addr=
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
	dmesg -c

        insmod kmap_test.ko p_addr=0x$alloc_addr >/dev/null
        if [ $? -ne 0 ]; then
                RET=$(($RET+1))
        fi

	# Get the addr
        kernel_addr=`dmesg |grep "kmap" |awk -F"addr:" '{print $2}'`
        if [ $? -ne 0 ]; then
                RET=$(($RET+1))
        fi

	perf record $param -e mem:0x$kernel_addr:wr insmod read_mem.ko addr=0x$kernel_addr &>$logfile
        if [ $? -ne 0 ]; then
                RET=$(($RET+1))
        fi

        # check the message in log_file
        cat $logfile |grep "samples" >/dev/null
        if [ $? -ne 0 ]; then
                RET=$(($RET+1))
        fi

	rmmod read_mem
	rmmod kmap_test
}

clean()
{
	rmmod alloc_pages
}

setup_test
setup

for i in `seq 0 9`
do
	do_test
done

clean
cleanup

exit $RET
