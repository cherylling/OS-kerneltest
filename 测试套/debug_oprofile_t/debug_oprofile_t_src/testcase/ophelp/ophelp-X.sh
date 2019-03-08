#!/bin/bash

set -x
. ../conf/conf.sh

do_test(){
	msg info "do_test..."
	XMLSTR=`ophelp -X`


	if [ -z "$XMLSTR" ];then
		msg fail "ophelp -X get info fail" 
		RET=$((RET+1))
		return $RET
	else
		echo $XMLSTR |grep '<'
		if [ $? -ne 0 ];then
			msg fail "ophelp -X get info fail 2" 
			RET=$((RET+1))
			return $RET
		else
			msg pass "ophelp -X get info pass" 
		fi
	fi

}

RET=0
setenv && do_test
do_clean
exit $RET
