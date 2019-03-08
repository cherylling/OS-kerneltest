#!/bin/bash
set -x 
. ../conf/conf.sh
#. ../conf/suite_api.sh
#. ../conf/events.sh

#oprofile_ko_check
#if [ $? -ne 0 ];then
#    exit 1
#fi

do_test()
{
	msg info "do_test..."
    opcontrol --deinit
    if [ $? -ne 0 ];then
        msg fail "opcontrol --deinit fail"
		RET=$((RET+1))  
		return $RET      
    fi

    OPFILES=`ls /dev/oprofile`
    if [ ! -z "$OPFILES" ];then
        msg fail  "there's some files in /dev/oprofile dir after opcontrol --deinit"
		RET=$((RET+1))     
		return $RET   
    fi
}

RET=0
setenv && do_test
do_clean
exit $RET
