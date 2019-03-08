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

	opcontrol --status > status.log
	if [ $? -ne 0 ];then
		msg fail "opcontrol --status show configuration fail" 
		RET=$((RET+1))
		return $RET
	fi

	# how check stop data collection  tbd

	cat status.log | grep "Daemon not running" 
	if [ $? -ne 0 ];then
		msg pass  "opcontrol -t stop data collection pass" 
		opcontrol -h
		return 0
	fi
	cat status.log
	msg info "opcontrol -s stop kill daemon !!!" 

	opcontrol -h
	RET=$((RET+1))
	return $RET
}

RET=0
setenv && do_test
do_clean
exit $RET
