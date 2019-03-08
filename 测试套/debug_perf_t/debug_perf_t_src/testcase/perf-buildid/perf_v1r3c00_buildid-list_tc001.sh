#!/bin/bash
#======================================================
# Author: dingzengjian - d00228505
#
# Last modified: 2014-09-12 21:40
#
# Filename: perf_v1r3c00_buildid-list_tc001.sh
#
# Description: 测试perf buildid-list
#   1. 使用perf buildid-list -k查看内核的buildid
#   2. 使用perf buildid-list perf.data查看perf.data的buildid
#   3. 判断他们的buildid是否正确
#
#======================================================

msg(){
	kind=$1
	shift
	echo "[$kind] $*"
}

RET=0
setenv(){
	EXE=tc_perf_buildid_01
	TDIR=./
	OUTFILE=$TDIR/perf-buildid-list-report
        PERFDATAFILE=/tmp/perf.data

	#clean all old data
	cd $TDIR
	rm -rf $PERFDATAFILE
}

dotest(){
	#perf buildid-list -k
	perf buildid-list -k > $OUTFILE
	if [ $? -ne 0 ];then
		msg FAIL "perf buildid-list -k failed"
		RET=$((RET+1))
	fi

	#check and get kernel buildid
	Kbuildid=`cat $OUTFILE | awk '{print $1}'`
	cat $OUTFILE  | grep "[[:alnum:]]\{1,\}"
	if [ $? -ne 0 ];then
		msg FAIL "perf buildid-list -k failed"
		msg INFO "kernel buildid>>"
		cat $OUTFILE
		RET=$((RET+1))
	fi

	#get perf.data buildid
	perf record -o $PERFDATAFILE ./$EXE
	perf buildid-list -i $PERFDATAFILE > $OUTFILE
	cat $OUTFILE | grep "$Kbuildid"
	if [ $? -ne 0 ];then
		msg FAIL "No kernel buildid ..."
		RET=$((RET+1))
	fi
	ExeBuildid=`readelf -a $EXE | grep "Build ID" | awk '{print $3}'`
	cat $OUTFILE | grep "$ExeBuildid.*$EXE"
	if [ $? -ne 0 ];then
		msg FAIL "executable file buildid checked failed"
		RET=$((RET+1))
	fi
}
cleanup(){
	rm -rf $OUTFILE $PERFDATAFILE
}

setenv && dotest
cleanup
exit $RET
