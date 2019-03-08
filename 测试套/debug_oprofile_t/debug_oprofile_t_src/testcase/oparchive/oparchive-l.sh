#!/bin/bash

set -x
. ../conf/conf.sh


do_test(){
	msg info "do_test..."
	#set_session_dir /var/lib/oprofile
	get_default_event
	opcontrol --setup --no-vmlinux -e=${DEFAULT_EVENT}:10000:0:1:1 --session-dir=/var/lib/oprofile
	if [ $? -ne 0 ];then
		msg fail  "oparchive --session-dir=/var/lib/oprofile fail"
		RET=$((RET+1))
		return $RET
	fi

    sleep 1

	opcontrol -s
	if [ $? -ne 0 ];then
		msg fail  "opcontrol -s start data collection fail"
		opcontrol -h
		RET=$((RET+1))
		return $RET
	fi

	sleep 5

	opcontrol --dump
	if [ $? -ne 0 ];then
		msg fail  "opcontrol --dump fail"
		opcontrol -h
		RET=$((RET+1))
		return $RET
	fi
	msg pass "opcontrol --dump pass"

    sleep 1

	oparchive -l
	if [ $? -ne 0 ];then
		msg fail "oparchive -l fail"
		opcontrol -h
		RET=$((RET+1))
		return $RET
	fi
	msg pass  "oparchive -l pass"
	opcontrol -h
}

RET=0
setenv && do_test
do_clean
exit $RET


