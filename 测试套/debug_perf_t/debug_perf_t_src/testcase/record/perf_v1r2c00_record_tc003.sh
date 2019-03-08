#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: perf_v1r2c00_record_tc003
##- @Author: y00197803
##- @Date: 2013-4-17
##- @Precon: 1.支持perf功能
##- @Brief: perf record 基本命令可用3
##- @Detail: 1.perf record -D -T -B ./test
#            2.perf record --no-delay --timestamp --no-buildid ./test
##- @Expect: 生成perf.data
##- @Level: Level 2
##- @Auto:
##- @Modify:
#######################################################################*/
. ${TCBIN}./common_perf.sh
######################################################################
##- @Description: prepare,set the init env.
######################################################################
#if [ `arch` != "aarch64" ];then
#perf_vcmp 4 0
#if [ $? -eq 1 ];then
#	Doption="-D"
#else
	Doption="-D 0"
#fi

prepareenv()
{
    func_is_support file=${TCBIN}../config/record.help $Doption -T -B --no-delay --timestamp --no-buildid
    prepare_tmp
    datafile=${TCTMP}/record_tc003-$$.data
}

######################################################################
##- @Description: 
######################################################################
dotest()
{
    perf record -o $datafile $Doption -T -B ${USE_HUGE}common_prg_1 2>/dev/null
    check_ret_code $?
    has_file $datafile
    perf record -o $datafile --no-delay --timestamp --no-buildid ${USE_HUGE}common_prg_1 2>/dev/null
    check_ret_code $?
    has_file $datafile
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
