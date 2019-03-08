#!/bin/bash

#
# test for hw_breakpoint
# Description:
# 	Set breakpoint in error addr, perf_event_open()
# 	will fail and return
#

RET=0

badaddr=0xffffffffffffffff

do_test()
{
	./set_breakpoint $badaddr
	if [ $? -eq 0 ]; then
		echo "./set_breakpoint $addr return unexpectly"
		RET=$(($RET+1))
	fi
}

do_test

exit $RET
