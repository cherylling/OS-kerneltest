#!/bin/bash

set -x
. ../conf/conf.sh

do_test(){
	msg info "do_test..."
	ophelp -r
	if [ $? -ne 0 ]
	then
		msg fail "ophelp -r cannot get cpu type!"
		RET=$((RET+1))
		return $RET
	fi
	msg pass "cpu type is `ophelp -r` " 
}

RET=0
setenv && do_test
do_clean
exit $RET
