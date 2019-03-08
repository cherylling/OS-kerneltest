#!/bin/bash
set -x

. ../conf/conf.sh

do_test(){
    msg info "do_test..."
    cpunum=`cat /proc/cpuinfo | grep processor | wc -l`
    if [ $cpunum -gt 2 ];then
        exit 0
    fi

    opcontrol --event=CPU_CYCLES:5000:0:1:1
    opcontrol --start

}

RET=0
setenv && do_test
do_clean
exit $RET
