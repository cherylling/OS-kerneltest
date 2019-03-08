#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2019, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: perf_v1r2c00_stat_tc007
##- @Author: z00314551
##- @Date: 2019-1-14
##- @Precon: 1.֧��perf����
##- @Brief: perf stat
##- @Detail: test perf stat -x
#            1.perf stat -x ./test
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
    cd $TCTMP
}

######################################################################
##- @Description: 
######################################################################
dotest()
{
    rm -f ${stat_file}
    perf stat -x SEP ${USE_HUGE}common_prg_1 2>${stat_file}
    check_ret_code $?
    check_in_file SEP ${stat_file}
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
