#!/bin/bash
set -x
. ../conf/conf.sh

do_test(){
	msg info "do_test..."
	opcontrol -s
	if [ $? -ne 0 ];then
		msg fail "opcontrol -s start data collection fail" 
		RET=$((RET+1))
		return $RET
	fi

	opcontrol -h
	if [ $? -ne 0 ];then
		msg fail  "opcontrol -h stop data collection and kill daemon fail" 
		RET=$((RET+1))
		return $RET
	fi

	opcontrol --status > status.log
	if [ $? -ne 0 ];then
		msg fail "opcontrol --status show configuration fail" 
		RET=$((RET+1))
		return $RET
	fi

	cat status.log | grep "Daemon not running" 
	if [ $? -ne 0 ];then
		msg fail "opcontrol -h stop data collection and kill daemon fail" 
		cat status.log
		RET=$((RET+1))
		return $RET
	fi
	msg pass "opcontrol -h stop data collection and kill daemon pass" 
}

RET=0
setenv && do_test
do_clean
exit $RET
