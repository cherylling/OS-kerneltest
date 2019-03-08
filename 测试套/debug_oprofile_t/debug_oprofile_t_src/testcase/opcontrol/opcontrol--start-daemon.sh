#!/bin/bash
set -x
. ../conf/conf.sh

do_test(){
	msg info "do_test..."
	opcontrol --start-daemon
	if [ $? -ne 0 ];then
		msg fail "opcontrol --start-daemon start daemon without starting profiling fail" 
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

	cat status.log | grep "Daemon paused" ||cat status.log | grep "Daemon running"
	if [ $? -ne 0 ];then
		msg fail "opcontrol --start-daemon start daemon without starting profiling fail" 
		cat status.log
		rm status.log
		opcontrol -h
		RET=$((RET+1))
		return $RET
	fi
	msg pass "opcontrol --start-daemon start daemon without starting profiling pass" 

	opcontrol -h
	rm status.log
}

RET=0
setenv && do_test
do_clean
exit $RET
