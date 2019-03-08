#!/bin/bash
set -x
. ../conf/conf.sh

do_test(){
	msg info "do_test..."
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
	msg pass "opcontrol --dump pass"

	opimport -a /var/lib/oprofile/abi -o /tmp/abi abi -f
	if [ $? -ne 0 ];then
		msg fail "opimport -a /var/lib/oprofile/abi -o abi abi -f fail"
		opcontrol -h
		rm abi -rf
		RET=$((RET+1))
		return $RET
	fi
	msg pass "opimport -a /var/lib/oprofile/abi -o abi abi -f pass"
	opcontrol -h
	rm abi -rf
}

RET=0
setenv && do_test
do_clean
exit $RET


