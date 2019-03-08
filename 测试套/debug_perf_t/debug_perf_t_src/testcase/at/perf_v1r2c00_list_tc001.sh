#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: perf_v1r2c00_list_tc001
##- @Author: y00197803
##- @Date: 2013-4-17
##- @Precon: 1.支持perf功能
##- @Brief: perf list基本命令可用1
##- @Detail: 1.perf list
##- @Expect: 输出包含关键字：Hardware event，Software event，Hardware cache event，Raw hardware event descriptor，Hardware breakpoint，Tracepoint event种类型的事件
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
    list_file1=${TCTMP}/list_tc001-$$.list1
    list_file2=${TCTMP}/list_tc001-$$.list2
}
######################################################################
##- @Description: 
######################################################################
dotest()
{
    perf list > $list_file1
    check_in_file 'Hardware event' $list_file1
    check_in_file 'Software event' $list_file1
    check_in_file 'Hardware cache event' $list_file1
    check_in_file 'Raw hardware event descriptor' $list_file1
    check_in_file 'Hardware breakpoint' $list_file1
    check_in_file 'Tracepoint event' $list_file1
    perf list > $list_file2
    func_is_diff $list_file1 $list_file2
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
