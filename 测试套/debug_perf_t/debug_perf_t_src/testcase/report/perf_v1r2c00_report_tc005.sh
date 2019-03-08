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

# linux v4.4-rc1 rename "--showcpuutilization" to "--show-cpu-utilization"
# commit: b272a59d835cd8ca6b45f41c66c61b473996c759
# patch name: perf report: Rename to --show-cpu-utilization
perf_vcmp 4 4
if [ $? -eq 1 ];then
	opt_show_cpu_utilization="--show-cpu-utilization"
else
	opt_show_cpu_utilization="--showcpuutilization"
fi

######################################################################
##- @Description: prepare,set the init env.
######################################################################
prepareenv()
{
    func_is_support file=${TCBIN}../config/report.help $opt_show_cpu_utilization --show-total-period
    prepare_tmp_report
    test_report1=sys
    test_report2=usr
    test_report3=Period
    perf record -o $datafile -g --call-graph fp ${USE_HUGE}common_prg_1 > /dev/null 2>&1
}

######################################################################
##- @Description:
######################################################################
dotest()
{
    perf report -i $datafile $opt_show_cpu_utilization --show-total-period > $report_file1
    check_ret_code $?
    check_in_file $test_report1 $report_file1
    check_in_file $test_report2 $report_file1
    check_in_file $test_report3 $report_file1

    perf report -i $datafile --asm-raw > $report_file2
    check_ret_code $?
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
