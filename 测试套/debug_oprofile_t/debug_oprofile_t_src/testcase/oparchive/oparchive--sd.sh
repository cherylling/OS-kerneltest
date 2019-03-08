#!/bin/bash
set -x
. ../conf/conf.sh


do_test(){
	msg info "do_test..."
	rm /tmp/lo -rf

	set_session_dir /tmp/lo

	if [ $? -ne 0 ];then
		msg fail "opcontrol --session-dir=/tmp/lo hold sample database and session data in dir /tmp/lo fail"
		RET=$((RET+1))
		return $RET
	fi

	opcontrol -s
	if [ $? -ne 0 ];then
		msg fail "opcontrol -s start data collection fail"
		opcontrol -h
		rm -rf /tmp/lo
		RET=$((RET+1))
		return $RET
	fi

	if [ ! -f /tmp/lo/samples/oprofiled.log ];then
		msg fail "oparchive --session-dir=/tmp/lo hold sample database and session data in dir /tmp/lo fail"
		opcontrol -h
		rm -rf /tmp/lo
		RET=$((RET+1))
		return $RET
	fi
	msg pass "oparchive --session-dir=/tmp/lo hold sample database and session data in dir /tmp/lo pass"

	opcontrol --dump
	if [ $? -ne 0 ];then
		msg fail "opcontrol --dump fail"
		opcontrol -h
		rm -rf /tmp/lo
		RET=$((RET+1))
		return $RET
	fi
	msg pass "opcontrol --dump pass"

	oparchive --session-dir=/tmp/lo -o /tmp/log
	if [ $? -ne 0 ];then
		msg fail "oparchive --session-dir=/tmp/lo -o /tmp/lo fail"
		opcontrol -h
		rm -rf /tmp/lo
		RET=$((RET+1))
		return $RETs
	fi
	msg pass "oparchive  --session-dir=/tmp/lo -o /tmp/lo pass"
	opcontrol -h
	rm -rf /tmp/lo /tmp/log
}

RET=0
setenv && do_test
do_clean
exit $RET
