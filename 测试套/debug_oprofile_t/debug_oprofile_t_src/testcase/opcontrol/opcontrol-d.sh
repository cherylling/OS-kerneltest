#!/bin/bash
set -x

. ../conf/conf.sh
#. ../conf/suite_api.sh
#. ../conf/events.sh
#
#oprofile_ko_check
#if [ $? -ne 0 ];then
#	exit 1
#fi
#rtos_msg_color 32 "opcontrol --init pass"

#get_available_events_str 
#EV=`echo $EVENTS_STR |awk -F : '{print $1}'`

do_test(){
	msg info "do_test..."
	get_default_event
	if [ $? -eq 0 ];then
		opcontrol --setup -e=$DEFAULT_EVENT:30000000:0:1:1
	else
		msg info "Using timer mode"
	fi

	opcontrol -s
	if [ $? -ne 0 ];then
		msg fail  "opcontrol -s fail" 
		RET=$((RET+1))
		return $RET
	fi

	sleep 1

	opcontrol --dump
	if [ $? -ne 0 ];then
		msg fail "opcontrol --dump fail" 
		RET=$((RET+1))
		return $RET
	fi
}

RET=0
setenv && do_test
do_clean
exit $RET
