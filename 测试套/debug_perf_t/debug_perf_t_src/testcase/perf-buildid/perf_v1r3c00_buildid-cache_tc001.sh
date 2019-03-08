#!/bin/bash
#######################################################################
##- @Copyright (C), 2018-2050, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: perf_v1r2c00_buildid-cache_tc001
##- @Author: l00275356
##- @Date: 2018-11-29
##- @Precon:
##- @Brief:
##- @Detail: perf buildid-cache {-u|-r|-a} $EXE
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
    BUILDID_PATH=~/.debug/$TCBIN/$EXE
}

######################################################################
##- @Description:
######################################################################
dotest()
{
    perf record $EXE

    perf buildid-cache -u $EXE
    ret=$?
    check_ret_code $ret
    ret=`ls $BUILDID_PATH | wc -l`
    check_ret_code $ret 1

    perf buildid-cache -r $EXE
    ret=$?
    check_ret_code $ret
    ret=`ls $BUILDID_PATH | wc -l`
    check_ret_code $ret 0

    perf buildid-cache -a $EXE
    ret=$?
    check_ret_code $ret
    ret=`ls $BUILDID_PATH | wc -l`
    check_ret_code $ret 1

}
cleanenv()
{
    exit $RC
}
######################################################################
##-@ Description:  main function
######################################################################
prepareenv
dotest
cleanenv
