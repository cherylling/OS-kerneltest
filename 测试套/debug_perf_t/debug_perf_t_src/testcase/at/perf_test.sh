#!/bin/bash

RESULTPATH=/tmp/perf_test

perf test > $RESULTPATH 2>&1
ret=`cat $RESULTPATH | grep FAILED`
if [ $? -eq 0 ];then
	echo "TEST FAILED:"
	echo "$ret"
	rm -f $RESULTPATH 
	exit 1
else
	echo "PASS"
	rm -f $RESULTPATH
	exit 0
fi
