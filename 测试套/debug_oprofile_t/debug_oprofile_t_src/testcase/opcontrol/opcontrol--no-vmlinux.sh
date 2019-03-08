#!/bin/bash
set -x 
. ../conf/conf.sh

do_test(){
	msg info "do_test..."
	opcontrol --setup --no-vmlinux
	if [ $? -ne 0 ];then
		msg fail "opcontrol --no-vmlinux set no kernel image (vmlinux) available fail"
		RET=$((RET+1))
		return $RET
	fi
	msg pass "opcontrol --no-vmlinux set no kernel image (vmlinux) available pass"
}

RET=0
setenv && do_test
do_clean
exit $RET
