#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: perf_v1r2c00_report_tc001
##- @Author: y00197803
##- @Date: 2013-4-17
##- @Precon: 1.支持perf功能
##- @Brief: 
##- @Detail: 1.执行perf probe   -a 内核函数%return
#            2.执行perf record
#            3.执行perf report
#            4.验证侦测内核模块函数 -a接口 内核函数%return 
##- @Expect: perf report 含有相关信息
##- @Level: Level 2
##- @Auto:
##- @Modify:
#######################################################################*/
. ${TCBIN}./common_perf.sh

prepareenv()
{
    prepare_tmp
    insmod ${TCBIN}../module/kernel_module.ko
    reportfile=${TCTMP}/perf-probe-$$.report
    perfdatafile=/tmp/perf.data
}

dotest()
{
    cd ${TCTMP}
    perf probe -m ${TCBIN}../module/kernel_module.ko -a planck_free_read%return > /dev/null 2>&1
    perf record -o $perfdatafile -e probe:planck_free_read -aR cat /proc/mykthread_free_enable > /dev/null 2>&1
    perf report -i $perfdatafile > $reportfile 2>/dev/null
    check_ret_code $?
    check_in_file cat $reportfile
    check_in_file kernel_module $reportfile 0
}

cleanenv()
{
    rmmod kernel_module
    rm $perfdatafile -rf
    perf probe -d planck* >/dev/null 2>&1
    clean_end
}

prepareenv
dotest
cleanenv
