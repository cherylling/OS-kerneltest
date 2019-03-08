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

	opcontrol --status > status.log
	if [ $? -ne 0 ];then
		msg fail  "opcontrol --status show configuration fail" 
		RET=$((RET+1))
		return $RET
	fi

	# how check stop data collection  tbd

	cat status.log | grep "Daemon running" 
	if [ $? -ne 0 ];then
		msg fails  "opcontrol -s tart data collection fail!!!" 
		cat status.log
		opcontrol -h
		RET=$((RET+1))
		return $RET
	fi
	msg pass "opcontrol -s tart data collection pass" 

	opcontrol -h
	rm status.log
}

RET=0
setenv && do_test
do_clean
exit $RET
