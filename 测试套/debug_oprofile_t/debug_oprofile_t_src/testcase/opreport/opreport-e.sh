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
	./e-strlen
	sleep 1
	opcontrol --dump
	if [ $? -ne 0 ];then
		msg fail "opcontrol --dump fail" 
		opcontrol -h
		RET=$((RET+1))
		return $RET
	fi

	opreport --session-dir=/tmp/lo -l -e strlen >log
	if [ $? -ne 0 ];then
		msg fail "opreport --session-dir=/tmp/lo -l -e strlen fail" 
		opcontrol -h
		RET=$((RET+1))
		return $RET
	fi

	cat log |grep strlen
	if [ $? -eq 0 ];then
		msg pass "opreport --session-dir=/tmp/lo -l -e strlen pass" 
		opcontrol -h
		return 0
	fi

	msg fail "opreport --session-dir=/tmp/lo -l -e strlen fail, there's strlen in log" 
	opcontrol -h
	RET=$((RET+1))
	return $RET
}

RET=0
setenv && do_test
do_clean
exit $RET
