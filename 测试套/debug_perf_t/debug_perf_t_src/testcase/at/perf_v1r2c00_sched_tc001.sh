#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: perf_v1r2c00_sched_tc001
##- @Author: y00197803
##- @Date: 2013-4-17
##- @Precon: 1.支持perf功能
##- @Brief: perf sched record
##- @Detail: perf sched record sleep 2
##- @Expect: 1.生成perf.data
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
}

######################################################################
##- @Description: 
######################################################################
dotest()
{
    perf sched record -o /tmp/perf.data sleep 2 2>/dev/null
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "If there arm some error such as : Assertion 'ret != -1',
                Then you need rebuild the perf command with necessary lib"
    fi

    check_ret_code $ret
    has_file /tmp/perf.data
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
