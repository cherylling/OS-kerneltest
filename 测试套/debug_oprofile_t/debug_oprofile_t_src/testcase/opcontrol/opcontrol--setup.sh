#!/bin/bash
set -x
. ../conf/conf.sh


do_test(){
	#get_available_events_str 
	#EV=`echo $EVENTS_STR |awk -F : '{print $1}'`
	msg info "do_test..."
	get_default_event
	if [ $? -eq 0 ];then
		opcontrol --setup -e=$DEFAULT_EVENT:2000000:0:1:1
	fi
	if [ $? -ne 0 ];then
		msg fail "opcontrol --setup -e=$DEFAULT_EVENT:2000000:0:1:1 specify an event fail" 
		RET=$((RET+1))
		return $RET
	fi

	opcontrol --status > status.log
	if [ $? -ne 0 ];then
		msg fail "opcontrol --status show configuration fail" 
		RET=$((RET+1))
		return $RET
	fi


	cat status.log | grep "$Event:2000000:0:1:1"
	if [ $? -ne 0 ];then
		msg fail "opcontrol --setup -e=$Event:2000000:0:1:1 specify an event fail" 
		cat status.log
		RET=$((RET+1))
		return $RET
	fi
	msg pass "opcontrol --setup -e=$Event:2000000:0:1:1 specify an event pass" 
	rm status.log
}

RET=0
setenv && do_test
do_clean
exit $RET
