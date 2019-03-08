#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: perf_v1r2c00_stat_tc002
##- @Author: y00197803
##- @Date: 2013-4-17
##- @Precon: 1.支持perf功能
##- @Brief: perf stat基本命令可用1
##- @Detail: 1.perf stat -e page-faults -p $PID -t $PID -i -a -c -v -r 2 -B sleep 2
#            2.perf stat --event cpu-clock --pid $PID --tid $PID --no-inherit --all-cpus --scale --verbose --repeat 2 --big-num sleep 2
##- @Expect: 能输出结果
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
    stat_file1=${TCTMP}/stat_tc002-$$.stat1
    stat_file2=${TCTMP}/stat_tc002-$$.stat2
    cd ${TCTMP}
    ${USE_HUGE}common_while_1 > /dev/null &
    PID=$!
}

######################################################################
##- @Description: 
######################################################################
dotest()
{
    perf stat -e page-faults -p $PID -t $PID -i -a -c -v -r 2 -B sleep 2 2>$stat_file1
    check_ret_code $?
    perf stat --event cpu-clock --pid $PID --tid $PID --no-inherit --all-cpus --scale --verbose --repeat 2 --big-num sleep 2 2>$stat_file2
    check_ret_code $?
    has_content $stat_file1 $stat_file2
}

######################################################################
##- @Description: ending,clear the program env.
######################################################################
cleanenv()
{
    kill -9 $PID > /dev/null 2>&1
    clean_end
}
######################################################################
##-@ Description:  main function
######################################################################
use_huge $*
prepareenv
dotest
cleanenv
