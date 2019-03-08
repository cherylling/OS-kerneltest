#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: perf_v1r2c00_report_tc001
##- @Author: y00197803
##- @Date: 2013-4-17
##- @Precon: 1.支持perf功能
##- @Brief: perf report基本命令可用1
##- @Detail: 1.perf record -o 1.data -g -B ./test
#            2.perf report -i 1.data -v -k /tmp -f -m -n -T -s pid,comm,dso,symbol,parent -x -g -w 1 -t xx -U > 1
#            3.perf report --input 1.data --verbose --vmlinux /tmp --force --modules --show-nr-samples --threads --sort pid,comm,dso,symbol,parent --exclude-other --call-graph --column-widths 1 --field-separator xx --hide-unresolved > 1
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
    prepare_tmp_report
    vmlinux_path=${TCBIN}../config/vmlinux
    perf record -o $datafile -g --call-graph fp ./${USE_HUGE}common_prg_1 > /dev/null 2>&1
}

######################################################################
##- @Description: 
######################################################################
dotest()
{
    perf report -i $datafile -v -k $vmlinux_path -f -m -n -T -s pid,comm,dso,symbol,parent -x -g -w 1 -t xx> $report_file1 2>/dev/null
    perf report --input $datafile --verbose --vmlinux $vmlinux_path --force --modules --show-nr-samples --threads --sort pid,comm,dso,symbol,parent --exclude-other --call-graph --column-widths 1 --field-separator xx > $report_file2 2>/dev/null
    check_result_report_ingore_comment $? $report_file1 $report_file2
    perf report -i $datafile -U > ${report_file1}1
    perf report -i $datafile --hide-unresolved > ${report_file1}2
    check_result_report_ingore_comment $? ${report_file1}1 ${report_file1}2
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
