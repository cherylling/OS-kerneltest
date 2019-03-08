#!/bin/bash
set -x

. ../conf/conf.sh

#get_available_events_str 
#EV=`echo $EVENTS_STR |awk -F : '{print $1}'`

#opcontrol --setup -e=CPU_CYCLES:10000:0:1:1
#opcontrol --setup -e=$1:30000000:0:1:1

do_test(){
	msg info "do_test..."
	
	get_default_event
	if [ $? -eq 0 ];then
		opcontrol --setup -e=$DEFAULT_EVENT:30000000:0:1:1
		if [ $? -ne 0 ];then
			msg fail "opcontrol --setup -e=$DEFAULT_EVENT:10000:0:1:1 specify an event fail" 
			RET=$((RET+1))
			return $RET
		fi
	else
		msg info "using timer mode"
	fi


	opcontrol -s
	if [ $? -ne 0 ];then
		msg fail "opcontrol -s fail" 
		RET=$((RET+1))
		return $RET
	fi

	sleep 5

	opcontrol --dump 
	if [ $? -ne 0 ];then
		msg fail "opcontrol --dump fail" 
		opcontrol -h
		RET=$((RET+1))
		return $RET
	fi

	opreport -l --session-dir=/tmp/lo
	if [ $? -ne 0 ];then
		msg fail "opreport fail" 
		opcontrol -h
		RET=$((RET+1))
		return $RET
	fi

	opcontrol -h

	opcontrol --reset
	if [ $? -ne 0 ];then
		msg fail "opcontrol --reset fail" 
		opcontrol -h
		RET=$((RET+1))
		return $RET
	fi

}

RET=0
setenv && do_test
do_clean
exit $RET
