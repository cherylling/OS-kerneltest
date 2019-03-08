#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: perf_v1r2c00_record_tc002
##- @Author: y00197803
##- @Date: 2013-4-17
##- @Precon: 1.支持perf功能
##- @Brief: perf record -A基本命令可用2
##- @Detail: 1.perf record ./test -A
#            2.perf record ./test --append
##- @Expect: 生成perf.data
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
    datafile=${TCTMP}/record_tc002-$$.data
}

######################################################################
##- @Description: 
######################################################################
dotest()
{
    perf record -o $datafile -A ${USE_HUGE}common_prg_1 2>/dev/null
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "If there arm some error such as : failed to mmap with 22,
                Then you need rebuild the perf command with necessary lib"
    fi

    check_ret_code $ret
    has_file $datafile
    perf record -o $datafile --append ${USE_HUGE}common_prg_1 2>/dev/null
    check_ret_code $?
    has_file $datafile
}

cleanenv()
{
    clean_end
}
######################################################################
##-@ Description:  main function
######################################################################
use_huge $*
prepareenv
dotest
cleanenv
