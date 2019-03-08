#!/bin/bash
set -x
. ../conf/conf.sh

do_test(){
	msg info "do_test..."
	DEFAULT_E=`ophelp -d |awk -F _ '{print $1}'`

	if [ "$DEFAULT_E" != "CPU" -a "$DEFAULT_E" != "CNT" ];then
		msg fail "ophelp -d to  get the default event failed:{$DEFAULT_E}"
		RET=$((RET+1))
		return $RET
	fi
	msg pass "ophelp -d to get the default event pass:{$DEFAULT_E}"
}

RET=0
setenv && do_test
do_clean
exit $RET
