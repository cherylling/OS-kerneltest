#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: perf_v1r2c00_report_tc003
##- @Author: y00197803
##- @Date: 2013-4-17
##- @Precon: 1.支持perf功能
##- @Brief: perf mem选项测试
##- @Detail: 1.perf mem record ./test
#            2.perf mem -t store/load record
#            3.perf mem report
##- @Expect: 能输出结果，结果一致
##- @Level: Level 2
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
    data_file=${TCTMP}/mem_tc001-$$.data
    store_data_file=${TCTMP}/mem_store_tc001-$$.data
    load_data_file=${TCTMP}/mem_load_tc001-$$.data
    report_file=${TCTMP}/mem_tc001-$$.report
    store_report_file=${TCTMP}/mem_store_tc001-$$.report
    load_report_file=${TCTMP}/mem_load_tc001-$$.report
    exce_file=tc_perf_mem_01
    hotspot_in_file=longa
}

######################################################################
##- @Description:
######################################################################
dotest()
{
    perf mem record -o $data_file $exce_file 2>/dev/null
    check_ret_code $?
    perf mem report -i $data_file > ${report_file}
    check_ret_code $?
    check_in_file $hotspot_in_file ${report_file}

    perf mem -t store record -o $store_data_file $exce_file 2>/dev/null
    check_ret_code $?
    perf mem report -i $store_data_file > ${store_report_file}
    check_ret_code $?
    check_in_file $hotspot_in_file ${store_report_file}

    perf mem -t load record -o $load_data_file $exce_file 2>/dev/null
    check_ret_code $?
    perf mem report -i $load_data_file > ${load_report_file}
    check_ret_code $?
    check_in_file $hotspot_in_file ${load_report_file}
}

cleanenv()
{
    clean_end
}
######################################################################
##-@ Description:  main function
######################################################################
prepareenv
dotest
cleanenv
