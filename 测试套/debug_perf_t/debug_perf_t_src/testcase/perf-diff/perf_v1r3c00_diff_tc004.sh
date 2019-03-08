#!/bin/bash
#======================================================
# Author: dingzengjian - d00228505
# 
# Last modified: 2014-09-12 20:50
# 
# Filename: perf_v1r3c00_diff_tc004.sh
# 
# Description: 测试perf diff -f -p -F -c +
#	1. 对于exe1和exe2分别使用perf record -a -o $output采集数据
#   2. 分别对应生成exe1.data和exe2.data
#   3. 使用perf diff exe1.data exe2.data -f -p -F -c +生成perf-diff-report
#   4. 检查perf-diff-report的正确性，预期只显示过滤的symbols
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

	#clean all old data
	cd $TDIR
	rm -rf perf.data* 

}

dotest(){
	# sample first proc
	perf record -a -o ./${EXE1}.data ./$EXE1
	if [ $? -ne 0 ];then
		msg FAIL "perf record -a ./$EXE1 failed"
		RET=$((RET+1))
	fi

	# sample second proc
	perf record -a -o ./${EXE2}.data ./$EXE2
	if [ $? -ne 0 ];then
		msg FAIL "perf record -a ./$EXE2 failed"
		RET=$((RET+1))
	fi

	msg INFO "finish sampling"
	msg INFO "perf diff ..."

	# --symbols with relative path
	msg INFO "doing perf diff --symbol with relative path"
#	if [ `arch` != "aarch64" ];then
#		perf diff ./${EXE1}.data ${EXE2}.data -f -p -F -c + > $OUTFILE 2>&1
#	else
		perf diff ./${EXE1}.data ${EXE2}.data -f -p -F > $OUTFILE 2>&1
#	fi
	if [ $? -ne 0 ];then
		msg FAIL "perf diff failed"
		RET=$((RET+1))
	fi
	# check the diff report
#	if [ `arch` != "aarch64" ];then
#		cat $OUTFILE | grep "Baseline.*Delta.*Formula.*Period.*Period\ Base.*Share" || RET=$((RET+1))
#		cat $OUTFILE | grep "+[[:digit:]]\{2,2\}\.[[:digit:]]\{2,2\}\%.*tc_perf_diff_02.*longa" || RET=$((RET+1))
#		cat $OUTFILE | grep "\-[[:digit:]]\{2,2\}\.[[:digit:]]\{2,2\}\%.*tc_perf_diff_01.*longa" || RET=$((RET+1))
#	else
		cat $OUTFILE | grep "Baseline.*Delta.*Formula.*Period.*Shared.*Object" || RET=$((RET+1))
                cat $OUTFILE | grep "+[[:digit:]]\{1,2\}\.[[:digit:]]\{1,2\}\%.*tc_perf_diff_02.*longa" || RET=$((RET+1))
                cat $OUTFILE | grep "[[:digit:]]\{1,2\}\.[[:digit:]]\{1,2\}\%.*tc_perf_diff_01.*longa" || RET=$((RET+1))
#	fi
}
cleanup(){
	rm -rf $OUTFILE 
	rm -rf ./${EXE1}.data ./${EXE2}.data
}

setenv && dotest
cleanup
exit $RET
