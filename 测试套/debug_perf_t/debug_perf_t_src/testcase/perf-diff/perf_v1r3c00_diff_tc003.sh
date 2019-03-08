#!/bin/bash
#======================================================
# Author: dingzengjian - d00228505
# 
# Last modified: 2014-09-04 15:41
# 
# Filename: perf_v1r3c00_diff_tc003.sh
# 
# Description: 测试perf diff --symbols=file://SymbolsFilter
#	1. 对于exe1和exe2分别使用perf record -a -o $output采集数据
#   2. 分别对应生成exe1.data和exe2.data
#   3. 使用perf diff exe1.data exe2.data --symbols=file://SymbolsFilter生成perf-diff-report
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

	#make symbols filter file
	echo "longa" > ./SymbolsFilter
	echo "foo1" >> ./SymbolsFilter
	echo "foo2" >> ./SymbolsFilter
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
	perf diff ./${EXE1}.data ${EXE2}.data --symbols=file://SymbolsFilter > $OUTFILE 2>&1
	if [ $? -ne 0 ];then
		msg FAIL "perf diff failed"
		RET=$((RET+1))
	fi
	# check the diff report
	cat $OUTFILE | grep "Baseline.*Delta.*Shared\ Object.*Symbol" || RET=$((RET+1))
#	if [ `arch` != "aarch64" ];then
#		cat $OUTFILE | grep "+[[:digit:]]\{3,3\}\.[[:digit:]]\{2,2\}.*tc_perf_diff_02.*longa" || RET=$((RET+1))
#		cat $OUTFILE | grep "[[:digit:]]\{3,3\}\.[[:digit:]]\{2,2\}\%.*\-[[:digit:]]\{3,3\}\.[[:digit:]]\{2,2\}.*tc_perf_diff_01.*longa" || RET=$((RET+1))
#	else
		cat $OUTFILE | grep "+[[:digit:]]\{1,2\}\.[[:digit:]]\{1,2\}.*tc_perf_diff_02.*longa" || RET=$((RET+1))
                cat $OUTFILE | grep "[[:digit:]]\{1,2\}\.[[:digit:]]\{1,2\}.*tc_perf_diff_01.*longa" || RET=$((RET+1))
#	fi
	# --symbols with absolute path
	rm -rf $OUTFILE
	msg INFO "doing perf diff --symbol with absolute path"
	SymbolsFilePath=`pwd`/SymbolsFilter
	perf diff ./${EXE1}.data ${EXE2}.data --symbols=file://${SymbolsFilePath} > $OUTFILE 2>&1
	if [ $? -ne 0 ];then
		msg FAIL "perf diff failed"
		RET=$((RET+1))
	fi
	# check the diff report again
	cat $OUTFILE | grep "Baseline.*Delta.*Shared\ Object.*Symbol" || RET=$((RET+1))
#	if [ `arch` != "aarch64" ];then
#        	cat $OUTFILE | grep "+[[:digit:]]\{3,3\}\.[[:digit:]]\{2,2\}.*tc_perf_diff_02.*longa" || RET=$((RET+1))
#        	cat $OUTFILE | grep "[[:digit:]]\{3,3\}\.[[:digit:]]\{2,2\}\%.*\-[[:digit:]]\{3,3\}\.[[:digit:]]\{2,2\}.*tc_perf_diff_01.*longa" || RET=$((RET+1))
#	else
		cat $OUTFILE | grep "+[[:digit:]]\{1,2\}\.[[:digit:]]\{1,2\}.*tc_perf_diff_02.*longa" || RET=$((RET+1))
                cat $OUTFILE | grep "[[:digit:]]\{1,2\}\.[[:digit:]]\{1,2\}.*tc_perf_diff_01.*longa" || RET=$((RET+1))
#	fi
}
cleanup(){
	rm -rf $OUTFILE 
	rm -rf SymbolsFilter
	rm -rf ./${EXE1}.data ./${EXE2}.data
}

setenv && dotest
cleanup
exit $RET
