#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2019, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: perf_v1r2c00_stat_tc005
##- @Author: z00314551
##- @Date: 2019-1-14
##- @Precon: 1.֧��perf����
##- @Brief: perf stat
##- @Detail: test perf stat -o
#            1.perf stat -o file ./test
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
    perf stat -o ${stat_file} ${USE_HUGE}common_prg_1 2>/dev/null
    check_ret_code $?
    has_content ${stat_file}
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
