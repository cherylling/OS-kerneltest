#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: perf_v1r2c00_report_common
##- @Author: y00197803
##- @Date: 2013-4-17
##- @Precon: 1.支持perf功能
##- @Brief: functions for perf report test
##- @Detail: 
#######################################################################*/

######################################################################
##- @Description: check return code and datafile
######################################################################
check_result_report()
{
    local rc=$1
    local file1=$2
    local file2=$3
    has_content $file1 $file2
    if [ $rc -ne 0 ];then
        echo "TFAIL: perf report error!"
        RC=`expr $RC + 1`
    else
        diff $file1 $file2
        if [ $? -ne 0 ];then
            echo "TFAIL: perf reports are different"
            RC=`expr $RC + 1`
        else 
            echo "TPASS: perf report checked"
        fi
    fi
}

######################################################################
##- @Description: check return code and datafile
######################################################################
check_result_report_ingore_comment()
{
    local rc=$1
    local file1=$2
    local file2=$3
    has_content $file1 $file2
    if [ $rc -ne 0 ];then
        echo "TFAIL: perf report error!"
        RC=`expr $RC + 1`
    else
        diff -u -B <(grep -vE '^\s*(#|$)' $file1)  <(grep -vE '^\s*(#|$)' $file2)
        if [ $? -ne 0 ];then
            echo "TFAIL: perf reports are different"
            RC=`expr $RC + 1`
        else
            echo "TPASS: perf report checked"
        fi
    fi
}

######################################################################
##- @Description: set values of variables
######################################################################
prepare_tmp_report()
{
    prepare_tmp
    datafile=${TCTMP}/report_tc-$$.data
    report_file1=${TCTMP}/report_tc-$$.report1
    report_file2=${TCTMP}/report_tc-$$.report2
}
