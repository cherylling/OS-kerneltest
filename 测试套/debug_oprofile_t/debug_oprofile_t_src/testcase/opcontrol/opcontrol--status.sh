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

	opcontrol -t
	if [ $? -ne 0 ];then
		msg fail "opcontrol -t stop data collection fail" 
		RET=$((RET+1))
		return $RET
	fi

	opcontrol --status 
	if [ $? -ne 0 ];then
		msg fail  "opcontrol --status show configuration fail" 
		RET=$((RET+1))
		return $RET
	fi

	msg pass "opcontrol --status show configuration pass" 

	opcontrol -h
}

RET=0
setenv && do_test
do_clean
exit $RET
