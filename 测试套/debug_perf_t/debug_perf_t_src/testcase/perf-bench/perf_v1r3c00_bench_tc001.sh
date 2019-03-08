#!/bin/bash
#======================================================
# Author: dingzengjian - d00228505
# 
# Last modified: 2014-09-12 22:00
# 
# Filename: perf_v1r3c00_bench_tc001.sh
# 
# Description: 测试perf bench sched
#   1. perf bench sched messaging -t -g 20测试内核调度器性能
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
	perf bench sched messaging -t -g 20 > $OUTFILE 2>&1
	if [ $? -ne 0 ];then
		msg FAIL "perf bench sched messaging -t -g 20 failed"
		RET=$((RET+1))
	fi

	#check bench report
	cat $OUTFILE | grep "Running 'sched/messaging' benchmark" || RET=$((RET+1))
	cat $OUTFILE | grep "20 sender and receiver" || RET=$((RET+1))
	cat $OUTFILE | grep "20 groups" || RET=$((RET+1))
	cat $OUTFILE | grep "Total time.*[[:digit:]].*[sec]" || RET=$((RET+1))
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
