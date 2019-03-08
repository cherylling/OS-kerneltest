#!/bin/bash
set -x
. ../conf/conf.sh

do_test(){
	msg info "do_test..."
	rm -rf /tmp/log
	set_session_dir /var/lib/oprofile
	if [ $? -ne 0 ];then
		msg fail "oparchive --session-dir=/var/lib/oprofile fail"
		RET=$((RET+1))
		return $RET
	fi

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
	echo "opcontrol --dump pass"

	oparchive -o /tmp/log
	if [ $? -ne 0 ];then
		msg fail "oparchive -o /tmp/log fail"
		opcontrol -h
		RET=$((RET+1))
		return $RET
	fi
	msg pass "oparchive  -o /tmp/log pass"
	opcontrol -h
	rm -rf /tmp/log
}

RET=0
setenv && do_test
do_clean
exit $RET



