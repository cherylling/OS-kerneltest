#!/bin/bash
set -x
. ../conf/conf.sh
do_test(){
	return 0
}

RET=0
setenv && do_test
do_clean
exit $RET
