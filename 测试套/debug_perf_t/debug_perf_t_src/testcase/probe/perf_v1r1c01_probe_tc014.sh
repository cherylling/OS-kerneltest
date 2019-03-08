#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: perf_v1r2c00_report_tc001
##- @Author: y00197803
##- @Date: 2013-4-17
##- @Precon: 1.支持perf功能
##- @Brief: 
##- @Detail: 1将模块insmod到系统
#            2执行perf probe -m “相对路径的内核模块” “module function” 
#            3执行perf record -e probe：“module function”…
#            4执行perf report
#            5验证侦测模块内函数是否成功、perf report的信息是否正确
##- @Expect: perf probe -m可以直接支持相对径
##- @Level: Level 3
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
    cd ${TCBIN}../module
    perf probe -m ./kernel_module.ko -f planck_free_read > /dev/null 2>&1
    if [ $? -ne 0 ];then
        echo "TFAIL: perf probe -m <relative path> <function> error"
        RC=$((RC+1))
    else
        cd ${TCTMP}
        #perf record -e probe:planck_free_read -M ${TCBIN}../module -aR cat /proc/mykthread_free_enable > /dev/null 2>&1
        #perf report > $reportfile 2>/dev/null
        #check_ret_code $?
        #check_in_file kernel_module $reportfile
        #check_in_file cat $reportfile
        #check_in_file planck_free_read $reportfile
        #rm -f perf.data*
	perf --version | grep "4.1"
	rel=$?
	if [ $rel -eq 0 ];then
        perf record -o $perfdatafile -e probe:planck_free_read -aR cat /proc/mykthread_free_enable > /dev/null 2>&1
        perf report -i $perfdatafile > $reportfile 2>/dev/null
	else
        perf record -o $perfdatafile -e probe:planck_free_read -aR cat /proc/mykthread_free_enable > /dev/null #2>&1
        perf report -i $perfdatafile > $reportfile #2>/dev/null
	fi
        check_ret_code $?
        check_in_file cat $reportfile
        check_in_file kernel_module $reportfile
        check_in_file planck_free_read $reportfile
    fi
}

cleanenv()
{
    rmmod kernel_module
    rm $perfdatafile -rf
    perf probe -d planck* > /dev/null 2>&1
    clean_end
}

prepareenv
dotest
cleanenv
