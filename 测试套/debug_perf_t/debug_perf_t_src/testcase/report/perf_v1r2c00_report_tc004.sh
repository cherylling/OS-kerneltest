#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: perf_v1r2c00_report_tc004
##- @Author: y00197803
##- @Date: 2013-4-17
##- @Precon: 1.支持perf功能
##- @Brief: perf report --symfs
##- @Detail: 1.编写一个进程test，进程中有函数func
#            2.perf record ./test
#            3.perf report --symfs=/tmp > log1
#            4.perf report --symfs=. > log2，其中.目录下必须按照编译时的结构存有可执行程序
##- @Expect: log1中无法找到符号，log2中可以找到符号
##- @Level: Level 2
##- @Auto:
##- @Modify:
#######################################################################*/
. ${TCBIN}./common_perf.sh
. ${TCBIN}./perf_v1r2c00_report_common.sh
######################################################################
##- @Description: prepare,set the init env.
######################################################################
prepareenv()
{
    func_is_support file=${TCBIN}../config/report.help --symfs
    prepare_tmp_report
    #for --symfs need this directory
    MK_DIR=${TCBIN#/}
    MK_DIR_TOP=${MK_DIR%%/*}
    mkdir -p $MK_DIR
    cp ${USE_HUGE}report_tc004 $MK_DIR

    ./${USE_HUGE}report_tc004 > /dev/null &
    PID=$!
    perf record -o $datafile -p $PID sleep 2
}

######################################################################
##- @Description: 
#       1.do perf report --symfs=/tmp ,report1 with no symbol like hotspot
#       2.do perf report --symfs=. ,report2 with symbol hotspot
######################################################################
dotest()
{
    perf report -i $datafile --symfs=/tmp > $report_file1
    check_in_file hotspot_1 $report_file1 0 
    check_in_file hotspot_2 $report_file1 0
    perf report -i $datafile --symfs=. > $report_file2
    check_in_file hotspot_1 $report_file2
    check_in_file hotspot_2 $report_file2
}

######################################################################
##- @Description: 
######################################################################
cleanenv()
{
    kill -9 $PID
    rm -rf $MK_DIR_TOP
    clean_end
}
######################################################################
##-@ Description:  main function
######################################################################
use_huge $*
prepareenv
dotest
cleanenv
