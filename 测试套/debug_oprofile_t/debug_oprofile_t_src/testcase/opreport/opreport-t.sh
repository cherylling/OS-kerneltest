#!/bin/bash
set -x 
. ../conf/conf.sh

do_test(){
	msg info "do_test..."
	opcontrol -s
	if [ $? -ne 0 ];then
		msg fail "opcontrol -s fail" 
		RET=$((RET+1))
		return $RET
	fi

	sleep 3
	opcontrol --dump
	if [ $? -ne 0 ];then
		msg fail "opcontrol --dump fail" 
		opcontrol -h
		RET=$((RET+1))
		return $RET
	fi

	opreport --session-dir=/tmp/lo -l -t 1
	if [ $? -ne 0 ];then
		msg fail "opreport --session-dir=/tmp/lo -l -t 1 fail" 
		opcontrol -h
		RET=$((RET+1))
		return $RET
	fi

	msg pass "opreport --session-dir=/tmp/lo -l -t 1 pass" 
	opcontrol -h
}

RET=0
setenv && do_test
do_clean
exit $RET
