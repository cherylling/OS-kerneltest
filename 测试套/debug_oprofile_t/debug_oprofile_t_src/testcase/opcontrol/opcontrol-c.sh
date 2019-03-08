#!/bin/bash
set -x
. ../conf/conf.sh
#. ../conf/suite_api.sh
#. ../conf/events.sh

#oprofile_ko_check
#if [ $? -ne 0 ];then
#    exit 1
#fi

do_test(){
	msg info "do_test..."
	get_default_event
	if [ $? -eq 0 ];then
		opcontrol --setup -e=$DEFAULT_EVENT:30000000:0:1:1 
	else
		# using timer mode
		msg fail "Notice: Using timer mode"
		#RET=$((RET+1))
		#return $RET
	fi
	opcontrol -c=10
	if [ $? -ne 0 ];then
		msg fail "opcontrol -c enable callgraph sample collection with 10 depth fail" 
		RET=$((RET+1))	
		return $RET
	fi

	opcontrol --status > status.log
	if [ $? -ne 0 ];then
		msg fail  "opcontrol --status show configuration fail" 
		RET=$((RET+1))	
		return $RET
	fi

	# how check stop data collection  tbd

	DEPTH=`cat status.log | grep "Call-graph depth" |awk -F : '{print $2}'`
	if [ $DEPTH -ne 10 ];then
		msg fail "opcontrol -c=10 enable callgraph fail !!!" 
		cat status.log
		opcontrol -c=0
		RET=$((RET+1))	
		return $RET
	fi
	msg pass "opcontrol -c=10 enable callgraph pass !!!" 

	opcontrol -c=0
}
RET=0
setenv && do_test
do_clean
exit $RET
