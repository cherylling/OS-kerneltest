#!/bin/bash
#======================================================
# Author: dingzengjian - d00228505
# 
# Last modified: 2013-03-29 12:01
# 
# Filename: eventsupport.sh
# 
# Description: support event? or using time mode  
# 
#======================================================
set -x
. ../conf/conf.sh


do_test(){
	msg info "do_test..."
	get_default_event
	if [ $? -eq 0 ];then
		# using event mode
		# and have a try
		msg pass "Support sample by events"
		opcontrol --setup -e=$DEFAULT_EVENT:30000000:0:1:1 
		if [ $? -ne 0 ];then
			msg fail "opcontrol --setup -e=$DEFAULT_EVENT:30000000:0:1:1  fail"
			msg fail "Not actually support event"
			RET=$((RET+1))
			return $RET
		fi
	else
		# using timer mode
		msg fail "Using timer mode"
		RET=$((RET+1))
		return $RET
	fi
}
RET=0
setenv && do_test
do_clean
exit $RET
