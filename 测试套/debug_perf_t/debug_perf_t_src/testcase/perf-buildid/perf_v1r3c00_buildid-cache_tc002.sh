#!/bin/bash
#######################################################################
##- @Copyright (C), 2018-2050, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: perf_v1r2c00_buildid-cache_tc002
##- @Author: l00275356
##- @Date: 2018-11-29
##- @Precon:
##- @Brief:
##- @Detail: perf buildid-cache -M $EXE
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
    EXE=tc_perf_buildid_01
    TMPFILE=M.tmp
    BUILDID_PATH=~/.debug/$TCBIN/$EXE
    PERF_DATA_PATH=/tmp/perf.data
    rm -f $PERF_DATA_PATH
}

######################################################################
##- @Description:
######################################################################
dotest()
{
    perf record -o $PERF_DATA_PATH $EXE
    ret=$?
    check_ret_code $ret
    has_file $PERF_DATA_PATH

    CHECK=`ls $BUILDID_PATH`

    perf buildid-cache -M $PERF_DATA_PATH -v 2>$TMPFILE
    ret=$?
    check_ret_code $ret
    check_in_file $CHECK $TMPFILE

    ret=`perf buildid-cache -M $PERF_DATA_PATH | wc -l`
    check_ret_code $ret 0
    perf buildid-cache -r $EXE
    ret=`perf buildid-cache -M $PERF_DATA_PATH | wc -l`
    check_ret_code $ret 1
    perf buildid-cache -u $EXE
}
cleanenv()
{
    rm -f $TMPFILE $PERF_DATA_PATH
    exit $RC
}
######################################################################
##-@ Description:  main function
######################################################################
prepareenv
dotest
cleanenv
