#!/bin/bash
set -x 
. ../conf/conf.sh
do_test(){
	msg info "do_test..."
	get_default_event
	if [ $? -ne 0 ];then
		RET=$((RET+1))
		return $RET
	fi
	opcontrol -e=$DEFAULT_EVENT:2000000:0:1:1
	if [ $? -ne 0 ];then
		msg fail "opcontrol -e=$DEFAULT_EVENT:2000000:0:1:1 specify an event fail" 
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

	cat status.log | grep "$DEFAULT_EVENT:2000000:0:1:1"
	if [ $? -ne 0 ];then
		msg fail "opcontrol -e=$Event:2000000:0:1:1 specify an event fail" 
		cat status.log
		RET=$((RET+1))
		return $RET
	fi
	msg pass "opcontrol -e=$Event:2000000:0:1:1 specify an event pass" 
	rm status.log
}

RET=0
setenv && do_test
do_clean
exit $RET
