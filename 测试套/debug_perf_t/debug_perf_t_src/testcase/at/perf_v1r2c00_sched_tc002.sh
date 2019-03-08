#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: perf_v1r2c00_sched_tc002
##- @Author: y00197803
##- @Date: 2013-4-17
##- @Precon: 1.支持perf功能
##- @Brief: perf sched latency
##- @Detail: 1.perf sched -i 1.data -v -D latency
#            2.perf sched --input 1.data --verbose --dump-raw-trace latency
##- @Expect: 能输出结果，结果一致
##- @Level: Level 1
##- @Auto:
##- @Modify:
#######################################################################*/
. ${TCBIN}./common_perf.sh
######################################################################
##- @Description: prepare,set the init env.
######################################################################
prepareenv()
{
    prepare_tmp
    cd $TCTMP
    perf sched record -o /tmp/perf.data sleep 2 2>/dev/null
    datafile=sched_tc002-$$.data
    report_file1=sched_tc002-$$.report1
    report_file2=sched_tc002-$$.report2
    mv /tmp/perf.data $datafile
}

######################################################################
##- @Description: 
######################################################################
dotest()
{
    perf sched -i $datafile -v -D latency > $report_file1
    check_ret_code $?
    perf sched --input $datafile --verbose --dump-raw-trace latency > $report_file2
    check_ret_code $?
    has_content $report_file1 $report_file2
    check_in_file perf $report_file1
    check_in_file perf $report_file2
    func_is_diff $report_file1 $report_file2
}

cleanenv()
{
    rm /tmp/perf.data -rf
    clean_end
}
######################################################################
##-@ Description:  main function
######################################################################
prepareenv
dotest
cleanenv
