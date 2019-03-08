#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: perf_v1r2c00_record_tc001
##- @Author: y00197803
##- @Date: 2013-4-17
##- @Precon: 1.支持perf功能
##- @Brief: perf record基本命令可用1
##- @Detail: 1.perf record -e cpu-clock -p $PID -t $PID -r 55 -R -a -C 2 -f -c 2 -o 1.data -i -F 100 -m 1 -g -v -q -s -d -n -N sleep 1
#            2.perf record --event cpu-clock --pid $PID --tid $PID --realtime 55 --raw-samples --all-cpus --cpu 2 --force --count 2 --output 1.data --no-inherit --freq 100 --mmap-pages 1 --call-graph --verbose --quiet --stat --data --no-samples --no-buildid-cache sleep 1
##- @Expect: 生成1.data
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
    datafile=record_tc001-$$.data
    ${USE_HUGE}common_while_1 > /dev/null &
    PID=$!
}

######################################################################
##- @Description: do perf record then check the return code and datafile
######################################################################
dotest()
{
    # linux 3.11 delete 'perf record -f'
    # commit: 4a4d371a4dfbd3b84a7eab8d535d4c7c3647b09e
    # patch name: perf record: Remove -f/--force option
    perf_vcmp 3 11
    if [ $? -eq 1 ];then
        opt1=""
        opt2=""
    else
        opt1="-f"
        opt2="--force"
    fi

    in_root=`cat /sys/fs/cgroup/cpu/tasks | grep $$`
    if [ -z "$in_root"]; then
        rt_s_opt=""
        rt_l_opt=""
    else
        rt_s_opt="-r 55"
        rt_l_opt="--realtime 55"
    fi

    perf record -e cpu-clock -p $PID -t $PID $rt_s_opt -R -a -C 2 $opt1 -c 2 -o $datafile -i -F 100 -m 1 -g -v -q -s -d -n -N sleep 1
    check_ret_code $?
    has_file $datafile
    has_file perf.data 0
    perf record --event cpu-clock --pid $PID --tid $PID $rt_l_opt --raw-samples --all-cpus --cpu 2 $opt2 --count 2 --output $datafile --no-inherit --freq 100 --mmap-pages 1 --call-graph fp --verbose --quiet --stat --data --no-samples --no-buildid-cache sleep 1
    check_ret_code $?
    has_file $datafile
    has_file perf.data 0
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
