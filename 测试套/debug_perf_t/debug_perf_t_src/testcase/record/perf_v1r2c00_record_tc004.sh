#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: perf_v1r2c00_record_tc004
##- @Author: y00197803
##- @Date: 2013-4-17
##- @Precon: 1.支持perf功能
##- @Brief: perf record -G基本功能验证
##- @Detail: 1.-G(--cgroup),将进程加入Cgroup,监控cgroup
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
    func_is_support file=${TCBIN}../config/record.help -G --cgroup
    prepare_tmp
    datafile=record_tc004-$$.data

    mkdir ${TCTMP}/cgroup
    mount -t cgroup -ocpu none ${TCTMP}/cgroup
    mkdir ${TCTMP}/cgroup/subcgroup

    cd $TCTMP
    ${USE_HUGE}common_while_1 > /dev/null &
    PID=$!
    ONCPU=`cat ${TCTMP}/common_while_1.oncpu`
    echo $PID > ${TCTMP}/cgroup/subcgroup/tasks
}

######################################################################
##- @Description: 
######################################################################
dotest()
{
    perf record -o $datafile -C $ONCPU -G subcgroup 2>/dev/null
    check_ret_code $?
    has_file $datafile
    has_file perf.data 0
    perf record -o $datafile --cpu $ONCPU --cgroup subcgroup 2>/dev/null
    check_result_record $? $datafile
    has_file perf.data 0
}

######################################################################
##- @Description: ending,clear the program env.
######################################################################
cleanenv()
{
    kill -9 $PID > /dev/null 2>&1
    rmdir ${TCTMP}/cgroup/subcgroup
    umount ${TCTMP}/cgroup
    clean_end
}

######################################################################
##-@ Description:  main function
######################################################################
use_huge $*
prepareenv
dotest
cleanenv
