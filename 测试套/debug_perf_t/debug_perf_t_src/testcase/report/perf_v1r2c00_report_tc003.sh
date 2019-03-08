#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: perf_v1r2c00_report_tc003
##- @Author: y00197803
##- @Date: 2013-4-17
##- @Precon: 1.支持perf功能
##- @Brief: perf report部分版本不支持选项
##- @Detail: 1.perf record ./test 
#            2.perf report -d aaa -C bbb -S cc -D > 1
#            3.perf report --dso aaa --comms bbb --symbols cc --dump-raw-trace --pretty 1 --tui --stdio > 1
##- @Expect: 能输出结果，结果一致
##- @Level: Level 2
##- @Auto:
##- @Modify:
#######################################################################*/
. ${TCBIN}./common_perf.sh
. ${TCBIN}./perf_v1r2c00_report_common.sh
######################################################################
##- @Description: prepare,set the init env.
######################################################################
prepareenv()
{
    func_is_support file=${TCBIN}../config/report.help -d -c -S -D --dso --comms --symbols --dump-raw-trace --pretty --tui --stdio
    prepare_tmp_report
    perf record -o $datafile -g --call-graph fp ${USE_HUGE}common_prg_1 > /dev/null 2>&1
}

######################################################################
##- @Description: 
######################################################################
dotest()
{
    perf report -i $datafile -d aaa -c bbb -S cc -D --pretty 1 --tui --stdio > $report_file1
    perf report -i $datafile --dso aaa --comms bbb --symbols cc --dump-raw-tra --pretty 1 --tui --stdio > $report_file2
    check_result_report $? $report_file1 $report_file2
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
