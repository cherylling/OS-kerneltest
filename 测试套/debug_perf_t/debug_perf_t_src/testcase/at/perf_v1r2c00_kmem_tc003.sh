#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: perf_v1r2c00_kmem_tc003
##- @Author: y00197803
##- @Date: 2013-4-17
##- @Precon: 1.支持perf功能
##- @Brief: perf kmem基本命令可用2
##- @Detail: 1.perf kmem stat -i 1.data --caller -s hit,pingpong,frag,ptr,callsite,bytes -l 10
#            2.perf kmem stat --input 1.data --caller --sort hit,pingpong,frag,ptr,callsite,bytes --line 10
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
    datafile=${TCTMP}/perf_v1r2c00_kmem_tc-$$.data
    report_file1=${TCTMP}/perf_v1r2c00_kmem_tc-$$.report1
    report_file2=${TCTMP}/perf_v1r2c00_kmem_tc-$$.report2
    perf kmem record sleep 0.1 2>/dev/null
    mv perf.data $datafile
}

######################################################################
##- @Description: 
######################################################################
dotest()
{
    perf kmem stat -i $datafile --caller -s hit,pingpong,frag,ptr,callsite,bytes -l 10 > $report_file1
    perf kmem stat --input $datafile --caller --sort hit,pingpong,frag,ptr,callsite,bytes --line 10 > $report_file2
    sleep 3
    cat $report_file1
    cat $report_file2
    check_ret_code $?
    has_content $report_file1 $report_file2
    func_is_diff $report_file1 $report_file2
}

cleanenv()
{
    clean_end
}
######################################################################
##-@ Description:  main function
######################################################################
prepareenv
dotest
cleanenv
