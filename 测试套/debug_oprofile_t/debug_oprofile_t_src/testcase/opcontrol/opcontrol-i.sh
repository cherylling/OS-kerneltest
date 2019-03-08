#!/bin/bash
set -x
. ../conf/conf.sh
#. ../conf/suite_api.sh
#oprofile_ko_check
#if [ $? -ne 0 ];then
#    exit 1
#fi
#rtos_msg_color 32 "opcontrol --init pass"
do_test(){
	msg info "do_test..."
	opcontrol -i=/lib/libpopt.so
	if [ $? -ne 0 ];then
		msg fail "opcontrol -i=/lib/libpopt.so list of binaries to profile fail" 
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

	cat status.log | grep "/lib/libpopt.so"
	if [ $? -ne 0 ];then
		msg fail "opcontrol -i=/lib/libpopt.so list of binaries to profile fail" 
		cat status.log
		opcontrol -i=all
		rm status.log
		RET=$((RET+1))
		return $RET
	fi
	msg pass "opcontrol -i=/lib/libpopt.so list of binaries to profile pass" 

	opcontrol -i=all
	rm status.log
}

RET=0
setenv && do_test
do_clean
exit $RET
