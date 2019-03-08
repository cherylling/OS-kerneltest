#!/bin/bash
set -x
. ../conf/conf.sh

do_test(){
	msg info "do_test..."
	
	rm /tmp/lo -rf
	opcontrol --session-dir=/tmp/lo
	if [ $? -ne 0 ];then
		msg fail "opcontrol --session-dir=/tmp/lo place sample database in dir /tmp/lo fail"
		RET=$((RET=1))
		return $RET
	fi

	opcontrol -s
	if [ $? -ne 0 ];then
		msg fail "opcontrol -s start data collection fail"
		RET=$((RET+1))
		return $RET
	fi

	if [ ! -f /tmp/lo/samples/oprofiled.log ];then
		msg fail "opcontrol --session-dir=/tmp/lo place sample database in dir /tmp/lo fail"
		opcontrol -h
		rm -rf /tmp/lo
		RET=$((RET+1))
		return $RET
	fi
	msg pass "opcontrol --session-dir=/tmp/lo place sample database in dir /tmp/lo pass"
	opcontrol -h
	rm -rf /tmp/lo
}

RET=0
setenv && do_test
do_clean
exit $RET
