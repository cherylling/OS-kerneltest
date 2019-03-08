#!/bin/bash
#======================================================
# Author: dingzengjian - d00228505
# 
# Last modified: 2014-09-04 14:54
# 
# Filename: perf_v1r3c00_diff_tc001.sh
# 
# Description: 测试perf diff
#	1. 对于exe1和exe2分别使用perf record采集数据
#   2. 默认生成perf.data和perf.data.old
#   3. 使用perf diff生成perf-diff-report
#   4. 检查perf-diff-report的正确性，预期能显示两者的不同
# 
#======================================================

msg(){
	kind=$1
	shift
	echo "[$kind] $*"
}

RET=0
setenv(){
	EXE1=tc_perf_diff_01
	EXE2=tc_perf_diff_02
	TDIR=./
	OUTFILE=$TDIR/perf-diff-report
        PERFFILE1=/tmp/perf.data1
        PERFFILE2=/tmp/perf.data2
	#clean all old data
	cd $TDIR
	rm -rf $PERFFILE
}

dotest(){
	# sample first proc
	perf record -o $PERFFILE1 -a ./$EXE1
	if [ $? -ne 0 ];then
		msg FAIL "perf record -a ./$EXE1 failed"
		RET=$((RET+1))
	fi

	# sample second proc
	perf record -o $PERFFILE2 -a ./$EXE2
	if [ $? -ne 0 ];then
		msg FAIL "perf record -a ./$EXE2 failed"
		RET=$((RET+1))
	fi

	msg INFO "finish sampling"
	perf diff $PERFFILE1 $PERFFILE2 > $OUTFILE 2>&1
	if [ $? -ne 0 ];then
		msg FAIL "perf diff failed"
		RET=$((RET+1))
	fi

	# check the diff report
	cat $OUTFILE | grep "Baseline.*Delta.*Shared\ Object.*Symbol" || RET=$((RET+1))
#	if [ `arch` != "aarch64" ];then
#		cat $OUTFILE | grep "+[[:digit:]]\{2,2\}\.[[:digit:]]\{2,2\}\%.*tc_perf_diff_02.*longa" || RET=$((RET+1))
#		cat $OUTFILE | grep "\-[[:digit:]]\{2,2\}\.[[:digit:]]\{2,2\}\%.*tc_perf_diff_01.*longa" || RET=$((RET+1))
#	else
		cat $OUTFILE | grep "+[[:digit:]]\{1,2\}\.[[:digit:]]\{1,2\}\%.*tc_perf_diff_02.*longa" || RET=$((RET+1))
		cat $OUTFILE | grep "[[:digit:]]\{1,2\}\.[[:digit:]]\{1,2\}\%.*tc_perf_diff_01.*longa" || RET=$((RET+1))
#	fi
}
cleanup(){
	rm -rf $OUTFILE $PERFFILE1 $PERFFILE2
}

setenv && dotest
cleanup
exit $RET
