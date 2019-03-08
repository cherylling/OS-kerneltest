#!/bin/bash
set -x
. ../conf/conf.sh

do_test(){
	msg info "do_test..."
	CPU_TYPE=`ophelp`

	if [ -z "$CPU_TYPE" ];then
		msg fail "ophelp get event fail" 
		RET=$((RET+1))
		return $RET
	fi
	msg pass "ophelp get event pass" 
}

RET=0
setenv && do_test
do_clean
exit $RET
