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
	# Get the linux_proc_banner addr
	kernel_addr=`cat /proc/kallsyms |grep linux_proc_banner |awk -F" " '{print $1}'`
	if [ $? -ne 0 ]; then
		echo "get linux_proc_banner addr failed"
		RET=$(($RET+1))
	fi
}

do_test()
{
	perf record $param -e mem:0x$kernel_addr:wr cat /proc/version &>$logfile
	if [ $? -ne 0 ]; then
		RET=$(($RET+1))
	fi

	# check the message in log_file
	cat $logfile |grep "samples" >/dev/null
	if [ $? -ne 0 ]; then
		RET=$(($RET+1))
	fi
}

setup_test
setup
do_test
cleanup

exit $RET
