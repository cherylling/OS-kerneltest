#!/bin/bash
#======================================================
# Author: dingzengjian - d00228505
# 
# Last modified: 2014-09-12 22:13
# 
# Filename: perf_v1r3c00_bench_tc004.sh
# 
# Description: 测试perf bench mem memset 性能
#   1. perf bench mem memset -l 100000 测试memset性能
#   2. 检查性能报告是否正确
# 
#======================================================

msg(){
	kind=$1
	shift
	echo "[$kind] $*"
}

RET=0
setenv(){
	EXE=
	TDIR=./
	OUTFILE=$TDIR/perf-bench-report

	#clean all old data
	cd $TDIR
	rm -rf perf.data* 
}

dotest(){
	#perf bench 
	perf bench mem memset -l 100000 > $OUTFILE 2>&1
	if [ $? -ne 0 ];then
		msg FAIL "perf bench mem memset -l 100000 failed"
		RET=$((RET+1))
	fi

	#check bench report
	cat $OUTFILE | grep "mem/memset" || RET=$((RET+1))
	cat $OUTFILE | grep "Copying" || RET=$((RET+1))
	if [ $RET -ne 0 ];then
		msg FAIL "check bench report failed"
	fi
}
cleanup(){
	rm -rf $OUTFILE perf.data*
}

setenv && dotest
cleanup
exit $RET
