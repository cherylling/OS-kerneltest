#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: perf_v1r2c00_stat_tc003
##- @Author: y00197803
##- @Date: 2013-4-17
##- @Precon: 1.支持perf功能
##- @Brief: perf stat -G基本功能
##- @Detail: perf stat -e branch-load-misses -G xxx
##- @Expect: 能输出结果
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
    func_is_support file=${TCBIN}../config/stat.help -G --cgroup
    prepare_tmp
    statfile1=stat_tc003-$$.stat1
    statfile2=stat_tc003-$$.stat2

    cgroupname=cgroup-$$
    mkdir ${TCTMP}/$cgroupname
    mount -t cgroup -ocpu none ${TCTMP}/$cgroupname
    mkdir ${TCTMP}/$cgroupname/sub$cgroupname

    cd $TCTMP
    ${USE_HUGE}common_while_1 > /dev/null &
    PID=$!
    echo $PID > ${TCTMP}/$cgroupname/sub$cgroupname/tasks
}

######################################################################
##- @Description: 
######################################################################
dotest()
{
    perf stat -e branch-load-misses -G sub$cgroupname 2>$statfile1
    check_ret_code $?
    perf stat -e branch-load-misses --cgroup sub$cgroupname 2>$statfile2
    check_ret_code $?
    has_content $stat_file1 $stat_file2
}

######################################################################
##- @Description: ending,clear the program env.
######################################################################
cleanenv()
{
    kill -9 $PID > /dev/null 2>&1
    rmdir ${TCTMP}/$cgroupname/sub$cgroupname
    umount ${TCTMP}/$cgroupname
    clean_end
}

######################################################################
##-@ Description:  main function
######################################################################
use_huge $*
prepareenv
dotest
cleanenv
