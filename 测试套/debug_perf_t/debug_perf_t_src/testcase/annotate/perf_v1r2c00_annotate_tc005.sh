#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: perf_v1r2c00_annotate_tc005
##- @Author: z00314551
##- @Date: 2018-11-11
##- @Precon: 1.支持perf功能
#            2.支持expand,addr2line,objdump
#            3.可执行程序编译带-g选项
##- @Brief: perf annotate基本命令可用1
##- @Detail: 1.编写可执行程序，使用到动态库
#            2.perf record ./test
#            3.perf annotate --asm-raw
##- @Expect: 长短选项输出相同
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
    annotatefile=annotate_tc001-$$.annotate
    datafile=annotate_tc002-$$.data
    hotspot_in_lib=anno_hotspot1
    hotspot_in_app=anno_hotspot2

    cp ${USE_HUGE}common_while_lib_d ${TCTMP}
    cd $TCTMP
    ${USE_HUGE}common_while_lib_d > /dev/null &
    PID=$!

}
######################################################################
##- @Description: do perf record then
######################################################################
dotest()
{
    perf record -p $PID -o ${datafile} sleep 2 2>/dev/null
    perf annotate -i ${datafile} --asm-raw  > ${annotatefile}1
    check_ret_code $?
    check_msg="Source code & Disassembly of ${USE_HUGE}common_while_lib_d"
    check_in_file "$check_msg" ${annotatefile}1
    check_in_file $hotspot_in_lib ${annotatefile}1
    check_in_file $hotspot_in_app ${annotatefile}1

}
######################################################################
##- @Description: ending,clear the program env.
######################################################################
cleanenv()
{
    kill -9 $PID > /dev/null 2>&1
    clean_end
}
######################################################################
##-@ Description:  main function
######################################################################
use_huge $*
prepareenv
dotest
cleanenv
