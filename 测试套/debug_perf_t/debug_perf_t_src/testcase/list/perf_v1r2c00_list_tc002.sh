#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: perf_v1r2c00_list_tc002
##- @Author: y00197803
##- @Date: 2013-4-17
##- @Precon: 1.支持perf功能
##- @Brief: perf list基本命令可用2
##- @Detail: 1.perf list event_glob hw sw cache tracepoint
##- @Expect: 与perf list仅差2行
##- @Level: Level 2
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
    list_file1=${TCTMP}/list_tc002-$$.list1
    list_file2=${TCTMP}/list_tc002-$$.list2
}

######################################################################
##- @Description: 
######################################################################
dotest()
{
    ret=`perf list -h | grep pmu`
    if [ -n $ret ]; then
        opt_pmu="pmu"
    else
        opt_pmu=""
    fi

    ret=`perf list -h | grep sdt`
    if [ -n $ret ]; then
        opt_sdt="sdt"
    else
        opt_sdt=""
    fi

    perf list event_glob hw sw cache $opt_pmu tracepoint $opt_sdt > $list_file1
    perf list > $list_file2
    sed -i '/^$/d' $list_file1
    sed -i '/^$/d' $list_file2

    sed -i '/rNNN/d' $list_file2
    sed -i '/Hardware breakpoint/d' $list_file2

    sed -i '/cpu\/t1=v1/d' $list_file2
	sed -i '/(see\ /d' $list_file2

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
