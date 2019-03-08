#!/bin/bash
set -x

. ../conf/conf.sh

do_test(){
	msg info "do_test..."
	opcontrol -p=none
	if [ $? -ne 0 ];then
		msg fail "opcontrol -p=none Separate none profiles fail" 
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

	cat status.log | grep "Separate options" |awk -F : '{print $2}'|grep "none"
	if [ $? -ne 0 ];then
		msg fail "opcontrol -none Separate none profiles fail" 
		cat status.log
		opcontrol -p=none
		RET=$((RET+1))
		return $RET
	fi
	msg pass "opcontrol -none Separate none profiles pass" 

	opcontrol -p=none
}
RET=0 
setenv && do_test
do_clean
exit $RET
