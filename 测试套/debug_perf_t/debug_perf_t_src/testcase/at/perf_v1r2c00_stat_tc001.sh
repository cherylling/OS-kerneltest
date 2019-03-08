#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: perf_v1r2c00_stat_tc001
##- @Author: y00197803
##- @Date: 2013-4-17
##- @Precon: 1.支持perf功能
##- @Brief: perf stat
##- @Detail: test perf stat option that in perf_v1r2c00_stat_common.list
#            1.perf stat ./test
#            2.perf stat -n -C 2 ./test
#            3.perf stat --null --cpu 2 ./test
#            4.perf stat -d -S -A -a -x xxx ./test
#            5.perf stat --detailed --sync --no-aggr --all-cpus --field-separator xxx ./test
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
    option_file=${TCBIN}../config/perf_v1r2c00_stat_common.list
    prepare_tmp
    lines=`cat $option_file | wc -l`
    [ $lines -le 0 ] && echo "TFAIL: no option in list" && exit 1
}

######################################################################
##- @Description: 
######################################################################
dotest()
{
    line=0
    while [ $line -lt $lines ];do
        line=`expr $line + 1`
        stat_file=${TCTMP}/stat_tc001-$$.stat$line
        option=`sed -n "$line"p $option_file`
        perf stat $option ${USE_HUGE}common_prg_1 2>$stat_file
        check_ret_code $?
        has_content $stat_file
        echo "perf stat $option ${USE_HUGE}common_prg_1" >> $stat_file
    done
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
