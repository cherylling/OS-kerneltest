#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: perf_v1r2c00_annotate_tc002
##- @Author: y00197803
##- @Date: 2013-4-29
##- @Precon: 1.支持perf功能
#            2.支持expand,addr2line,objdump
#            3.可执行程序编译带-g选项
##- @Brief: perf annotate基本命令可用1
##- @Detail: 1.编写可执行程序，使用动态库libxx.so
#            2.perf record ./test -o 1.data
#            3.perf annotate -i 1.data -d libxx.so -s xx（xx是libxx.so中的热点）
#            4.验证perf annotate --input --dsos --symbol与perf annotate -i -d -s相同
#            5.perf annotate -i 1.data -d libxx.so -s yy(yy不是libxx.so中的热点，是test中的热点)
#            6.perf annotate -i 1.data -d libxx.so -s xx -P
##- @Expect: 能输出结果，并且结果信息正确
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
    reportfile=${TCTMP}/annotate_tc002-$$.report
    annotatefile=${TCTMP}/annotate_tc002-$$.annotate
    datafile=${TCTMP}/annotate_tc002-$$.data
    so_name=libcommon_while_lib.so
    hotspot_in_lib=anno_hotspot1
    hotspot_in_app=anno_hotspot2

    #common_while_lib_d use libcommon_while_lib.so
	[ -e /tmp/${USE_HUGE}common_while_lib_d ] && rm -rf /tmp/${USE_HUGE}common_while_lib_d
	cp ${USE_HUGE}common_while_lib_d /tmp
    LD_LIBRARY_PATH=${TCBIN}../../lib /tmp/${USE_HUGE}common_while_lib_d &
    PID=$!
}
######################################################################
##- @Description: do perf record then 
######################################################################
dotest()
{
    #check annotate -d -s
    perf record -p $PID -o ${datafile} sleep 5 2>/dev/null
    perf report -i ${datafile} > ${reportfile}
    check_ret_code $?
    check_in_file $hotspot_in_lib ${reportfile}
    check_in_file $hotspot_in_app ${reportfile}
    perf annotate -i ${datafile} -d ${so_name} -s $hotspot_in_lib > ${annotatefile}1
    check_ret_code $?
    check_msg="Source code & Disassembly of $so_name"
    check_in_file "$check_msg" ${annotatefile}1
    check_in_file $hotspot_in_lib ${annotatefile}1
    check_in_file $hotspot_in_app ${annotatefile}1 0
    #-i -d -s should be the same with --input --dsos --symbol
    perf annotate --input ${datafile} --dsos ${so_name} --symbol $hotspot_in_lib > ${annotatefile}11
    check_ret_code $?
    has_content ${annotatefile}11
    func_is_diff ${annotatefile}1 ${annotatefile}11
    #
    perf annotate -i ${datafile} -d ${so_name} -s $hotspot_in_app > ${annotatefile}2
    check_ret_code $?
    has_content ${annotatefile}2 0
    #check annotate -P
    perf annotate -i ${datafile} -d ${so_name} -s $hotspot_in_lib -P > ${annotatefile}3
    check_in_file "Source code & Disassembly of /" ${annotatefile}3
}
######################################################################
##- @Description: ending,clear the program env
######################################################################
cleanenv()
{
    kill -9 $PID > /dev/null 2>&1
	[ -e /tmp/${USE_HUGE}common_while_lib_d ] && rm -rf /tmp/${USE_HUGE}common_while_lib_d
    clean_end
}

######################################################################
##-@ Description:  main function
######################################################################
use_huge $*
prepareenv
dotest
cleanenv
