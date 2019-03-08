#!/bin/bash
set -x 
. ../conf/conf.sh
. ../conf/suite_api.sh
do_test(){
	msg info "do_test..."
	get_available_events_str 
	echo $EVENTS_STR
	echo $EVENTS_NUM


	for event in $EVENTS_STR
	do
		msg info "event :$event testing ..."
		opcontrol --init
		opcontrol --reset
		if [ $event != "CPU_CYCLES" ];then
			opcontrol --setup -e $event:500::1:1
		else
			opcontrol --setup -e $event:10000::1:1
		fi  

		opcontrol -s

		./hackbench 10 
		sleep 3
		opcontrol --dump

		opcontrol -h

		opreport --session-dir=/tmp/lo -l |grep $event 
		if [ $? -eq 0 ]; then
			echo "success:$event" >>oprofileEventTestlog
		else
			echo "fail:$event">>oprofileEventTestlog
		fi 
	done

	cat oprofileEventTestlog |grep fail
	if [ $? -ne 0 ];then
		msg pass "all events test pass"
		return 0
	fi
	msg fail "some events test fail, please check these events"
	RET=$((RET+1))
	return 1
}

RET=0
setenv && do_test
do_clean
exit $RET
