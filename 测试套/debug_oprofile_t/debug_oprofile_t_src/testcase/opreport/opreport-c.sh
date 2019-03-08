#!/bin/bash
set -x 
. ../conf/conf.sh

do_test(){
	msg info "do_test..."
	opcontrol -s
	if [ $? -ne 0 ];then
		msg fail "opcontrol -s start data collection fail"
		opcontrol -h
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

	opreport -l -i open -c --session-dir=/tmp/lo
	if [ $? -ne 0 ];then
		msg fail "opreport -l -i open -c fail"
		opcontrol -h
		RET=$((RET+1))
		return $RET
	fi
	msg pass "opreport -l -i open -c pass"
	opcontrol -h
}

RET=0
setenv && do_test
do_clean
exit $RET


