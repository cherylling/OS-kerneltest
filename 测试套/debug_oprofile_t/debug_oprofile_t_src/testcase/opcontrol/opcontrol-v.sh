#!/bin/bash
set -x
. ../conf/conf.sh

do_test(){
	msg info "do_test..."
	VERSION_MSG_STR=`opcontrol -v`

	H_V=`echo $VERSION_MSG_STR |ophelp -v|awk -F . '{print $1}'|awk '{print $3}'`
	M_V=`echo $VERSION_MSG_STR |ophelp -v|awk -F . '{print $2}'`
	L_V=`echo $VERSION_MSG_STR |ophelp -v|awk -F . '{print $3}'|awk '{print $1}'`

	VERSION_MSG=$H_V$M_V$L_V

	if [ "$VERSION_MSG" != "$1" ];then
		msg fail "oprofile version mismatch {$VERSION_MSG} != {$1} ,please check your control file" 
		RET=$((RET+1))
		return $RET
	fi
	msg pass "oprofile version matchs {$VERSION_MSG} == {$1}" 
}

RET=0
VERSION=`opcontrol -v | awk '{print $3}'|awk -F'.' '{print $1$2$3}'`
setenv && do_test $VERSION
do_clean
exit $RET
