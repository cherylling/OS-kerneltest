#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: perf_v1r2c00_annotate_tc003
##- @Author: y00197803
##- @Date: 2013-4-28
##- @Precon: 1.支持perf功能
#            2.支持expand,addr2line,objdump
#            3.可执行程序编译带-g选项
##- @Brief: perf annotate基本命令可用1
##- @Detail: 1.编写可执行程序，程序中含有热点aa
#            2.perf record ./test
#            3.perf report
#            4.perf annotate -l -s aa
#            5.perf annotate --print-line -s aa
##- @Expect: 能输出结果
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
    reportfile=annotate_tc003-$$.report
    perf_data_path=/tmp/perf.data
    annotatefile=annotate_tc003-$$.annotate
    [ -e /tmp/${USE_HUGE}common_while_1 ] && rm -rf /tmp/${USE_HUGE}common_while_1
	cp ${USE_HUGE}common_while_1 /tmp/
    /tmp/${USE_HUGE}common_while_1 > /dev/null &
    PID=$!
    cd $TCTMP
}
######################################################################
##- @Description: do perf record then 
######################################################################
dotest()
{
    perf record -o $perf_data_path -p $PID sleep 5 2>/dev/null
    perf report -i $perf_data_path > $reportfile
    check_ret_code $?
    check_in_file hotspot_1 $reportfile
    perf annotate -i $perf_data_path -l -s hotspot_1 > $annotatefile
    check_ret_code $?
    check_in_file 'common_while_1.c:[[:digit:]]' $annotatefile
    perf annotate -i $perf_data_path --print-line -s hotspot_1 > ${annotatefile}1
    check_ret_code $?
    func_is_diff $annotatefile ${annotatefile}1
}
######################################################################
##- @Description: ending,clear the program env.
######################################################################
cleanenv()
{
    kill -9 $PID > /dev/null 2>&1
    rm $perf_data_path -rf
    [ -e /tmp/${USE_HUGE}common_while_1 ] && rm -rf /tmp/${USE_HUGE}common_while_1
    clean_end
}

######################################################################
##-@ Description:  main function
######################################################################
use_huge $*
prepareenv
dotest
cleanenv
