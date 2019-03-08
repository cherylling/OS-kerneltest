#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2019, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: perf_v1r2c00_stat_tc004
##- @Author: z00314551
##- @Date: 2019-1-14
##- @Precon: 1.֧��perf����
##- @Brief: perf stat
##- @Detail: test perf stat -C
#            1.perf stat -C -A ./test
##- @Expect: ��������
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
    stat_file=stat.data
    cpuNum=`cat /proc/cpuinfo | grep -i "processor[[:blank:]]\{1,\}:[[:blank:]]\{1,\}[[:digit:]]" | wc -l`
    ((cpuNum--)) 
    cd $TCTMP
}

######################################################################
##- @Description: 
######################################################################
dotest()
{
    perf stat -C 0-${cpuNum} -A ${USE_HUGE}common_prg_1 2>$stat_file
    check_ret_code $?
    check_in_file CPU0 ${stat_file}
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
