#!/bin/bash
#######################################################################
##- @Copyright (C), 2018-2050, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: perf_v1r2c00_archive_tc001
##- @Author: l00275356
##- @Date: 2018-11-29
##- @Precon:
##- @Brief:
##- @Detail: perf archive perf.data
##- @Expect:
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
    RC=0
    PERF_DATA=/tmp/perf.data
    ARCHIVE_DATA=/tmp/perf.data.tar.bz2
    rm -f $PERF_DATA $ARCHIVE_DATA
}

######################################################################
##- @Description:
######################################################################
dotest()
{
    perf record -o $PERF_DATA ./tc_perf_buildid_01
    ret=$?
    check_ret_code $ret
    has_file $PERF_DATA

    perf archive $PERF_DATA
    ret=$?
    check_ret_code $ret
    has_file $ARCHIVE_DATA
}
cleanenv()
{
    rm -f $PERF_DATA $ARCHIVE_DATA
    exit $RC
}
######################################################################
##-@ Description:  main function
######################################################################
prepareenv
dotest
cleanenv
