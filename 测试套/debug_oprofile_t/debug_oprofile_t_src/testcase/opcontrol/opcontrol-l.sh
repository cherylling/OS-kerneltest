#!/bin/bash
set -x 

. ../conf/conf.sh

do_test(){
	msg info "do_test..."
	ophelp > ophelpevent
	EVENT_STR=`opcontrol -l`
	if [ -z "$EVENT_STR" ];then
		msg fail  "opcontrol -l get event fail" 
		RET=$((RET+1))
		return $RET
	fi
	opcontrol -l > opcontrollevent
	
	diff ophelpevent opcontrollevent
	if [ $? -ne 0 ];then
		msg fail "ophelp & opcontrol -l GET EVENT mismatch"
		RET=$((RET+1))
		return $RET
	fi
	msg pass "ophelp & opcontrol -l GET EVENT matches"
	rm -rf ophelpevent opcontrollevent

}

RET=0
setenv && do_test
do_clean
exit $RET
