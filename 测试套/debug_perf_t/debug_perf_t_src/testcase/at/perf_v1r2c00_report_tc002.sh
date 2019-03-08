#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: perf_v1r2c00_report_tc002
##- @Author: y00197803
##- @Date: 2013-4-17
##- @Precon: 1.支持perf功能
##- @Brief: perf report基本命令可用2
##- @Detail: 1.perf record –g ./test
#            2.perf report -p 1 --showcpuutilization > 1
#            3.perf report --parent 1 --showcpuutilization > 1
#            
##- @Expect: 能输出结果，结果一致
##- @Level: Level 1
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
    func_is_support file=${TCBIN}../config/report.help -p --parent --showcpuutilization
    prepare_tmp_report
    perf record -o $datafile -g ${USE_HUGE}common_prg_1 > /dev/null 2>&1
}

######################################################################
##- @Description: 
######################################################################
dotest()
{
    perf report -i $datafile -p 1 --showcpuutilization > $report_file1
    perf report -i $datafile --parent 1 --showcpuutilization > $report_file2
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
