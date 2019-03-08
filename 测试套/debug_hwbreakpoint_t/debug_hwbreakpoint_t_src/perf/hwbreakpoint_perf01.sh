#!/bin/bash
#**********************************************************************
#    This testsuite uses perf_even_open() to test hwbreakpoint, but It
#    is not enough because someone use it by perf or gdb and so on.
#    So I write the perf_test which is a repetitive test including
#    hwbreakpoint_test 01,02...11.
#**********************************************************************
. ./hwbreakpoint_perf.conf

RET=0

badaddr=0xffffffffffffffff

do_test()
{
	local addr=$1

	perf record $param -e mem:$addr:wr cat /proc/version

	if [ $? -eq 0 ]; then
		echo "./set_breakpoint $addr return PASS"
	fi
}

setup_test

do_test $badaddr

cleanup

exit $RET
